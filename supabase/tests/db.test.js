import { readFileSync, readdirSync, rmSync } from 'node:fs';
import { before, after, beforeEach, describe, it } from 'node:test';
import assert from 'node:assert/strict';
import EmbeddedPostgres from 'embedded-postgres';
import pg from 'pg';

const here = (f) => new URL(f, import.meta.url);
const PORT = 54329;
const DATA = new URL('./.pgdata', import.meta.url).pathname.replace(/^\/(\w:)/, '$1');

const U = '00000000-0000-0000-0000-00000000000a'; // owner
const V = '00000000-0000-0000-0000-00000000000b'; // partner
const W = '00000000-0000-0000-0000-00000000000c'; // third member
const X = '00000000-0000-0000-0000-00000000000d'; // outsider
const Y = '00000000-0000-0000-0000-00000000000e'; // fourth person
const UN = '10000000-0000-0000-0000-000000000001';

let server;
let admin; // superuser connection (bypasses RLS)

before(async () => {
  rmSync(DATA, { recursive: true, force: true, maxRetries: 20, retryDelay: 250 });
  server = new EmbeddedPostgres({
    databaseDir: DATA, user: 'postgres', password: 'pw', port: PORT, persistent: false,
  });
  await server.initialise();
  await server.start();
  admin = new pg.Client({ host: 'localhost', port: PORT, user: 'postgres', password: 'pw', database: 'postgres' });
  await admin.connect();
  await admin.query(readFileSync(here('./shim.sql'), 'utf8'));
  // Apply every migration in filename (timestamp) order, like `supabase db push`.
  for (const f of readdirSync(here('../migrations/')).filter((f) => f.endsWith('.sql')).sort()) {
    await admin.query(readFileSync(here(`../migrations/${f}`), 'utf8'));
  }
});

after(async () => {
  await admin?.end();
  await server?.stop();
  // Best effort: on Windows Postgres can hold the folder briefly after stopping.
  // The next run wipes it in before(), so a leftover never affects results.
  try {
    rmSync(DATA, { recursive: true, force: true, maxRetries: 20, retryDelay: 250 });
  } catch {}
});

beforeEach(async () => {
  await admin.query('truncate auth.users, public.unions cascade');
  for (const id of [U, V, W, X, Y]) {
    await admin.query('insert into auth.users (id, email) values ($1, $2)', [id, `${id.slice(-1)}@t.test`]);
  }
  // A two-member union (U owner, V member) with one invite left.
  await admin.query(`insert into public.unions (id, member_count) values ($1, 2)`, [UN]);
  await admin.query(`insert into public.members (union_id, user_id, role) values ($1,$2,'owner'),($1,$3,'member')`, [UN, U, V]);
  await admin.query(`update public.profiles set active_union_id = $1 where id in ($2, $3)`, [UN, U, V]);
});

/** Run one statement as an authenticated user (or `anon` when uid is null), in its own transaction. */
async function run(uid, sql, params = []) {
  const c = new pg.Client({ host: 'localhost', port: PORT, user: 'postgres', password: 'pw', database: 'postgres' });
  await c.connect();
  try {
    await c.query('begin');
    await c.query(`set local role ${uid ? 'authenticated' : 'anon'}`);
    if (uid) await c.query(`select set_config('request.jwt.claims', $1, true)`, [JSON.stringify({ sub: uid, role: 'authenticated' })]);
    const r = await c.query(sql, params);
    await c.query('commit');
    return r;
  } catch (e) {
    await c.query('rollback').catch(() => {});
    throw e;
  } finally {
    await c.end();
  }
}

const ok = (uid, sql, params) => run(uid, sql, params);
const denied = (uid, sql, params) => assert.rejects(run(uid, sql, params));
const noRows = async (uid, sql, params) => assert.equal((await run(uid, sql, params)).rowCount, 0);

