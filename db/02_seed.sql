-- =============================================================================
-- VibeShelf — Seed data (realistic, 3-5 rows per table)
-- File: db/02_seed.sql
-- Run after 01_schema.sql
-- =============================================================================

-- We use deterministic UUIDs (literal text-cast) so foreign keys are easy to wire.
-- In production these would all be defaults.

-- ---------- USERS ----------
insert into app_user (user_id, email, password_hash) values
('11111111-1111-1111-1111-111111111111','ada@vibeshelf.app','h_seed_ada'),
('22222222-2222-2222-2222-222222222222','milo@vibeshelf.app','h_seed_milo'),
('33333333-3333-3333-3333-333333333333','noor@vibeshelf.app','h_seed_noor'),
('44444444-4444-4444-4444-444444444444','jay@vibeshelf.app','h_seed_jay');

-- ---------- PROFILES ----------
insert into profile (user_id, username, bio, is_public) values
('11111111-1111-1111-1111-111111111111','adareads','Coastal librarian. Lives for slow novels and rainy afternoons.', true),
('22222222-2222-2222-2222-222222222222','milobooks','Sci-fi nerd by night, accountant by day.', true),
('33333333-3333-3333-3333-333333333333','noorpages','Literary fiction & memoirs. Always one book behind.', true),
('44444444-4444-4444-4444-444444444444','jaylight','Casual reader. Mostly cosy mysteries.', false);

-- ---------- GENRES ----------
insert into genre (genre_id, name, description) values
('aaaaaaaa-0000-0000-0000-000000000001','Fiction','General fiction'),
('aaaaaaaa-0000-0000-0000-000000000002','Mystery','Whodunits and suspense'),
('aaaaaaaa-0000-0000-0000-000000000003','Sci-Fi','Speculative & science fiction'),
('aaaaaaaa-0000-0000-0000-000000000004','Fantasy','Magical & speculative worlds'),
('aaaaaaaa-0000-0000-0000-000000000005','Romance','Love stories'),
('aaaaaaaa-0000-0000-0000-000000000006','Memoir','Personal nonfiction');

-- ---------- MOODS ----------
insert into mood (mood_id, name, description) values
('bbbbbbbb-0000-0000-0000-000000000001','Cosy','Warm, comforting, gentle reads'),
('bbbbbbbb-0000-0000-0000-000000000002','Thrilling','High-tension page-turners'),
('bbbbbbbb-0000-0000-0000-000000000003','Adventurous','Big journeys & big stakes'),
('bbbbbbbb-0000-0000-0000-000000000004','Romantic','Hearts and longing'),
('bbbbbbbb-0000-0000-0000-000000000005','Reflective','Quiet, thoughtful, internal'),
('bbbbbbbb-0000-0000-0000-000000000006','Hopeful','Uplifting & forward-looking');

-- ---------- BOOKS ----------
insert into book (book_id, title, author, isbn, description, cover_image_url) values
('cccccccc-0000-0000-0000-000000000001','The House in the Cerulean Sea','TJ Klune','9781250217288',
 'A magical island, a quiet caseworker, and a found family that mends broken hearts.', null),
('cccccccc-0000-0000-0000-000000000002','Project Hail Mary','Andy Weir','9780593135204',
 'A lone astronaut wakes up in deep space and must solve a problem to save Earth.', null),
('cccccccc-0000-0000-0000-000000000003','Beach Read','Emily Henry','9781984806734',
 'Two rival writers swap genres and hearts over one Michigan summer.', null),
('cccccccc-0000-0000-0000-000000000004','The Midnight Library','Matt Haig','9780525559474',
 'Between life and death sits a library — every book a life you could have lived.', null),
('cccccccc-0000-0000-0000-000000000005','Piranesi','Susanna Clarke','9781635575637',
 'A flooded labyrinthine house, a single inhabitant, and a secret that grows.', null);

-- ---------- BOOK_GENRE ----------
insert into book_genre (book_id, genre_id) values
('cccccccc-0000-0000-0000-000000000001','aaaaaaaa-0000-0000-0000-000000000004'), -- Fantasy
('cccccccc-0000-0000-0000-000000000001','aaaaaaaa-0000-0000-0000-000000000001'), -- Fiction
('cccccccc-0000-0000-0000-000000000002','aaaaaaaa-0000-0000-0000-000000000003'), -- Sci-Fi
('cccccccc-0000-0000-0000-000000000003','aaaaaaaa-0000-0000-0000-000000000005'), -- Romance
('cccccccc-0000-0000-0000-000000000004','aaaaaaaa-0000-0000-0000-000000000001'), -- Fiction
('cccccccc-0000-0000-0000-000000000004','aaaaaaaa-0000-0000-0000-000000000004'), -- Fantasy
('cccccccc-0000-0000-0000-000000000005','aaaaaaaa-0000-0000-0000-000000000004'); -- Fantasy

