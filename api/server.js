/**
 * VibeShelf API
 * Express server. Connects to Supabase via service-role key.
 * The browser client must NOT talk to Supabase directly — only through this API.
 */

import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { createClient } from '@supabase/supabase-js';

const PORT = process.env.PORT || 3000;
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
  console.error('Missing SUPABASE_URL or SUPABASE_SERVICE_KEY in environment');
  process.exit(1);
}

const supa = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
  auth: { persistSession: false }
});

const app = express();
app.use(cors());
app.use(express.json({ limit: '5mb' }));

// ---------- helpers ----------
const fail = (res, status, code, detail) =>
  res.status(status).json({ error: code, detail });

const wrap = fn => (req, res) => fn(req, res).catch(err => {
  console.error(err);
  fail(res, 500, 'internal_error', err.message);
});
// =============================================================================
// ADMIN — aggregate stats (role-gated)
// =============================================================================
app.get('/admin/stats/:userId', wrap(async (req, res) => {
  const { userId } = req.params;
  // verify caller is admin
  const { data: user } = await supa.from('app_user').select('is_admin').eq('user_id', userId).maybeSingle();
  if (!user || !user.is_admin) return fail(res, 403, 'forbidden');

  const [users, books, entries, reviews] = await Promise.all([
    supa.from('app_user').select('user_id', { count: 'exact', head: true }),
    supa.from('book').select('book_id', { count: 'exact', head: true }),
    supa.from('bookshelf_entry').select('entry_id', { count: 'exact', head: true }),
    supa.from('review').select('review_id', { count: 'exact', head: true })
  ]);

  res.json({
    users: users.count || 0,
    books: books.count || 0,
    shelf_entries: entries.count || 0,
    reviews: reviews.count || 0
  });
}));
// =============================================================================
// HEALTH
// =============================================================================
app.get('/health', (_req, res) => res.json({ ok: true, ts: new Date().toISOString() }));

// =============================================================================
// AUTH — sign up + log in (prototype hash, Supabase Auth would replace this)
// =============================================================================
import crypto from 'crypto';
const hashPw = pw => crypto.createHash('sha256').update(pw + 'vibeshelf_salt').digest('hex');

app.post('/auth/signup', wrap(async (req, res) => {
  const { email, username, password } = req.body || {};
  if (!email || !username || !password) return fail(res, 400, 'missing_fields');
  if (password.length < 4) return fail(res, 400, 'password_too_short');

  // unique email
  const { data: existing } = await supa.from('app_user').select('user_id').eq('email', email.toLowerCase()).maybeSingle();
  if (existing) return fail(res, 409, 'email_taken');

  // unique username
  const { data: existingU } = await supa.from('profile').select('profile_id').ilike('username', username).maybeSingle();
  if (existingU) return fail(res, 409, 'username_taken');

  // create user
  const { data: user, error: e1 } = await supa.from('app_user').insert({
    email: email.toLowerCase(), password_hash: hashPw(password)
  }).select().single();
  if (e1) return fail(res, 500, 'create_user_failed', e1.message);

  // create profile
  const { error: e2 } = await supa.from('profile').insert({
    user_id: user.user_id, username, bio: ''
  });
  if (e2) return fail(res, 500, 'create_profile_failed', e2.message);

  res.status(201).json({ user_id: user.user_id, email: user.email, username });
}));

app.post('/auth/login', wrap(async (req, res) => {
  const { email, password } = req.body || {};
  if (!email || !password) return fail(res, 400, 'missing_fields');

  const { data: user } = await supa.from('app_user').select('*').eq('email', email.toLowerCase()).maybeSingle();
  if (!user || user.password_hash !== hashPw(password)) return fail(res, 401, 'invalid_credentials');

  const { data: prof } = await supa.from('profile').select('username, bio').eq('user_id', user.user_id).maybeSingle();
  await supa.from('app_user').update({ last_login_at: new Date().toISOString() }).eq('user_id', user.user_id);
res.json({ user_id: user.user_id, email: user.email, username: prof?.username, bio: prof?.bio, is_admin: user.is_admin || false });
}));

// =============================================================================
// MOODS & GENRES — lookup tables
// =============================================================================
app.get('/moods', wrap(async (_req, res) => {
  const { data, error } = await supa.from('mood').select('*').order('name');
  if (error) return fail(res, 500, 'db_error', error.message);
  res.json({ moods: data });
}));

app.get('/genres', wrap(async (_req, res) => {
  const { data, error } = await supa.from('genre').select('*').order('name');
  if (error) return fail(res, 500, 'db_error', error.message);
  res.json({ genres: data });
}));