describe('Me data is owner-only', () => {
  beforeEach(() => admin.query(`insert into public.selfcare_items (id, user_id, title, category) values ('20000000-0000-0000-0000-000000000001', $1, 'teeth', 'basic')`, [U]));

  it('owner reads and writes own items and check-ins', async () => {
    assert.equal((await ok(U, 'select * from public.selfcare_items')).rowCount, 1);
    await ok(U, `insert into public.checkins (user_id, date, answers) values ($1, '2026-11-01', '[]')`, [U]);
  });
  it('partner cannot read or write them', async () => {
    await noRows(V, 'select * from public.selfcare_items');
    await denied(V, `insert into public.selfcare_items (user_id, title, category) values ($1, 'x', 'basic')`, [U]);
    await noRows(V, `update public.selfcare_items set title = 'hacked'`);
    await noRows(V, `delete from public.selfcare_items`);
    await noRows(V, `select * from public.profiles where id = $1`, [U]);
  });
  it('partner cannot read check-ins or the self-care log', async () => {
    await admin.query(`insert into public.checkins (user_id, date, answers) values ($1, '2026-11-01', '[{"qId":"mood","choiceId":"ok"}]')`, [U]);
    await admin.query(`insert into public.selfcare_log (user_id, date, item_id) values ($1, '2026-11-01', '20000000-0000-0000-0000-000000000001')`, [U]);
    await noRows(V, 'select * from public.checkins');
    await noRows(V, 'select * from public.selfcare_log');
    await noRows(V, `update public.checkins set answers = '[]'`);
    await noRows(V, 'delete from public.selfcare_log');
    await denied(V, `insert into public.checkins (user_id, date) values ($1, '2026-11-02')`, [U]);
  });
  it('self-care log stores a non-negative points snapshot', async () => {
    await ok(U, `insert into public.selfcare_log (user_id, date, item_id, points) values ($1, '2026-11-01', '20000000-0000-0000-0000-000000000001', 2)`, [U]);
    assert.equal((await ok(U, 'select points from public.selfcare_log')).rows[0].points, 2);
    await denied(U, `insert into public.selfcare_log (user_id, date, item_id, points) values ($1, '2026-11-02', '20000000-0000-0000-0000-000000000001', -1)`, [U]);
  });
  it('anon has no access', async () => {
    await denied(null, 'select * from public.selfcare_items');
    await denied(null, 'select * from public.profiles');
  });
  it('owner cannot set active_union_id', async () => {
    await denied(X, `update public.profiles set active_union_id = $1 where id = $2`, [UN, X]);
    await ok(X, `update public.profiles set display_name = 'New' where id = $1`, [X]);
  });
});

describe('unions: member-only reads, function-only structural writes', () => {
  it('members read union and members; outsider sees nothing', async () => {
    assert.equal((await ok(U, 'select * from public.unions')).rowCount, 1);
    assert.equal((await ok(V, 'select * from public.members')).rowCount, 2);
    await noRows(X, 'select * from public.unions');
    await noRows(X, 'select * from public.members');
  });
  it('us_entitled defaults to false and members can read it', async () => {
    assert.equal((await ok(U, 'select us_entitled from public.unions')).rows[0].us_entitled, false);
  });
  it('clients cannot write unions', async () => {
    await denied(U, `update public.unions set kids_entitled = true`);
    await denied(U, `update public.unions set us_entitled = true`);
    await denied(X, `insert into public.unions default values`);
    await denied(U, `delete from public.unions`);
  });
  it('member edits own preferences only', async () => {
    await ok(U, `update public.members set accepts_flags = true where user_id = $1`, [U]);
    await ok(U, `update public.members set my_doors = '{"kids":false,"thirdPerson":false,"alcohol":true,"lite":true}' where user_id = $1`, [U]);
    await denied(U, `update public.members set points = 999 where user_id = $1`, [U]);
    await denied(U, `update public.members set role = 'owner' where user_id = $1`, [V]);
    await noRows(U, `update public.members set accepts_flags = true where user_id = $1`, [V]);
  });
  it('clients cannot join by inserting a member row', async () => {
    await denied(X, `insert into public.members (union_id, user_id) values ($1, $2)`, [UN, X]);
  });
});

