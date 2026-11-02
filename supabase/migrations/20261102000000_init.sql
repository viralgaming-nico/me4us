-- Me4Us initial schema. See CLAUDE.md "Security rules" and "Data model".
--  - Me data (profiles, selfcare_*, checkins): owner only. Partners never read it.
--  - Union data: members read. Structural writes, nudges, matches = functions only.
--  - invites / invite_attempts: no client access at all.
-- Privileges are granted explicitly (revoke-all, then grant) so nothing depends on
-- Supabase's default grants.

-- ---------------------------------------------------------------- tables

create table public.profiles (
  id               uuid primary key references auth.users (id) on delete cascade,
  display_name     text,
  active_union_id  uuid,
  fcm_tokens       text[] not null default '{}',
  created_at       timestamptz not null default now()
);

create table public.unions (
  id             uuid primary key default gen_random_uuid(),
  member_count   int  not null default 1 check (member_count between 1 and 3),
  kids_entitled  boolean not null default false,
  created_at     timestamptz not null default now()
);

alter table public.profiles
  add constraint profiles_active_union_fk
  foreign key (active_union_id) references public.unions (id) on delete set null;

create table public.members (
  union_id        uuid not null references public.unions (id) on delete cascade,
  user_id         uuid not null references auth.users (id) on delete cascade,
  role            text not null default 'member' check (role in ('owner', 'member')),
  joined_at       timestamptz not null default now(),
  accepts_flags   boolean not null default false,
  hygiene_alerts  boolean not null default false,
  -- All four doors per person; effective door = ALL members opted in (computed client-side).
  my_doors        jsonb not null default '{"kids":false,"thirdPerson":false,"alcohol":false,"lite":false}'
                  check (jsonb_typeof(my_doors) = 'object'),
  points          int not null default 0,
  primary key (union_id, user_id)
);

create table public.selfcare_items (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users (id) on delete cascade,
  title        text not null,
  category     text not null check (category in ('basic', 'periodic', 'meds', 'nutrition')),
  cadence      text,
  point_value  int not null default 0,
  active       boolean not null default true
);

create table public.selfcare_log (
  user_id  uuid not null references auth.users (id) on delete cascade,
  item_id  uuid not null references public.selfcare_items (id) on delete cascade,
  date     date not null,
  done     boolean not null default true,
  at       timestamptz not null default now(),
  primary key (user_id, date, item_id)
);

create table public.checkins (
  user_id  uuid not null references auth.users (id) on delete cascade,
  date     date not null,
  answers  jsonb not null default '[]',
  primary key (user_id, date)
);

create table public.nudges (
  id        uuid primary key default gen_random_uuid(),
  union_id  uuid not null references public.unions (id) on delete cascade,
  from_uid  uuid not null references auth.users (id) on delete cascade,
  to_uid    uuid not null references auth.users (id) on delete cascade,
  kind      text not null check (kind in ('flag', 'presence')),
  text      text,
  at        timestamptz not null default now(),
  read_at   timestamptz
);

create table public.points_ledger (
  id        uuid primary key default gen_random_uuid(),
  union_id  uuid not null references public.unions (id) on delete cascade,
  user_id   uuid not null references auth.users (id) on delete cascade,
  delta     int not null,
  reason    text,
  ref_type  text,
  ref_id    text,
  at        timestamptz not null default now()
);

create table public.rewards (
  id          uuid primary key default gen_random_uuid(),
  union_id    uuid not null references public.unions (id) on delete cascade,
  title       text not null,
  cost        int not null check (cost >= 0),
  created_by  uuid not null references auth.users (id) on delete cascade,
  active      boolean not null default true
);

create table public.events (
  id               uuid primary key default gen_random_uuid(),
  union_id         uuid not null references public.unions (id) on delete cascade,
  title            text not null,
  start_at         timestamptz not null,
  end_at           timestamptz,
  all_day          boolean not null default false,
  owner_uid        uuid references auth.users (id) on delete set null,
  audience         text,
  kid_id           uuid,
  google_event_id  text,
  reminders        jsonb not null default '[]'
);

-- Kids add-on
create table public.kids (
  id          uuid primary key default gen_random_uuid(),
  union_id    uuid not null references public.unions (id) on delete cascade,
  name        text not null,
  birth_year  int
);

create table public.kid_tasks (
  id           uuid primary key default gen_random_uuid(),
  union_id     uuid not null references public.unions (id) on delete cascade,
  kid_id       uuid not null references public.kids (id) on delete cascade,
  title        text not null,
  recurrence   text,
  assigned_to  uuid references auth.users (id) on delete set null,
  done_log     jsonb not null default '[]'
);

-- Function-written, later
create table public.flist_matches (
  union_id    uuid not null references public.unions (id) on delete cascade,
  item_id     text not null,
  matched_at  timestamptz not null default now(),
  tier        text,
  primary key (union_id, item_id)
);

