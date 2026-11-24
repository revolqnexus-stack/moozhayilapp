# 🔍 Onboarding Loop Debugging - Logging Changes

## Problem
Users stuck in loop on Intent and Name screens. App calls `POST /user/intent` and `PATCH /user/me` but stays on same screen.

## Changes Made

### 1. ✅ `apps/api/src/modules/users/users.controller.ts`
Added detailed logging to both endpoints:

**PATCH /user/me** (name screen):
- Logs request body
- Logs user ID from auth
- Logs parsed input after validation
- Logs success response

**POST /user/intent** (intent screen):
- Logs request body
- Logs user ID from auth
- Logs parsed input after validation
- Logs success response

### 2. ✅ `apps/api/src/modules/auth/auth.middleware.ts`
Added authentication flow logging:
- Logs if auth header present
- Logs token decode success/failure
- Logs session validation results
- Logs user ID on successful auth
- Logs specific auth failure reasons

### 3. ✅ `apps/api/src/middleware/error.middleware.ts`
Added error logging:
- Logs all caught errors with path, method, error message, stack trace
- Logs AppError details (code, message, details)
- Logs ZodError validation failures with field-level details

---

## How to Deploy

```bash
cd "/Users/ajmal/moozhayil app/moozhayilapp"
git add -A
git commit -m "Add detailed logging for onboarding loop debugging"
git push
```

Render will auto-deploy.

---

## Expected Logs

### Success Case:
```
🔐 Auth middleware - Path: /user/intent Has auth header: true
🔐 Token decoded - user_id: cm123abc session_id: sess_456def
🔐 Auth success - user: cm123abc
🎯 POST /user/intent - Request body: {"intents":["wedding","investment"]}
🎯 POST /user/intent - User ID: cm123abc
🎯 POST /user/intent - Parsed input: {"intents":["wedding","investment"]}
🎯 POST /user/intent - Success: {"intents":["wedding","investment"]}
```

### Auth Failure:
```
🔐 Auth middleware - Path: /user/intent Has auth header: false
🔐 Auth failed: Missing Bearer token
❌ AppError: UNAUTHORIZED Missing access token
```

### Validation Failure:
```
🔐 Auth success - user: cm123abc
🎯 POST /user/intent - Request body: {"intents":[]}
❌ ZodError: {"intents":["Array must contain at least 1 element(s)"]}
```

---

## Testing Instructions

1. Deploy the changes
2. Open app and go through onboarding:
   - Request OTP → Verify OTP
   - Select intent → Tap Continue
   - Enter name → Tap Continue
3. When it loops, check Render logs
4. Copy the logs and share them

The logs will tell us exactly which of these is happening:
- ❌ 401 Unauthorized - access token not being sent/invalid
- ❌ 422 Validation - name too short or intents format wrong
- ❌ 500 Server Error - backend crash

---

## Files Changed
- `apps/api/src/modules/users/users.controller.ts`
- `apps/api/src/modules/auth/auth.middleware.ts`
- `apps/api/src/middleware/error.middleware.ts`
