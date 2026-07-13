-- Orbit Notes schema for project oyjxpiradbbuocxsunmu
-- Run in Supabase SQL Editor if CLI/MCP is not linked to this project.

create extension if not exists "pgcrypto";

-- Trips
create table if not exists public.orbit_trips (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  start_date date not null,
  end_date date not null,
  destination text not null default '',
  cover_path text,
  cover_url text,
  accent_index int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Days
create table if not exists public.orbit_days (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  trip_id text not null references public.orbit_trips (id) on delete cascade,
  date date not null,
  title text,
  note text,
  created_at timestamptz not null default now()
);

-- Entries
create table if not exists public.orbit_entries (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  day_id text not null references public.orbit_days (id) on delete cascade,
  body text not null,
  place_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

-- Photos (metadata; files in storage)
create table if not exists public.orbit_photos (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  entry_id text references public.orbit_entries (id) on delete cascade,
  trip_id text references public.orbit_trips (id) on delete cascade,
  local_path text,
  storage_path text,
  public_url text,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

-- Map pins
create table if not exists public.orbit_map_pins (
  id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  latitude double precision not null,
  longitude double precision not null,
  label text not null default '',
  trip_id text references public.orbit_trips (id) on delete cascade,
  day_id text references public.orbit_days (id) on delete set null,
  entry_id text references public.orbit_entries (id) on delete cascade,
  created_at timestamptz not null default now()
);

create index if not exists orbit_trips_user_id_idx on public.orbit_trips (user_id);
create index if not exists orbit_days_trip_id_idx on public.orbit_days (trip_id);
create index if not exists orbit_entries_day_id_idx on public.orbit_entries (day_id);
create index if not exists orbit_photos_trip_id_idx on public.orbit_photos (trip_id);
create index if not exists orbit_map_pins_trip_id_idx on public.orbit_map_pins (trip_id);
create unique index if not exists orbit_map_pins_entry_id_uidx
  on public.orbit_map_pins (entry_id)
  where entry_id is not null;

alter table public.orbit_trips enable row level security;
alter table public.orbit_days enable row level security;
alter table public.orbit_entries enable row level security;
alter table public.orbit_photos enable row level security;
alter table public.orbit_map_pins enable row level security;

-- RLS: owner-only
create policy "orbit_trips_select_own" on public.orbit_trips
  for select using (auth.uid() = user_id);
create policy "orbit_trips_insert_own" on public.orbit_trips
  for insert with check (auth.uid() = user_id);
create policy "orbit_trips_update_own" on public.orbit_trips
  for update using (auth.uid() = user_id);
create policy "orbit_trips_delete_own" on public.orbit_trips
  for delete using (auth.uid() = user_id);

create policy "orbit_days_select_own" on public.orbit_days
  for select using (auth.uid() = user_id);
create policy "orbit_days_insert_own" on public.orbit_days
  for insert with check (auth.uid() = user_id);
create policy "orbit_days_update_own" on public.orbit_days
  for update using (auth.uid() = user_id);
create policy "orbit_days_delete_own" on public.orbit_days
  for delete using (auth.uid() = user_id);

create policy "orbit_entries_select_own" on public.orbit_entries
  for select using (auth.uid() = user_id);
create policy "orbit_entries_insert_own" on public.orbit_entries
  for insert with check (auth.uid() = user_id);
create policy "orbit_entries_update_own" on public.orbit_entries
  for update using (auth.uid() = user_id);
create policy "orbit_entries_delete_own" on public.orbit_entries
  for delete using (auth.uid() = user_id);

create policy "orbit_photos_select_own" on public.orbit_photos
  for select using (auth.uid() = user_id);
create policy "orbit_photos_insert_own" on public.orbit_photos
  for insert with check (auth.uid() = user_id);
create policy "orbit_photos_update_own" on public.orbit_photos
  for update using (auth.uid() = user_id);
create policy "orbit_photos_delete_own" on public.orbit_photos
  for delete using (auth.uid() = user_id);

create policy "orbit_map_pins_select_own" on public.orbit_map_pins
  for select using (auth.uid() = user_id);
create policy "orbit_map_pins_insert_own" on public.orbit_map_pins
  for insert with check (auth.uid() = user_id);
create policy "orbit_map_pins_update_own" on public.orbit_map_pins
  for update using (auth.uid() = user_id);
create policy "orbit_map_pins_delete_own" on public.orbit_map_pins
  for delete using (auth.uid() = user_id);

-- Storage bucket for trip photos
insert into storage.buckets (id, name, public)
values ('orbit-photos', 'orbit-photos', true)
on conflict (id) do nothing;

create policy "orbit_photos_storage_select"
  on storage.objects for select
  using (bucket_id = 'orbit-photos' and auth.uid()::text = (storage.foldername(name))[1]);

create policy "orbit_photos_storage_insert"
  on storage.objects for insert
  with check (bucket_id = 'orbit-photos' and auth.uid()::text = (storage.foldername(name))[1]);

create policy "orbit_photos_storage_update"
  on storage.objects for update
  using (bucket_id = 'orbit-photos' and auth.uid()::text = (storage.foldername(name))[1]);

create policy "orbit_photos_storage_delete"
  on storage.objects for delete
  using (bucket_id = 'orbit-photos' and auth.uid()::text = (storage.foldername(name))[1]);