describe('nudges', () => {
  beforeEach(() => admin.query(`insert into public.nudges (id, union_id, from_uid, to_uid, kind) values ('30000000-0000-0000-0000-000000000001', $1, $2, $3, 'flag')`, [UN, U, V]));

  it('only sender and recipient read', async () => {
    assert.equal((await ok(V, 'select * from public.nudges')).rowCount, 1);
    assert.equal((await ok(U, 'select * from public.nudges')).rowCount, 1);
    await noRows(X, 'select * from public.nudges');
  });
  it('clients cannot create or delete nudges', async () => {
    await denied(U, `insert into public.nudges (union_id, from_uid, to_uid, kind) values ($1, $2, $3, 'flag')`, [UN, U, V]);
    await denied(V, 'delete from public.nudges');
  });
  it('recipient can set read_at only', async () => {
    await ok(V, `update public.nudges set read_at = now()`);
    await denied(V, `update public.nudges set text = 'hi'`);
    await noRows(U, `update public.nudges set read_at = now()`);
  });
});

describe('points_ledger', () => {
  it('append-only, own entries', async () => {
    await ok(U, `insert into public.points_ledger (union_id, user_id, delta, reason) values ($1, $2, 5, 'teeth')`, [UN, U]);
    await ok(U, `insert into public.points_ledger (union_id, user_id, delta, reason) values ($1, $2, -10, 'redeem')`, [UN, U]);
    await denied(U, `insert into public.points_ledger (union_id, user_id, delta) values ($1, $2, 5)`, [UN, V]);
    await denied(X, `insert into public.points_ledger (union_id, user_id, delta) values ($1, $2, 5)`, [UN, X]);
  });
  it('entries cannot be edited or deleted', async () => {
    await ok(U, `insert into public.points_ledger (union_id, user_id, delta) values ($1, $2, 5)`, [UN, U]);
    await denied(U, `update public.points_ledger set delta = 500`);
    await denied(U, `delete from public.points_ledger`);
  });
});

describe('events and rewards', () => {
  it('members read/write events, outsiders cannot', async () => {
    await admin.query('update public.unions set us_entitled = true where id = $1', [UN]);
    await ok(V, `insert into public.events (union_id, title, start_at) values ($1, 'Dinner', now())`, [UN]);
    assert.equal((await ok(U, 'select * from public.events')).rowCount, 1);
    await noRows(X, 'select * from public.events');
    await denied(X, `insert into public.events (union_id, title, start_at) values ($1, 'x', now())`, [UN]);
  });
  it('reward created_by must be the caller', async () => {
    await ok(U, `insert into public.rewards (union_id, title, cost, created_by) values ($1, 'Massage', 50, $2)`, [UN, U]);
    await denied(U, `insert into public.rewards (union_id, title, cost, created_by) values ($1, 'x', 1, $2)`, [UN, V]);
  });
});

describe('kids add-on', () => {
  it('blocked until kids_entitled', async () => {
    await denied(U, `insert into public.kids (union_id, name, birth_year) values ($1, 'K', 2020)`, [UN]);
    await admin.query('update public.unions set kids_entitled = true where id = $1', [UN]);
    await ok(U, `insert into public.kids (id, union_id, name, birth_year) values ('40000000-0000-0000-0000-000000000001', $1, 'K', 2020)`, [UN]);
    await ok(V, `insert into public.kid_tasks (union_id, kid_id, title) values ($1, '40000000-0000-0000-0000-000000000001', 'Teeth')`, [UN]);
    await denied(X, `insert into public.kid_tasks (union_id, kid_id, title) values ($1, '40000000-0000-0000-0000-000000000001', 'x')`, [UN]);
  });
});

describe('flist_matches, invites, invite_attempts', () => {
  it('members read matches, never write', async () => {
    await admin.query(`insert into public.flist_matches (union_id, item_id) values ($1, 'i1')`, [UN]);
    assert.equal((await ok(U, 'select * from public.flist_matches')).rowCount, 1);
    await noRows(X, 'select * from public.flist_matches');
    await denied(U, `insert into public.flist_matches (union_id, item_id) values ($1, 'i2')`, [UN]);
  });
  it('invites and invite_attempts have no client access', async () => {
    await admin.query(`insert into public.invites (code, union_id, created_by, expires_at, uses_left) values ('ABC123XY', $1, $2, now() + interval '1 day', 1)`, [UN, U]);
    await denied(U, 'select * from public.invites');
    await denied(U, `insert into public.invites (code, union_id, created_by, expires_at, uses_left) values ('NEW', $1, $2, now(), 1)`, [UN, U]);
    await denied(U, 'select * from public.invite_attempts');
    await denied(U, `insert into public.invite_attempts (user_id, count, window_start) values ($1, 0, now())`, [U]);
  });
});

