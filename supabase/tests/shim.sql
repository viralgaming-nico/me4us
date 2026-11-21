-- Minimal stand-in for the parts of Supabase the migration relies on, so the
-- migration can run on plain Postgres. Real Supabase provides all of this.
create schema auth;

create table auth.users (
  id uuid primary key default gen_random_uuid(),
  email text
);

-- Same lookup order Supabase uses: the claims JSON set per request.
create function auth.uid() returns uuid
language sql stable as $$
  select coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub'
  )::uuid
$$;

create role anon nologin;
create role authenticated nologin;
create role service_role nologin bypassrls;

-- Supabase ships these default grants on the public schema; the migration must not rely on them.
grant usage on schema public, auth to anon, authenticated, service_role;
grant execute on function auth.uid() to anon, authenticated, service_role;
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to anon, authenticated, service_role;

-- Supabase creates this publication for Realtime.
create publication supabase_realtime;