-- ---------- BOOK_MOOD (max 2 per book; trigger enforces) ----------
insert into book_mood (book_id, mood_id) values
('cccccccc-0000-0000-0000-000000000001','bbbbbbbb-0000-0000-0000-000000000001'), -- Cosy
('cccccccc-0000-0000-0000-000000000001','bbbbbbbb-0000-0000-0000-000000000006'), -- Hopeful
('cccccccc-0000-0000-0000-000000000002','bbbbbbbb-0000-0000-0000-000000000002'), -- Thrilling
('cccccccc-0000-0000-0000-000000000002','bbbbbbbb-0000-0000-0000-000000000003'), -- Adventurous
('cccccccc-0000-0000-0000-000000000003','bbbbbbbb-0000-0000-0000-000000000004'), -- Romantic
('cccccccc-0000-0000-0000-000000000003','bbbbbbbb-0000-0000-0000-000000000001'), -- Cosy
('cccccccc-0000-0000-0000-000000000004','bbbbbbbb-0000-0000-0000-000000000005'), -- Reflective
('cccccccc-0000-0000-0000-000000000004','bbbbbbbb-0000-0000-0000-000000000006'), -- Hopeful
('cccccccc-0000-0000-0000-000000000005','bbbbbbbb-0000-0000-0000-000000000005'); -- Reflective

-- ---------- BOOKSHELF_ENTRY ----------
insert into bookshelf_entry (user_id, book_id, status, start_date, finish_date, is_favorited, personal_rating) values
('11111111-1111-1111-1111-111111111111','cccccccc-0000-0000-0000-000000000001','finished','2025-09-01','2025-09-08', true, 5),
('11111111-1111-1111-1111-111111111111','cccccccc-0000-0000-0000-000000000004','currently_reading','2025-10-20', null, false, null),
('22222222-2222-2222-2222-222222222222','cccccccc-0000-0000-0000-000000000002','finished','2025-08-12','2025-08-22', true, 5),
('22222222-2222-2222-2222-222222222222','cccccccc-0000-0000-0000-000000000005','want_to_read', null, null, false, null),
('33333333-3333-3333-3333-333333333333','cccccccc-0000-0000-0000-000000000003','finished','2025-07-05','2025-07-15', false, 4),
('33333333-3333-3333-3333-333333333333','cccccccc-0000-0000-0000-000000000004','want_to_read', null, null, false, null);

-- ---------- REVIEWS ----------
insert into review (user_id, book_id, star_rating, review_text, is_public) values
('11111111-1111-1111-1111-111111111111','cccccccc-0000-0000-0000-000000000001', 5, 'A quiet, generous book. The kind of story you press into a friend''s hands.', true),
('22222222-2222-2222-2222-222222222222','cccccccc-0000-0000-0000-000000000002', 5, 'Couldn''t put it down. Best sci-fi I''ve read all year.', true),
('33333333-3333-3333-3333-333333333333','cccccccc-0000-0000-0000-000000000003', 4, 'Light but smart. Great vacation read.', true),
('11111111-1111-1111-1111-111111111111','cccccccc-0000-0000-0000-000000000004', 4, 'A premise that earns its emotional payoff.', true);

-- ---------- RECOMMENDATIONS (sample session log) ----------
insert into recommendation (user_id, book_id, mood_id, session_id, status) values
('11111111-1111-1111-1111-111111111111','cccccccc-0000-0000-0000-000000000001','bbbbbbbb-0000-0000-0000-000000000001','sess_demo_001','saved'),
('11111111-1111-1111-1111-111111111111','cccccccc-0000-0000-0000-000000000003','bbbbbbbb-0000-0000-0000-000000000001','sess_demo_001','skipped'),
('22222222-2222-2222-2222-222222222222','cccccccc-0000-0000-0000-000000000002','bbbbbbbb-0000-0000-0000-000000000002','sess_demo_002','saved'),
('33333333-3333-3333-3333-333333333333','cccccccc-0000-0000-0000-000000000004','bbbbbbbb-0000-0000-0000-000000000005','sess_demo_003','shown');
