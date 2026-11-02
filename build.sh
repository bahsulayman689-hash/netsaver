#!/bin/sh
set -e
rm -rf public && mkdir public
cp index.html dashboard.html sw.js manifest.json icon.svg ping.txt content.js i18n.js public/
U=$(printf %s "$SUPABASE_URL" | sed 's#/rest/v1/*$##; s#/*$##')
printf 'window.NS_CONFIG={SUPABASE_URL:"%s",SUPABASE_ANON:"%s"};\n' "$U" "$SUPABASE_ANON" > public/config.js
echo "built into public/"