describe('create_union', () => {
  it('creates union, owner member, profile pointer and a 7-day invite with 2 uses', async () => {
    const r = (await ok(X, 'select * from public.create_union()')).rows[0];
    assert.equal(r.status, 'ok');
    assert.match(r.invite_code, /^[A-HJKMNP-Z2-9]{8}$/);
    const u = (await admin.query('select * from public.unions where id = $1', [r.union_id])).rows[0];
    assert.equal(u.member_count, 1);
    assert.equal(u.kids_entitled, false);
    const m = (await admin.query('select * from public.members where union_id = $1', [r.union_id])).rows[0];
    assert.equal(m.role, 'owner');
    assert.deepEqual(m.my_doors, { kids: false, thirdPerson: false, alcohol: false, lite: false });
    assert.equal((await admin.query('select active_union_id from public.profiles where id = $1', [X])).rows[0].active_union_id, r.union_id);
    const inv = (await admin.query('select * from public.invites where code = $1', [r.invite_code])).rows[0];
    assert.equal(inv.uses_left, 2);
    assert.equal(inv.created_by, X);
  });
  it('refuses a second union for the same user', async () => {
    assert.equal((await ok(U, 'select * from public.create_union()')).rows[0].status, 'already_in_union');
  });
  it('requires sign-in', async () => {
    await denied(null, 'select * from public.create_union()');
  });
});

describe('redeem_invite', () => {
  const create = async () => (await ok(X, 'select * from public.create_union()')).rows[0];
  const redeem = async (uid, code) => (await ok(uid, 'select * from public.redeem_invite($1)', [code])).rows[0];

  it('joins a second and third member, then the union is full', async () => {
    await admin.query('update public.profiles set active_union_id = null where id in ($1,$2)', [U, V]);
    await admin.query('delete from public.members');
    await admin.query('delete from public.unions');
    const { union_id, invite_code } = await create();
    assert.deepEqual(await redeem(V, invite_code), { status: 'ok', union_id });
    assert.deepEqual(await redeem(W, invite_code.toLowerCase()), { status: 'ok', union_id });
    assert.equal((await admin.query('select member_count from public.unions where id = $1', [union_id])).rows[0].member_count, 3);
    assert.equal((await admin.query('select role from public.members where user_id = $1', [V])).rows[0].role, 'member');
    assert.equal((await admin.query('select active_union_id from public.profiles where id = $1', [W])).rows[0].active_union_id, union_id);
    assert.equal((await redeem(Y, invite_code)).status, 'invalid');
    assert.equal((await admin.query('select member_count from public.unions where id = $1', [union_id])).rows[0].member_count, 3);
  });
  it('unknown code is invalid', async () => {
    assert.equal((await redeem(Y, 'ZZZZZZZZ')).status, 'invalid');
  });
  it('code is normalised: spaces, dashes and case', async () => {
    const { union_id, invite_code } = await create();
    const spaced = `${invite_code.slice(0, 4).toLowerCase()}-${invite_code.slice(4)} `;
    assert.deepEqual(await redeem(Y, spaced), { status: 'ok', union_id });
  });
  it('expired code looks the same as an unknown one', async () => {
    const { invite_code } = await create();
    await admin.query(`update public.invites set expires_at = now() - interval '1 second'`);
    assert.equal((await redeem(Y, invite_code)).status, 'invalid');
  });
  it('cannot join while already in a union', async () => {
    const { invite_code } = await create();
    assert.equal((await redeem(U, invite_code)).status, 'already_in_union');
  });
  it('owner cannot redeem their own code', async () => {
    const { invite_code } = await create();
    assert.equal((await redeem(X, invite_code)).status, 'already_in_union');
  });
  it('limits failed attempts to 5 per hour, then recovers', async () => {
    for (let i = 0; i < 5; i++) assert.equal((await redeem(Y, 'ZZZZZZZZ')).status, 'invalid');
    assert.equal((await redeem(Y, 'ZZZZZZZZ')).status, 'too_many_attempts');
    const { union_id, invite_code } = await create();
    assert.equal((await redeem(Y, invite_code)).status, 'too_many_attempts');
    await admin.query(`update public.invite_attempts set window_start = now() - interval '61 minutes'`);
    assert.deepEqual(await redeem(Y, invite_code), { status: 'ok', union_id });
  });
  it('a failed attempt is committed, not rolled back', async () => {
    assert.equal((await redeem(Y, 'ZZZZZZZZ')).status, 'invalid');
    assert.equal((await redeem(Y, 'ZZZZZZZZ')).status, 'invalid');
    const att = (await admin.query('select count from public.invite_attempts where user_id = $1', [Y])).rows[0];
    assert.equal(att.count, 2);
  });
  it('successful redeem clears the attempt counter', async () => {
    const { invite_code } = await create();
    await redeem(Y, 'ZZZZZZZZ');
    await redeem(Y, invite_code);
    assert.equal((await admin.query('select * from public.invite_attempts where user_id = $1', [Y])).rowCount, 0);
  });
  it('requires sign-in', async () => {
    await denied(null, `select * from public.redeem_invite('ABC')`);
  });
});

