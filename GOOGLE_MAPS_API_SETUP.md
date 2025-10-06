# Google Maps API Key Restriction Guide

## Securing Your API Key for Public Repository

Even though your API key is in a public repository for NASA Space Apps judging, you can restrict it to prevent abuse.

### Steps to Restrict Your API Key:

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/
   - Navigate to: **APIs & Services → Credentials**

2. **Find Your API Key**
   - Look for: `AIzaSyDcYIdXTj_xk2tG_q69Q--J33ihsC4UxoY`
   - Click on it to edit

3. **Set Application Restrictions**

   **For Android:**
   - Select: "Android apps"
   - Add your package name: `com.example.nasa_sar_app` (or whatever your package name is)
   - Add your SHA-1 certificate fingerprint

   **For iOS:**
   - Select: "iOS apps"
   - Add your bundle identifier: `com.example.nasaSarApp` (or whatever your bundle ID is)

   **For Testing/Judging:**
   - You can temporarily set to "None" for easier judging
   - Or add multiple app restrictions (Android + iOS)

4. **Set API Restrictions**
   - Click "Restrict key"
   - Select: "Maps SDK for Android" and "Maps SDK for iOS"
   - This prevents the key from being used for other Google services

5. **Set Usage Quotas (Optional but Recommended)**
   - Go to: APIs & Services → Maps SDK for Android/iOS
   - Set quotas to reasonable limits (e.g., 10,000 requests/day)
   - This prevents runaway costs if someone abuses your key

### What This Means:

✅ **Key can be public** - It won't work outside your app
✅ **Judges can use it** - It works when they run your Flutter app
✅ **Limited abuse potential** - Restricted to Maps SDK only
✅ **Cost protection** - Usage quotas prevent surprise bills

### Current Status:

- [ ] API restrictions applied
- [ ] Application restrictions set
- [ ] Usage quotas configured

### After Competition:

Still recommended to regenerate the key and remove from repository, but restrictions make it safe for public repos during judging.