// =============================================================================
// BOOKS
// =============================================================================
app.get('/books', wrap(async (req, res) => {
  const { mood, genre, q } = req.query;
  let query = supa.from('book').select('*');
  if (q) query = query.or(`title.ilike.%${q}%,author.ilike.%${q}%`);
  const { data: books, error } = await query.order('created_at', { ascending: false });
  if (error) return fail(res, 500, 'db_error', error.message);

  // hydrate moods/genres per book (small data set; fine for prototype)
  const ids = books.map(b => b.book_id);
  let bm = [], bg = [];
  if (ids.length) {
    bm = (await supa.from('book_mood').select('book_id, mood:mood_id(name, mood_id)').in('book_id', ids)).data || [];
    bg = (await supa.from('book_genre').select('book_id, genre:genre_id(name, genre_id)').in('book_id', ids)).data || [];
  }
  let result = books.map(b => ({
    ...b,
    moods: bm.filter(x => x.book_id === b.book_id).map(x => x.mood),
    genres: bg.filter(x => x.book_id === b.book_id).map(x => x.genre)
  }));
  if (mood) result = result.filter(b => b.moods.some(m => m.name.toLowerCase() === mood.toLowerCase()));
  if (genre) result = result.filter(b => b.genres.some(g => g.name.toLowerCase() === genre.toLowerCase()));
  res.json({ books: result });
}));

app.get('/books/:id', wrap(async (req, res) => {
  const { id } = req.params;
  const { data: book, error } = await supa.from('book').select('*').eq('book_id', id).maybeSingle();
  if (error) return fail(res, 500, 'db_error', error.message);
  if (!book) return fail(res, 404, 'not_found');
  const { data: bm } = await supa.from('book_mood').select('mood:mood_id(name, mood_id)').eq('book_id', id);
  const { data: bg } = await supa.from('book_genre').select('genre:genre_id(name, genre_id)').eq('book_id', id);
  res.json({ ...book, moods: (bm||[]).map(x => x.mood), genres: (bg||[]).map(x => x.genre) });
}));

app.post('/books', wrap(async (req, res) => {
  const { title, author, isbn, description, cover_image_url, genre_ids = [], mood_ids = [] } = req.body || {};
  if (!title || !author) return fail(res, 400, 'missing_fields');
  if (mood_ids.length > 2) return fail(res, 400, 'max_2_moods');

  const { data: book, error } = await supa.from('book').insert({
    title, author, isbn: isbn || null, description: description || null, cover_image_url: cover_image_url || null
  }).select().single();
  if (error) return fail(res, 500, 'create_failed', error.message);

  for (const gid of genre_ids) {
    await supa.from('book_genre').insert({ book_id: book.book_id, genre_id: gid });
  }
  for (const mid of mood_ids.slice(0, 2)) {
    await supa.from('book_mood').insert({ book_id: book.book_id, mood_id: mid });
  }
  res.status(201).json(book);
}));

// =============================================================================
// SHELF (BookshelfEntry)
// =============================================================================
app.get('/shelf/:userId', wrap(async (req, res) => {
  const { userId } = req.params;
  const { data, error } = await supa.from('bookshelf_entry')
    .select('*, book:book_id(*)')
    .eq('user_id', userId)
    .order('added_at', { ascending: false });
  if (error) return fail(res, 500, 'db_error', error.message);
  res.json({ entries: data });
}));

app.post('/shelf', wrap(async (req, res) => {
  const { user_id, book_id, status = 'want_to_read' } = req.body || {};
  if (!user_id || !book_id) return fail(res, 400, 'missing_fields');
  const { data, error } = await supa.from('bookshelf_entry').insert({
    user_id, book_id, status
  }).select().single();
  if (error) return fail(res, 500, 'create_failed', error.message);
  res.status(201).json(data);
}));

app.patch('/shelf/:entryId', wrap(async (req, res) => {
  const { entryId } = req.params;
  const allowed = ['status','start_date','finish_date','is_favorited','personal_rating','personal_note'];
  const patch = {};
  for (const k of allowed) if (k in req.body) patch[k] = req.body[k];
  if (Object.keys(patch).length === 0) return fail(res, 400, 'no_fields');
  if (patch.personal_rating != null && (patch.personal_rating < 1 || patch.personal_rating > 5))
    return fail(res, 400, 'rating_out_of_range');
  const { data, error } = await supa.from('bookshelf_entry').update(patch).eq('entry_id', entryId).select().single();
  if (error) return fail(res, 500, 'update_failed', error.message);
  if (!data) return fail(res, 404, 'not_found');
  res.json(data);
}));