describe('onboarding flag and new_invite', () => {
  it('member sets own onboarded flag only', async () => {
    await ok(V, `update public.members set onboarded = true where user_id = $1`, [V]);
    assert.equal((await admin.query('select onboarded from public.members where user_id = $1', [V])).rows[0].onboarded, true);
    await noRows(V, `update public.members set onboarded = true where user_id = $1`, [U]);
  });
  it('owner gets a fresh code that replaces the old one', async () => {
    const first = (await ok(U, 'select * from public.new_invite()')).rows[0];
    assert.equal(first.status, 'ok');
    assert.match(first.invite_code, /^[A-HJKMNP-Z2-9]{8}$/);
    const second = (await ok(U, 'select * from public.new_invite()')).rows[0];
    const codes = (await admin.query('select code, uses_left from public.invites where union_id = $1', [UN])).rows;
    assert.deepEqual(codes, [{ code: second.invite_code, uses_left: 1 }]); // 2 members -> 1 seat left
  });
  it('a code from new_invite can be redeemed', async () => {
    const { invite_code } = (await ok(U, 'select * from public.new_invite()')).rows[0];
    const r = (await ok(W, 'select * from public.redeem_invite($1)', [invite_code])).rows[0];
    assert.deepEqual(r, { status: 'ok', union_id: UN });
  });
  it('non-owner and outsider are refused; full union has no seat', async () => {
    assert.equal((await ok(V, 'select * from public.new_invite()')).rows[0].status, 'not_owner');
    assert.equal((await ok(X, 'select * from public.new_invite()')).rows[0].status, 'not_owner');
    await admin.query('update public.unions set member_count = 3 where id = $1', [UN]);
    assert.equal((await ok(U, 'select * from public.new_invite()')).rows[0].status, 'full');
  });
  it('requires sign-in', async () => {
    await denied(null, 'select * from public.new_invite()');
  });
});

