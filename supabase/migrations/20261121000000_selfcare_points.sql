-- Points earned for a self-care tick, snapshotted at tick time so later edits to an item's
-- point_value don't rewrite history. Me data: owner-only like the rest of selfcare_log.
alter table public.selfcare_log add column points int not null default 0 check (points >= 0);
