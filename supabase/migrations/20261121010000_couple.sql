-- Me + You (feat_couple): shared calendar and nudges, gated by unions.us_entitled.
--  - Events: members read all of the union's events. owner_uid null = shared, any member edits;
--    owner_uid set = that member's own event, only they edit or delete it.
--  - Nudges: written only by send_nudge(). Opt-in (recipient accepts_flags), 3 per sender per
--    rolling 24 hours, presence nudges never carry text (the reason is never stated).
--  - Push (FCM) is not wired yet; clients see new nudges through Realtime.

create function public.us_entitled(p_union uuid)
returns boolean
language sql stable security definer
set search_path = public
as $$
  select coalesce((select us_entitled from public.unions where id = p_union), false);
$$;

revoke all on function public.us_entitled(uuid) from public, anon;
grant execute on function public.us_entitled(uuid) to authenticated;

-- ---------------------------------------------------------------- events

alter table public.events
  add constraint events_end_after_start check (end_at is null or end_at >= start_at),
  add constraint events_reminders_array check (jsonb_typeof(reminders) = 'array');

drop policy events_all on public.events;

create policy events_read on public.events
  for select to authenticated
  using (public.is_member(union_id) and public.us_entitled(union_id));

create policy events_insert on public.events
  for insert to authenticated
  with check (
    public.is_member(union_id) and public.us_entitled(union_id)
    and (owner_uid is null or owner_uid = auth.uid())
  );

create policy events_update on public.events
  for update to authenticated
  using (
    public.is_member(union_id) and public.us_entitled(union_id)
    and (owner_uid is null or owner_uid = auth.uid())
  )
  with check (
    public.is_member(union_id) and public.us_entitled(union_id)
    and (owner_uid is null or owner_uid = auth.uid())
  );

create policy events_delete on public.events
  for delete to authenticated
  using (
    public.is_member(union_id) and public.us_entitled(union_id)
    and (owner_uid is null or owner_uid = auth.uid())
  );

-- Kids and Google sync columns stay function/later-owned.
revoke insert, update on public.events from authenticated;
grant insert (union_id, title, start_at, end_at, all_day, owner_uid, audience, reminders)
  on public.events to authenticated;
grant update (title, start_at, end_at, all_day, owner_uid, audience, reminders)
  on public.events to authenticated;

-- ---------------------------------------------------------------- nudges

create index nudges_from_at on public.nudges (from_uid, at);

create function public.send_nudge(p_to uuid, p_kind text, p_text text default null)
returns table (status text, nudge_id uuid)
language plpgsql security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  u_id uuid;
  recent int;
  n_id uuid;
  v_text text := nullif(btrim(coalesce(p_text, '')), '');
begin
  if uid is null then
    raise exception 'unauthenticated' using errcode = '28000';
  end if;

  if p_kind not in ('flag', 'presence') or p_to is null or p_to = uid
     or (v_text is not null and char_length(v_text) > 140) then
    return query select 'invalid'::text, null::uuid;
    return;
  end if;

  -- Sender and recipient must share the sender's active union.
  select p.active_union_id into u_id from public.profiles p where p.id = uid;
  if u_id is null
     or not exists (select 1 from public.members where union_id = u_id and user_id = uid)
     or not exists (select 1 from public.members where union_id = u_id and user_id = p_to) then
    return query select 'not_member'::text, null::uuid;
    return;
  end if;

  if not public.us_entitled(u_id) then
    return query select 'not_entitled'::text, null::uuid;
    return;
  end if;

  if not (select accepts_flags from public.members where union_id = u_id and user_id = p_to) then
    return query select 'not_accepting'::text, null::uuid;
    return;
  end if;

  -- Serialise this sender's sends so two at once can't both pass the limit.
  perform pg_advisory_xact_lock(hashtext('send_nudge:' || uid::text));
  select count(*) into recent from public.nudges
  where from_uid = uid and at > now() - interval '24 hours';
  if recent >= 3 then
    return query select 'rate_limited'::text, null::uuid;
    return;
  end if;

  insert into public.nudges (union_id, from_uid, to_uid, kind, text)
  values (u_id, uid, p_to, p_kind, case when p_kind = 'presence' then null else v_text end)
  returning id into n_id;

  -- FCM push goes here once Firebase is configured (stubbed in v0).
  return query select 'ok'::text, n_id;
end;
$$;

revoke all on function public.send_nudge(uuid, text, text) from public, anon;
grant execute on function public.send_nudge(uuid, text, text) to authenticated;

-- ---------------------------------------------------------------- realtime

-- Clients subscribe to these; RLS still decides which rows each person receives.
alter publication supabase_realtime add table public.events, public.nudges, public.members, public.unions;
