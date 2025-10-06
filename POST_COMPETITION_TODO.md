# Post-Competition Security Checklist

## ⚠️ IMPORTANT - DO AFTER NASA SPACE APPS COMPETITION ENDS

### 1. Reduce Google Earth Engine API Quota
Current quota is set to **100,000 EECU-seconds/day** for the competition to allow judges to test the backend without hitting limits.

**Steps to reduce quota:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to: APIs & Services → Quotas
3. Find: "Earth Engine compute time (EECU-time) per day in seconds"
4. Change from **100,000** to **50,000** (still above your normal ~40,737 usage)
5. Click Save

This protects you from unexpected costs while maintaining normal functionality.

### 2. Regenerate Google Maps API Key
The API key in `lib/config/secrets.dart` was included in the public repository for judging purposes.

**Steps to regenerate:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to: APIs & Services → Credentials
3. Find the API key: `AIzaSyDcYIdXTj_xk2tG_q69Q--J33ihsC4UxoY`
4. Delete this key
5. Create a new API key
6. Apply the same restrictions:
   - API restrictions: Maps SDK for iOS, Maps SDK for Android, Map Tiles API
   - Application restrictions: None (or add your app package/bundle IDs)
7. Update `lib/config/secrets.dart` with the new key
8. Add `secrets.dart` back to `.gitignore`
9. Run: `git rm --cached lib/config/secrets.dart`
10. Commit the change

### 3. Update .gitignore
Uncomment the line in `.gitignore`:
```
# API Keys and Secrets
secrets.dart  # Uncomment this line
```

### 4. Clean Git History (Optional but Recommended)
If you want to remove the API key from git history completely:
```bash
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch lib/config/secrets.dart" \
  --prune-empty --tag-name-filter cat -- --all

git push origin --force --all
```

**WARNING:** This rewrites git history. Only do this if you're comfortable with the implications.

---

**Date to complete by:** 1 week after NASA Space Apps Challenge ends
**Status:** ⏳ Pending
