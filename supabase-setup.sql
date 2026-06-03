-- ════════════════════════════════════════════════════════════
--  TEAM SA RAFFLE — Supabase database setup
--  Run this ONCE in: Supabase Dashboard → SQL Editor → New query → Run
-- ════════════════════════════════════════════════════════════

-- 1) Entries table ------------------------------------------------
create table if not exists raffle_entries (
  id          bigint generated always as identity primary key,
  name        text not null,
  whatsapp    text,
  pkg         text not null,
  tickets     int  not null default 1,
  ticket_nums text not null default '',
  notes       text,
  ref         text,
  date        text,
  status      text not null default 'pending',   -- pending | confirmed | sent
  created_at  timestamptz default now()
);

-- 2) Settings table (holds the running ticket-number counter) -----
create table if not exists raffle_settings (
  key   text primary key,
  value text
);
insert into raffle_settings (key, value)
  values ('next_ticket', '1')
  on conflict (key) do nothing;

-- 3) Atomic "add entry + assign ticket numbers" function ----------
--    Guarantees no two entries ever get the same ticket number,
--    even if the website and manager add at the same moment.
create or replace function add_raffle_entry(
  p_name text, p_whatsapp text, p_pkg text, p_tickets int,
  p_notes text, p_ref text, p_date text, p_status text
) returns raffle_entries
language plpgsql
as $$
declare
  start_num int;
  nums      text;
  new_row   raffle_entries;
begin
  -- reserve a block of ticket numbers atomically
  update raffle_settings
     set value = (value::int + p_tickets)::text
   where key = 'next_ticket'
   returning (value::int - p_tickets) into start_num;

  if start_num is null then
    insert into raffle_settings(key, value) values ('next_ticket', (p_tickets + 1)::text);
    start_num := 1;
  end if;

  -- build "1, 2, 3" style ticket string
  select string_agg((start_num + g)::text, ', ')
    into nums
    from generate_series(0, p_tickets - 1) as g;

  insert into raffle_entries (name, whatsapp, pkg, tickets, ticket_nums, notes, ref, date, status)
       values (p_name, p_whatsapp, p_pkg, p_tickets, nums, p_notes, p_ref, p_date, p_status)
    returning * into new_row;

  return new_row;
end;
$$;

-- 4) Row Level Security + policies --------------------------------
--    (the public site needs to add entries; the manager reads/edits)
alter table raffle_entries  enable row level security;
alter table raffle_settings enable row level security;

drop policy if exists "rf_entries_all"  on raffle_entries;
drop policy if exists "rf_settings_all" on raffle_settings;

create policy "rf_entries_all"  on raffle_entries
  for all using (true) with check (true);
create policy "rf_settings_all" on raffle_settings
  for all using (true) with check (true);

grant execute on function add_raffle_entry to anon;

-- ════════════════════════════════════════════════════════════
--  Done! Your raffle now uses one shared cloud database.
-- ════════════════════════════════════════════════════════════