app.delete('/shelf/:entryId', wrap(async (req, res) => {
  const { entryId } = req.params;
  const { error } = await supa.from('bookshelf_entry').delete().eq('entry_id', entryId);
  if (error) return fail(res, 500, 'delete_failed', error.message);
  res.json({ ok: true });
}));

// =============================================================================
// REVIEWS
// =============================================================================
app.get('/reviews/:bookId', wrap(async (req, res) => {
  const { bookId } = req.params;
  const { data, error } = await supa.from('review')
    .select('*, profile:user_id(username, bio)')
    .eq('book_id', bookId)
    .eq('is_public', true)
    .order('review_date', { ascending: false });
  if (error) return fail(res, 500, 'db_error', error.message);
  res.json({ reviews: data });
}));

app.post('/reviews', wrap(async (req, res) => {
  const { user_id, book_id, star_rating, review_text, is_public = true } = req.body || {};
  if (!user_id || !book_id || !star_rating) return fail(res, 400, 'missing_fields');
  if (star_rating < 1 || star_rating > 5) return fail(res, 400, 'rating_out_of_range');
  const { data, error } = await supa.from('review').insert({
    user_id, book_id, star_rating, review_text: review_text || null, is_public
  }).select().single();
  if (error) return fail(res, 500, 'create_failed', error.message);
  res.status(201).json(data);
}));

// =============================================================================
// RECOMMENDATIONS
// =============================================================================
app.get('/recommend', wrap(async (req, res) => {
  const { mood, user_id, session_id, exclude } = req.query;
  if (!mood) return fail(res, 400, 'mood_required');

  // find mood id
  const { data: moodRow } = await supa.from('mood').select('mood_id').ilike('name', mood).maybeSingle();
  if (!moodRow) return fail(res, 404, 'mood_not_found');

  // find books with this mood
  const { data: bm } = await supa.from('book_mood').select('book_id').eq('mood_id', moodRow.mood_id);
  let candidateIds = (bm || []).map(x => x.book_id);

  // exclude user's existing shelf
  if (user_id) {
    const { data: shelf } = await supa.from('bookshelf_entry').select('book_id').eq('user_id', user_id);
    const owned = new Set((shelf || []).map(x => x.book_id));
    candidateIds = candidateIds.filter(id => !owned.has(id));
  }
  // exclude session-skipped
  if (exclude) {
    const ex = new Set(exclude.split(','));
    candidateIds = candidateIds.filter(id => !ex.has(id));
  }
  if (candidateIds.length === 0) return fail(res, 404, 'no_match');

  const pick = candidateIds[Math.floor(Math.random() * candidateIds.length)];
  const { data: book } = await supa.from('book').select('*').eq('book_id', pick).maybeSingle();

  // log the recommendation
  if (user_id && session_id) {
    await supa.from('recommendation').insert({
      user_id, book_id: pick, mood_id: moodRow.mood_id, session_id, status: 'shown'
    });
  }
  res.json({ book, mood, pool_size: candidateIds.length });
}));

app.post('/recommend/log', wrap(async (req, res) => {
  const { user_id, book_id, mood_id, session_id, status } = req.body || {};
  if (!user_id || !book_id || !mood_id || !session_id || !status) return fail(res, 400, 'missing_fields');
  if (!['shown','skipped','not_interested','saved'].includes(status)) return fail(res, 400, 'bad_status');
  const { data, error } = await supa.from('recommendation').insert({
    user_id, book_id, mood_id, session_id, status
  }).select().single();
  if (error) return fail(res, 500, 'create_failed', error.message);
  res.status(201).json(data);
}));

// =============================================================================
// PROFILE
// =============================================================================
app.get('/profile/:userId', wrap(async (req, res) => {
  const { userId } = req.params;
  const { data, error } = await supa.from('profile').select('*').eq('user_id', userId).maybeSingle();
  if (error) return fail(res, 500, 'db_error', error.message);
  if (!data) return fail(res, 404, 'not_found');
  res.json(data);
}));

app.patch('/profile/:userId', wrap(async (req, res) => {
  const { userId } = req.params;
  const { username, bio, is_public } = req.body || {};
  const patch = {};
  if (username != null) patch.username = username;
  if (bio != null) patch.bio = bio;
  if (is_public != null) patch.is_public = is_public;
  if (Object.keys(patch).length === 0) return fail(res, 400, 'no_fields');
  const { data, error } = await supa.from('profile').update(patch).eq('user_id', userId).select().single();
  if (error) return fail(res, 500, 'update_failed', error.message);
  res.json(data);
}));

// ---------- start ----------
app.listen(PORT, () => {
  console.log(`VibeShelf API listening on http://localhost:${PORT}`);
});
