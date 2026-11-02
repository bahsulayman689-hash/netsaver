-- Run in Supabase SQL Editor. Crowd-sourced data bundle prices (the "high broadband costs" evidence).
create table if not exists public.bundle_prices (
  id          bigint generated always as identity primary key,
  client_id   text not null unique check (char_length(client_id) between 4 and 64),
  created_at  timestamptz not null default now(),
  provider    text not null check (char_length(provider) between 2 and 40),
  plan_name   text check (plan_name is null or char_length(plan_name) <= 60),
  price_gmd   numeric(10,2) not null check (price_gmd > 0 and price_gmd <= 100000),
  size_mb     numeric(12,2) not null check (size_mb > 0 and size_mb <= 1000000),
  valid_days  int not null check (valid_days between 1 and 365),
  cost_per_gb numeric generated always as (round(price_gmd / (size_mb / 1024.0), 2)) stored,
  approved    boolean not null default false
);

alter table public.bundle_prices enable row level security;
create policy "anon can submit prices" on public.bundle_prices for insert to anon with check (approved = false);
create policy "public reads approved prices" on public.bundle_prices for select to anon using (approved = true);
grant insert, select on public.bundle_prices to anon;
grant usage on sequence public.bundle_prices_id_seq to anon;

-- Median / min / max GMD per GB by provider, approved rows from the last 90 days.
create or replace function public.get_price_stats() returns json
language sql security definer set search_path = public stable as $$
  select coalesce(json_agg(t order by t.median_gmd_per_gb), '[]'::json) from (
    select initcap(trim(provider)) as provider,
           count(*) as n,
           round((percentile_cont(0.5) within group (order by cost_per_gb))::numeric, 2) as median_gmd_per_gb,
           min(cost_per_gb) as min_gmd_per_gb,
           max(cost_per_gb) as max_gmd_per_gb
    from bundle_prices
    where approved and created_at > now() - interval '90 days'
    group by 1) t;
$$;
revoke all on function public.get_price_stats() from public;
grant execute on function public.get_price_stats() to anon;

-- MODERATION:
--   select id, provider, plan_name, price_gmd, size_mb, valid_days, cost_per_gb from public.bundle_prices where not approved order by created_at;
--   update public.bundle_prices set approved = true where id in (1,2,3);
--   delete from public.bundle_prices where id in (4,5);