-- Function-only
create table public.invites (
  code        text primary key,
  union_id    uuid not null references public.unions (id) on delete cascade,
  created_by  uuid not null references auth.users (id) on delete cascade,
  expires_at  timestamptz not null,
  uses_left   int not null check (uses_left >= 0)
);

create table public.invite_attempts (
  user_id       uuid primary key references auth.users (id) on delete cascade,
  count         int not null,
  window_start  timestamptz not null
);

-- ---------------------------------------------------------------- helpers

create function public.is_member(p_union uuid)
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.members where union_id = p_union and user_id = auth.uid()
  );
$$;

create function public.kids_entitled(p_union uuid)
returns boolean
language sql stable security definer
set search_path = public
as $$
  select coalesce((select kids_entitled from public.unions where id = p_union), false);
$$;

-- Every signup gets a profile row.
create function public.handle_new_user()
returns trigger
language plpgsql security definer
set search_path = public
as $$
begin
  insert into public.profiles (id) values (new.id) on conflict do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------- row level security

alter table public.profiles        enable row level security;
alter table public.unions          enable row level security;
alter table public.members         enable row level security;
alter table public.selfcare_items  enable row level security;
alter table public.selfcare_log    enable row level security;
alter table public.checkins        enable row level security;
alter table public.nudges          enable row level security;
alter table public.points_ledger   enable row level security;
alter table public.rewards         enable row level security;
alter table public.events         enable row level security;
alter table public.kids            enable row level security;
alter table public.kid_tasks       enable row level security;
alter table public.flist_matches   enable row level security;
alter table public.invites         enable row level security;
alter table public.invite_attempts enable row level security;
-- invites / invite_attempts: RLS on and NO policies, NO grants = no client access.

-- Me data: owner only
create policy profiles_own on public.profiles
  for select to authenticated using (id = auth.uid());
create policy profiles_update_own on public.profiles
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

create policy selfcare_items_own on public.selfcare_items
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy selfcare_log_own on public.selfcare_log
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy checkins_own on public.checkins
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Union data
create policy unions_read on public.unions
  for select to authenticated using (public.is_member(id));

create policy members_read on public.members
  for select to authenticated using (public.is_member(union_id));
create policy members_update_own on public.members
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Only sender and recipient see a nudge (stricter than "members").
create policy nudges_read on public.nudges
  for select to authenticated using (from_uid = auth.uid() or to_uid = auth.uid());
create policy nudges_mark_read on public.nudges
  for update to authenticated using (to_uid = auth.uid()) with check (to_uid = auth.uid());

-- Append-only, own entries. Redemption = negative delta.
create policy ledger_read on public.points_ledger
  for select to authenticated using (public.is_member(union_id));
create policy ledger_insert on public.points_ledger
  for insert to authenticated
  with check (public.is_member(union_id) and user_id = auth.uid());

create policy rewards_read on public.rewards
  for select to authenticated using (public.is_member(union_id));
create policy rewards_insert on public.rewards
  for insert to authenticated
  with check (public.is_member(union_id) and created_by = auth.uid());
create policy rewards_update on public.rewards
  for update to authenticated
  using (public.is_member(union_id)) with check (public.is_member(union_id));
create policy rewards_delete on public.rewards
  for delete to authenticated using (public.is_member(union_id));

create policy events_all on public.events
  for all to authenticated
  using (public.is_member(union_id)) with check (public.is_member(union_id));

-- Kids add-on: usable only once the union is entitled.
create policy kids_read on public.kids
  for select to authenticated using (public.is_member(union_id));
create policy kids_write on public.kids
  for all to authenticated
  using (public.is_member(union_id) and public.kids_entitled(union_id))
  with check (public.is_member(union_id) and public.kids_entitled(union_id));

create policy kid_tasks_read on public.kid_tasks
  for select to authenticated using (public.is_member(union_id));
create policy kid_tasks_write on public.kid_tasks
  for all to authenticated
  using (public.is_member(union_id) and public.kids_entitled(union_id))
  with check (public.is_member(union_id) and public.kids_entitled(union_id));

create policy flist_matches_read on public.flist_matches
  for select to authenticated using (public.is_member(union_id));

-- ---------------------------------------------------------------- privileges

revoke all on all tables    in schema public from anon, authenticated;
revoke all on all functions in schema public from public, anon, authenticated;

grant usage on schema public to authenticated;

grant select                               on public.profiles       to authenticated;
-- active_union_id is set by create_union / redeem_invite only.
grant update (display_name, fcm_tokens)    on public.profiles       to authenticated;

grant select, insert, update, delete       on public.selfcare_items to authenticated;
grant select, insert, update, delete       on public.selfcare_log   to authenticated;
grant select, insert, update, delete       on public.checkins       to authenticated;

grant select                               on public.unions         to authenticated;
grant select                               on public.members        to authenticated;
-- A member edits only their own preferences; role, joined_at, points are function-owned.
grant update (accepts_flags, hygiene_alerts, my_doors) on public.members to authenticated;

