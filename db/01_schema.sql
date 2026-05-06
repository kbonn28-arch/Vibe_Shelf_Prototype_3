-- =============================================================================
-- VibeShelf — Database schema (Level 3 spec)
-- File: db/01_schema.sql
-- Run order: 01_schema.sql -> 02_seed.sql -> (optional) 03_policies.sql
-- =============================================================================

-- Drop in reverse-dependency order (idempotent re-runs)
drop table if exists recommendation cascade;
drop table if exists review cascade;
drop table if exists bookshelf_entry cascade;
drop table if exists book_mood cascade;
drop table if exists book_genre cascade;
drop table if exists mood cascade;
drop table if exists genre cascade;
drop table if exists book cascade;
drop table if exists profile cascade;
drop table if exists app_user cascade;

-- -----------------------------------------------------------------------------
-- USER
-- -----------------------------------------------------------------------------
create table app_user (
  user_id        uuid primary key default gen_random_uuid(),
  email          text not null unique,
  password_hash  text not null,
  created_at     timestamptz not null default now(),
  last_login_at  timestamptz
);

-- -----------------------------------------------------------------------------
-- PROFILE (1:1 with USER)
-- -----------------------------------------------------------------------------
create table profile (
  profile_id  uuid primary key default gen_random_uuid(),
  user_id     uuid not null unique references app_user(user_id) on delete cascade,
  username    text not null unique,
  bio         text,
  is_public   boolean not null default true
);

-- -----------------------------------------------------------------------------
-- BOOK
-- -----------------------------------------------------------------------------
create table book (
  book_id          uuid primary key default gen_random_uuid(),
  title            text not null,
  author           text not null,
  isbn             text unique,
  description      text,
  cover_image_url  text,                   -- NEW in L3: manually uploaded by user
  created_at       timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- GENRE
-- -----------------------------------------------------------------------------
create table genre (
  genre_id     uuid primary key default gen_random_uuid(),
  name         text not null unique,
  description  text
);

-- -----------------------------------------------------------------------------
-- MOOD
-- -----------------------------------------------------------------------------
create table mood (
  mood_id      uuid primary key default gen_random_uuid(),
  name         text not null unique,
  description  text
);

-- -----------------------------------------------------------------------------
-- BOOK_GENRE (many-to-many junction)
-- -----------------------------------------------------------------------------
create table book_genre (
  book_id   uuid not null references book(book_id) on delete cascade,
  genre_id  uuid not null references genre(genre_id) on delete cascade,
  primary key (book_id, genre_id)
);

-- -----------------------------------------------------------------------------
-- BOOK_MOOD (many-to-many junction; max 2 enforced at app layer per spec)
-- -----------------------------------------------------------------------------
create table book_mood (
  book_id   uuid not null references book(book_id) on delete cascade,
  mood_id   uuid not null references mood(mood_id) on delete cascade,
  primary key (book_id, mood_id)
);

-- Application-layer rule: max 2 mood tags per book (also enforced via trigger)
create or replace function check_book_mood_limit()
returns trigger as $$
begin
  if (select count(*) from book_mood where book_id = new.book_id) >= 2 then
    raise exception 'A book may have at most 2 mood tags';
  end if;
  return new;
end;
$$ language plpgsql;

create trigger book_mood_max_2
before insert on book_mood
for each row execute function check_book_mood_limit();

-- -----------------------------------------------------------------------------
-- BOOKSHELF_ENTRY
-- -----------------------------------------------------------------------------
create table bookshelf_entry (
  entry_id         uuid primary key default gen_random_uuid(),
  user_id          uuid not null references app_user(user_id) on delete cascade,
  book_id          uuid not null references book(book_id) on delete cascade,
  status           text not null check (status in (
                     'want_to_read','currently_reading','finished',
                     'paused','dropped','re_reading')),
  start_date       date,
  finish_date      date,
  added_at         timestamptz not null default now(),
  is_favorited     boolean not null default false,        -- NEW in L3
  personal_rating  integer check (personal_rating between 1 and 5), -- NEW in L3
  personal_note    text,
  unique (user_id, book_id)
);

create index idx_bookshelf_user on bookshelf_entry(user_id);
create index idx_bookshelf_status on bookshelf_entry(status);

-- -----------------------------------------------------------------------------
-- REVIEW
-- -----------------------------------------------------------------------------
create table review (
  review_id    uuid primary key default gen_random_uuid(),
  user_id      uuid not null references app_user(user_id) on delete cascade,
  book_id      uuid not null references book(book_id) on delete cascade,
  star_rating  integer not null check (star_rating between 1 and 5),
  review_text  text,
  review_date  timestamptz not null default now(),
  is_public    boolean not null default true
);

create index idx_review_book on review(book_id);
create index idx_review_user on review(user_id);

-- -----------------------------------------------------------------------------
-- RECOMMENDATION
-- -----------------------------------------------------------------------------
create table recommendation (
  recommendation_id  uuid primary key default gen_random_uuid(),
  user_id            uuid not null references app_user(user_id) on delete cascade,
  book_id            uuid not null references book(book_id) on delete cascade,
  mood_id            uuid not null references mood(mood_id) on delete cascade,
  recommended_at     timestamptz not null default now(),
  session_id         text not null,
  status             text not null check (status in (
                       'shown','skipped','not_interested','saved'))
);

create index idx_reco_user on recommendation(user_id);
create index idx_reco_session on recommendation(session_id);
