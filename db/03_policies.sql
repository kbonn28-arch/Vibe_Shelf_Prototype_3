-- =============================================================================
-- VibeShelf — Row Level Security policies (optional)
-- File: db/03_policies.sql
-- These are illustrative starter policies. The local Express API uses the
-- service-role key and bypasses RLS, so these only matter once the client
-- talks to Supabase directly with the anon key.
-- =============================================================================

-- Enable RLS on user-scoped tables
alter table app_user enable row level security;
alter table profile enable row level security;
alter table bookshelf_entry enable row level security;
alter table review enable row level security;
alter table recommendation enable row level security;

-- A user can read/write their own row
create policy "users can see self"
  on app_user for select
  using (user_id = auth.uid());

-- Profiles: anyone can read public profiles; only owner can update
create policy "public profiles readable"
  on profile for select
  using (is_public = true or user_id = auth.uid());

create policy "owners update profile"
  on profile for update
  using (user_id = auth.uid());

-- Bookshelf entries: only the owner can read/write
create policy "owners read shelf"
  on bookshelf_entry for select
  using (user_id = auth.uid());

create policy "owners write shelf"
  on bookshelf_entry for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Reviews: public reviews readable by all; user can write/edit their own
create policy "public reviews readable"
  on review for select
  using (is_public = true or user_id = auth.uid());

create policy "owners write review"
  on review for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Recommendations: only owner can read/write their own session data
create policy "owners read reco"
  on recommendation for select
  using (user_id = auth.uid());

create policy "owners write reco"
  on recommendation for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Books, Genres, Moods are global lookup tables; leave RLS off (default deny)
-- or open them for SELECT to all authenticated users:
-- alter table book enable row level security;
-- create policy "books readable" on book for select using (true);
