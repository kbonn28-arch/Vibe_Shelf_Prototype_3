@echo off
REM ============================================================================
REM VibeShelf API - smoke test (Windows)
REM Exits non-zero on any failure.
REM ============================================================================
setlocal enabledelayedexpansion

if "%BASE_URL%"=="" set BASE_URL=http://localhost:3000
echo Smoke testing API at: %BASE_URL%
echo ---------------------------------------------

REM -------- 1. GET /health --------
echo [1] GET /health
for /f %%i in ('curl -s -o nul -w "%%{http_code}" %BASE_URL%/health') do set CODE=%%i
if not "%CODE%"=="200" ( echo FAIL /health %CODE% & exit /b 1 )
echo   PASS

REM -------- 2. GET /moods --------
echo [2] GET /moods
for /f %%i in ('curl -s -o nul -w "%%{http_code}" %BASE_URL%/moods') do set CODE=%%i
if not "%CODE%"=="200" ( echo FAIL /moods %CODE% & exit /b 1 )
echo   PASS

REM -------- 3. GET /genres --------
echo [3] GET /genres
for /f %%i in ('curl -s -o nul -w "%%{http_code}" %BASE_URL%/genres') do set CODE=%%i
if not "%CODE%"=="200" ( echo FAIL /genres %CODE% & exit /b 1 )
echo   PASS

REM -------- 4. GET /books --------
echo [4] GET /books
for /f %%i in ('curl -s -o nul -w "%%{http_code}" %BASE_URL%/books') do set CODE=%%i
if not "%CODE%"=="200" ( echo FAIL /books %CODE% & exit /b 1 )
echo   PASS

REM -------- 5. POST /auth/signup --------
echo [5] POST /auth/signup
set RAND=%RANDOM%%RANDOM%
set BODY={"email":"smoke_!RAND!@vibeshelf.app","username":"smoke_!RAND!","password":"smoke1234"}
for /f %%i in ('curl -s -o nul -w "%%{http_code}" -X POST -H "Content-Type: application/json" -d "!BODY!" %BASE_URL%/auth/signup') do set CODE=%%i
if not "%CODE%"=="201" ( echo FAIL /auth/signup %CODE% & exit /b 1 )
echo   PASS

REM -------- 6. POST /auth/login --------
echo [6] POST /auth/login
set LBODY={"email":"smoke_!RAND!@vibeshelf.app","password":"smoke1234"}
for /f %%i in ('curl -s -o nul -w "%%{http_code}" -X POST -H "Content-Type: application/json" -d "!LBODY!" %BASE_URL%/auth/login') do set CODE=%%i
if not "%CODE%"=="200" ( echo FAIL /auth/login %CODE% & exit /b 1 )
echo   PASS

REM -------- 7. GET /recommend --------
echo [7] GET /recommend?mood=Cosy
for /f %%i in ('curl -s -o nul -w "%%{http_code}" "%BASE_URL%/recommend?mood=Cosy"') do set CODE=%%i
if "%CODE%"=="200" ( echo   PASS ) else if "%CODE%"=="404" ( echo   PASS-404 ) else ( echo FAIL /recommend %CODE% & exit /b 1 )

echo ---------------------------------------------
echo ALL TESTS PASSED
endlocal
