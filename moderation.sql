-- Run ONCE in Supabase SQL Editor: hides phone-number-like text in new reports before anyone can see them.
create or replace function public.mask_numbers() returns trigger
language plpgsql as $$
begin
  new.body := regexp_replace(new.body, '\+?\d[\d\s-]{5,}\d', '[number hidden]', 'g');
  new.provider := nullif(regexp_replace(coalesce(new.provider, ''), '\d{4,}', '', 'g'), '');
  return new;
end $$;

drop trigger if exists reports_mask on public.reports;
create trigger reports_mask before insert on public.reports
for each row execute function public.mask_numbers();

-- ===== DAILY MODERATION (run these as needed) =====
-- 1) See what is waiting:
--    select id, created_at, type, provider, body, lat, lng from public.reports where not approved order by created_at;
-- 2) Approve good ones (replace the ids):
--    update public.reports set approved = true where id in (1, 2, 3);
-- 3) Delete spam or abuse:
--    delete from public.reports where id in (4, 5);
-- 4) Remove your own test data:
--    delete from public.reports where body ilike '%test%';
