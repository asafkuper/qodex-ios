# Instagram API Setup for QodeX

## Step 1: Create Meta Developer Account
1. Go to https://developers.facebook.com/
2. Log in with Shani's Facebook account (or create one)
3. Complete developer registration

## Step 2: Create App
1. Click "Create App"
2. Select "Other" → "Consumer"
3. App Name: "QodeX Content Sync"
4. Add Instagram Basic Display product

## Step 3: Configure Instagram Basic Display
1. Go to Products → Instagram Basic Display → Basic Settings
2. Add these OAuth Redirect URIs:
   - `https://qodex.app/auth/instagram/callback`
   - `http://localhost:3000/auth/instagram/callback` (for testing)
3. Add Deauthorize Callback URL: `https://qodex.app/auth/instagram/deauthorize`
4. Add Data Deletion Request URL: `https://qodex.app/auth/instagram/delete`

## Step 4: Add Test User
1. Go to Roles → Instagram Testers
2. Click "Add Instagram Testers"
3. Enter Shani's Instagram handle: `qodex_numerology.il`
4. Shani accepts the invitation via Instagram app:
   - Settings → Apps and Websites → Tester Invites

## Step 5: Get Access Token
```bash
# Authorization URL (opens in browser)
https://api.instagram.com/oauth/authorize
  ?client_id=YOUR_APP_ID
  &redirect_uri=https://qodex.app/auth/instagram/callback
  &scope=user_profile,user_media
  &response_type=code

# Exchange code for token
curl -X POST https://api.instagram.com/oauth/access_token \
  -F client_id=YOUR_APP_ID \
  -F client_secret=YOUR_APP_SECRET \
  -F grant_type=authorization_code \
  -F redirect_uri=https://qodex.app/auth/instagram/callback \
  -F code=AUTHORIZATION_CODE
```

## Step 6: Fetch Profile Data
```bash
# Get user profile
curl "https://graph.instagram.com/me?fields=id,username,account_type,media_count&access_token=ACCESS_TOKEN"

# Get media
curl "https://graph.instagram.com/me/media?fields=id,caption,media_type,media_url,permalink,timestamp&access_token=ACCESS_TOKEN"
```

## Limitations
- Only accesses Shani's own content (not followers/other users)
- Media URLs expire after ~1 hour
- 200 API calls/hour limit
- App must pass review for production use

## Next Steps
1. Create the Meta app
2. Add Shani as tester
3. I can help write the integration code once you have the access token

Need help with any specific step?
