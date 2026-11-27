-- Me + You (couple features) entitlement, per union. Set only by a SQL function / service
-- role once billing exists (stubbed paywall in v0). Clients keep select-only on unions,
-- so they can read it but never write it.
alter table public.unions add column us_entitled boolean not null default false;
