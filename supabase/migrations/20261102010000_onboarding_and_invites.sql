-- Onboarding flag, and a way for the owner to get a fresh invite code later
-- (the first one is only returned by create_union; invites has no client access).

alter table public.members add column onboarded boolean not null default false;
grant update (onboarded) on public.members to authenticated;

-- Owner only. Replaces any earlier codes for the union, so only the newest works.
create function public.new_invite()
returns table (status text, invite_code text)
language plpgsql security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  u_id uuid;
  cnt int;
  code text;
begin
  if uid is null then
    raise exception 'unauthenticated' using errcode = '28000';
  end if;

  select m.union_id into u_id
  from public.members m
  where m.user_id = uid and m.role = 'owner';
  if u_id is null then
    return query select 'not_owner'::text, null::text;
    return;
  end if;

  select member_count into cnt from public.unions where id = u_id for update;
  if cnt >= 3 then
    return query select 'full'::text, null::text;
    return;
  end if;

  delete from public.invites where union_id = u_id;

  loop
    code := public.gen_invite_code();
    begin
      insert into public.invites (code, union_id, created_by, expires_at, uses_left)
      values (code, u_id, uid, now() + interval '7 days', 3 - cnt);
      exit;
    exception when unique_violation then
      null; -- collision, draw again
    end;
  end loop;

  return query select 'ok'::text, code;
end;
$$;

revoke all on function public.new_invite() from public, anon;
grant execute on function public.new_invite() to authenticated;
