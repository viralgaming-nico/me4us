-- Keep-awake target for .github/workflows/keep-supabase-awake.yml. Free projects pause after
-- about a week without database activity. Returns a constant and reads no data, so it is
-- the one thing anon may execute.
create function public.ping()
returns boolean
language sql stable
as $$ select true $$;

revoke all on function public.ping() from public;
grant execute on function public.ping() to anon, authenticated;
