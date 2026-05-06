#!/usr/bin/env bash
# =============================================================================
# VibeShelf API — smoke test
# Exercises >=3 GET endpoints and >=1 write endpoint.
# Reads BASE_URL from the environment; defaults to http://localhost:3000.
# Exits non-zero on any failure (scriptable for grading).
# =============================================================================
set -e

BASE_URL="${BASE_URL:-http://localhost:3000}"
echo "Smoke testing API at: $BASE_URL"
echo "---------------------------------------------"

pass() { echo "  PASS: $1"; }
fail() { echo "  FAIL: $1"; exit 1; }

# -------- 1. GET /health --------
echo "[1] GET /health"
http_code=$(curl -s -o /tmp/vs_health.json -w "%{http_code}" "$BASE_URL/health")
[ "$http_code" = "200" ] || fail "health returned $http_code"
grep -q '"ok":true' /tmp/vs_health.json || fail "health body missing ok:true"
pass "/health returned 200"

# -------- 2. GET /moods --------
echo "[2] GET /moods"
http_code=$(curl -s -o /tmp/vs_moods.json -w "%{http_code}" "$BASE_URL/moods")
[ "$http_code" = "200" ] || fail "/moods returned $http_code"
grep -q '"name"' /tmp/vs_moods.json || fail "/moods returned no rows"
pass "/moods returned at least one mood"

# -------- 3. GET /genres --------
echo "[3] GET /genres"
http_code=$(curl -s -o /tmp/vs_genres.json -w "%{http_code}" "$BASE_URL/genres")
[ "$http_code" = "200" ] || fail "/genres returned $http_code"
grep -q '"name"' /tmp/vs_genres.json || fail "/genres returned no rows"
pass "/genres returned at least one genre"

# -------- 4. GET /books --------
echo "[4] GET /books"
http_code=$(curl -s -o /tmp/vs_books.json -w "%{http_code}" "$BASE_URL/books")
[ "$http_code" = "200" ] || fail "/books returned $http_code"
grep -q '"title"' /tmp/vs_books.json || fail "/books returned no rows (did seed run?)"
pass "/books returned at least one book"

# -------- 5. POST /auth/signup (write #1) --------
echo "[5] POST /auth/signup"
RAND=$(date +%s)
SIGNUP_BODY=$(cat <<EOF
{"email":"smoke_${RAND}@vibeshelf.app","username":"smoke_${RAND}","password":"smoke1234"}
EOF
)
http_code=$(curl -s -o /tmp/vs_signup.json -w "%{http_code}" \
  -X POST -H "Content-Type: application/json" \
  -d "$SIGNUP_BODY" "$BASE_URL/auth/signup")
[ "$http_code" = "201" ] || fail "/auth/signup returned $http_code (body: $(cat /tmp/vs_signup.json))"
grep -q '"user_id"' /tmp/vs_signup.json || fail "signup did not return user_id"
pass "/auth/signup created a user (201)"

# -------- 6. POST /auth/login (verify the new user) --------
echo "[6] POST /auth/login"
LOGIN_BODY=$(cat <<EOF
{"email":"smoke_${RAND}@vibeshelf.app","password":"smoke1234"}
EOF
)
http_code=$(curl -s -o /tmp/vs_login.json -w "%{http_code}" \
  -X POST -H "Content-Type: application/json" \
  -d "$LOGIN_BODY" "$BASE_URL/auth/login")
[ "$http_code" = "200" ] || fail "/auth/login returned $http_code"
grep -q '"user_id"' /tmp/vs_login.json || fail "login did not return user_id"
pass "/auth/login verified (200)"

# -------- 7. GET /recommend (uses live DB join logic) --------
echo "[7] GET /recommend?mood=Cosy"
http_code=$(curl -s -o /tmp/vs_reco.json -w "%{http_code}" "$BASE_URL/recommend?mood=Cosy")
# Either 200 (book returned) or 404 (no_match) is acceptable; anything else fails
case "$http_code" in
  200) grep -q '"title"' /tmp/vs_reco.json || fail "/recommend 200 but no title in body"
       pass "/recommend returned a book (200)" ;;
  404) pass "/recommend returned no_match (404) — acceptable" ;;
  *)   fail "/recommend returned unexpected $http_code" ;;
esac

# -------- 8. Negative test: bad rating --------
echo "[8] POST /reviews with bad rating (expect 400)"
BAD_REVIEW='{"user_id":"00000000-0000-0000-0000-000000000000","book_id":"00000000-0000-0000-0000-000000000000","star_rating":99}'
http_code=$(curl -s -o /dev/null -w "%{http_code}" \
  -X POST -H "Content-Type: application/json" \
  -d "$BAD_REVIEW" "$BASE_URL/reviews")
[ "$http_code" = "400" ] || fail "expected 400 for invalid rating, got $http_code"
pass "/reviews rejected bad rating with 400"

echo "---------------------------------------------"
echo "ALL TESTS PASSED ✓"