describe('calendar (Me + You)', () => {
  const ins = (uid, owner, title = 'e') =>
    run(uid, `insert into public.events (union_id, title, start_at, owner_uid, reminders) values ($1, $2, now(), $3, '[60]') returning id`, [UN, title, owner]);
  beforeEach(() => admin.query('update public.unions set us_entitled = true where id = $1', [UN]));

  it('locked until the union is entitled', async () => {
    await admin.query('update public.unions set us_entitled = false where id = $1', [UN]);
    await admin.query(`insert into public.events (union_id, title, start_at) values ($1, 'x', now())`, [UN]);
    await denied(U, `insert into public.events (union_id, title, start_at) values ($1, 'x', now())`, [UN]);
    await noRows(U, 'select * from public.events');
  });
  it('shared events: any member edits and deletes', async () => {
    const { id } = (await ins(U, null)).rows[0];
    await ok(V, `update public.events set title = 'moved' where id = $1`, [id]);
    assert.equal((await ok(U, 'select title from public.events')).rows[0].title, 'moved');
    await ok(V, 'delete from public.events where id = $1', [id]);
    await noRows(U, 'select * from public.events');
  });
  it('own events: partner sees them but cannot change them', async () => {
    const { id } = (await ins(U, U, 'dentist')).rows[0];
    assert.equal((await ok(V, 'select title from public.events')).rows[0].title, 'dentist');
    await noRows(V, `update public.events set title = 'x' where id = $1`, [id]);
    await noRows(V, 'delete from public.events where id = $1', [id]);
    await ok(U, `update public.events set title = 'dentist 3pm' where id = $1`, [id]);
  });
  it('cannot create or reassign an event as someone else', async () => {
    await denied(U, `insert into public.events (union_id, title, start_at, owner_uid) values ($1, 'x', now(), $2)`, [UN, V]);
    const { id } = (await ins(U, null)).rows[0];
    await denied(U, `update public.events set owner_uid = $2 where id = $1`, [id, V]);
  });
  it('rejects end before start, non-array reminders, and Google/kids columns', async () => {
    await denied(U, `insert into public.events (union_id, title, start_at, end_at) values ($1, 'x', now(), now() - interval '1 hour')`, [UN]);
    await denied(U, `insert into public.events (union_id, title, start_at, reminders) values ($1, 'x', now(), '{}')`, [UN]);
    await denied(U, `insert into public.events (union_id, title, start_at, google_event_id) values ($1, 'x', now(), 'g')`, [UN]);
  });
});

describe('send_nudge', () => {
  const send = async (uid, to, kind = 'flag', text = null) =>
    (await ok(uid, 'select * from public.send_nudge($1, $2, $3)', [to, kind, text])).rows[0].status;
  beforeEach(async () => {
    await admin.query('update public.unions set us_entitled = true where id = $1', [UN]);
    await admin.query('update public.members set accepts_flags = true where user_id = $1', [V]);
  });

  it('delivers to an opted-in partner; only sender and recipient see it', async () => {
    assert.equal(await send(U, V, 'flag', '  hug?  '), 'ok');
    const n = (await ok(V, 'select * from public.nudges')).rows[0];
    assert.equal(n.text, 'hug?');
    assert.equal(n.from_uid, U);
    assert.equal(n.union_id, UN);
    await ok(V, `update public.nudges set read_at = now()`);
  });
  it('presence nudges never carry a reason', async () => {
    assert.equal(await send(U, V, 'presence', 'because you skipped meds'), 'ok');
    assert.equal((await admin.query('select text from public.nudges')).rows[0].text, null);
  });
  it('recipient must opt in', async () => {
    assert.equal(await send(V, U), 'not_accepting');
    assert.equal((await admin.query('select count(*)::int c from public.nudges')).rows[0].c, 0);
  });
  it('3 per sender per 24 hours, then recovers', async () => {
    for (let i = 0; i < 3; i++) assert.equal(await send(U, V), 'ok');
    assert.equal(await send(U, V, 'presence'), 'rate_limited');
    await admin.query(`update public.nudges set at = now() - interval '25 hours'`);
    assert.equal(await send(U, V), 'ok');
  });
  it('not entitled, outsiders, self and bad input are refused', async () => {
    assert.equal(await send(X, V), 'not_member');
    assert.equal(await send(U, U), 'invalid');
    assert.equal(await send(U, V, 'kiss'), 'invalid');
    assert.equal(await send(U, V, 'flag', 'x'.repeat(141)), 'invalid');
    await admin.query('update public.unions set us_entitled = false where id = $1', [UN]);
    assert.equal(await send(U, V), 'not_entitled');
  });
  it('requires sign-in', async () => {
    await denied(null, `select * from public.send_nudge($1, 'flag')`, [V]);
  });
});

describe('ping (keep-awake)', () => {
  it('anyone can call it; it returns true and nothing else', async () => {
    assert.equal((await run(null, 'select public.ping() as p')).rows[0].p, true);
  });
});