grant select                               on public.nudges         to authenticated;
grant update (read_at)                     on public.nudges         to authenticated;

grant select, insert                       on public.points_ledger  to authenticated;
grant select, insert, update, delete       on public.rewards        to authenticated;
grant select, insert, update, delete       on public.events         to authenticated;
grant select, insert, update, delete       on public.kids           to authenticated;
grant select, insert, update, delete       on public.kid_tasks      to authenticated;
grant select                               on public.flist_matches  to authenticated;

-- ---------------------------------------------------------------- union functions

create function public.gen_invite_code()
returns text
language plpgsql volatile
as $$
declare
  alphabet constant text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'; -- no 0/O/1/I/L
  src bytea := uuid_send(gen_random_uuid());
  code text := '';
  i int;
begin
  -- bytes 0-5 and 9-10 of a v4 uuid are fully random
  foreach i in array array[0, 1, 2, 3, 4, 5, 9, 10] loop
    code := code || substr(alphabet, (get_byte(src, i) % 31) + 1, 1);
  end loop;
  return code;
end;
$$;

-- Expected failures (bad code, already in a union, rate limit) are returned as a status,
-- not raised, so the attempt counter commits even when the redeem fails.

create function public.create_union()
returns table (status text, union_id uuid, invite_code text)
language plpgsql security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  u_id uuid;
  code text;
begin
  if uid is null then
    raise exception 'unauthenticated' using errcode = '28000';
  end if;

  insert into public.profiles (id) values (uid) on conflict do nothing;

  if (select active_union_id from public.profiles where id = uid for update) is not null then
    return query select 'already_in_union'::text, null::uuid, null::text;
    return;
  end if;

  insert into public.unions default values returning id into u_id;
  insert into public.members (union_id, user_id, role) values (u_id, uid, 'owner');
  update public.profiles set active_union_id = u_id where id = uid;

  loop
    code := public.gen_invite_code();
    begin
      insert into public.invites (code, union_id, created_by, expires_at, uses_left)
      values (code, u_id, uid, now() + interval '7 days', 2);
      exit;
    exception when unique_violation then
      null; -- collision, draw again
    end;
  end loop;

  return query select 'ok'::text, u_id, code;
end;
$$;

create function public.redeem_invite(p_code text)
returns table (status text, union_id uuid)
language plpgsql security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_code text := upper(regexp_replace(coalesce(p_code, ''), '[\s-]', '', 'g'));
  att public.invite_attempts;
  inv public.invites;
  cnt int;
begin
  if uid is null then
    raise exception 'unauthenticated' using errcode = '28000';
  end if;

  insert into public.profiles (id) values (uid) on conflict do nothing;

  -- Count the attempt first. 5 per hour; a successful redeem clears the counter.
  select * into att from public.invite_attempts where user_id = uid for update;
  if not found then
    insert into public.invite_attempts (user_id, count, window_start) values (uid, 1, now());
  elsif now() - att.window_start >= interval '1 hour' then
    update public.invite_attempts set count = 1, window_start = now() where user_id = uid;
  elsif att.count >= 5 then
    return query select 'too_many_attempts'::text, null::uuid;
    return;
  else
    update public.invite_attempts set count = count + 1 where user_id = uid;
  end if;

  -- Same status for missing / expired / used up / full, so codes can't be probed.
  select * into inv from public.invites where invites.code = v_code for update;
  if not found or inv.expires_at <= now() or inv.uses_left <= 0 then
    return query select 'invalid'::text, null::uuid;
    return;
  end if;

  if (select active_union_id from public.profiles where id = uid for update) is not null then
    return query select 'already_in_union'::text, null::uuid;
    return;
  end if;

  select member_count into cnt from public.unions where id = inv.union_id for update;
  if cnt is null or cnt >= 3 then
    return query select 'invalid'::text, null::uuid;
    return;
  end if;

  update public.unions set member_count = member_count + 1 where id = inv.union_id;
  insert into public.members (union_id, user_id, role) values (inv.union_id, uid, 'member');
  update public.profiles set active_union_id = inv.union_id where id = uid;
  update public.invites set uses_left = uses_left - 1 where invites.code = v_code;
  delete from public.invite_attempts where user_id = uid;

  return query select 'ok'::text, inv.union_id;
end;
$$;

-- New functions default to EXECUTE for PUBLIC; close that, then open only what clients call.
revoke all on function public.gen_invite_code()   from public, anon, authenticated;
revoke all on function public.create_union()      from public, anon;
revoke all on function public.redeem_invite(text) from public, anon;
revoke all on function public.is_member(uuid)     from public, anon;
revoke all on function public.kids_entitled(uuid) from public, anon;
revoke all on function public.handle_new_user()   from public, anon, authenticated;
grant execute on function public.is_member(uuid)     to authenticated;
grant execute on function public.kids_entitled(uuid) to authenticated;
grant execute on function public.create_union()      to authenticated;
grant execute on function public.redeem_invite(text) to authenticated;
