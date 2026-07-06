# 🚀 Vercel Deployment Guide for DUalert

## **QUICK SETUP (5 minutes)**

### **1. Install Vercel CLI**
```bash
npm install -g vercel
```

### **2. Login to Vercel**
```bash
vercel login
```
→ Opens browser to authenticate. Follow prompts.

### **3. Deploy Now**
```bash
vercel --prod
```

**When prompted:**
- Project name: `dualert`
- Project root: `.` (current directory)
- Build command: (leave blank, just press Enter)
- Output directory: `build/web`
- Development command: (leave blank, just press Enter)

✅ **Your app is now live!** You'll get a URL like `https://dualert.vercel.app`

---

## **IF IT'S NOT LOADING - FIX IT IMMEDIATELY**

### **Issue: Blank page or 404 errors**

Run this:
```bash
vercel env add PUBLIC_FIREBASE_API_KEY AIzaSyAUpo20fVUtybs0RW-nvlHPXbJYFaa60yc
vercel env add PUBLIC_FIREBASE_PROJECT_ID avotek-4e8e3
vercel env add PUBLIC_FIREBASE_AUTH_DOMAIN avotek-4e8e3.firebaseapp.com
```

Then redeploy:
```bash
vercel --prod
```

---

## **ALTERNATIVE: Git Auto-Deploy (Recommended)**

### **Step 1: Push to GitHub**
```bash
git add .
git commit -m "Web build ready for Vercel"
git push origin main
```

### **Step 2: Connect to Vercel**
1. Go to [vercel.com](https://vercel.com)
2. Click **"New Project"**
3. Select your GitHub repo (`DUalert`)
4. Set **Output Directory** to `build/web`
5. Click **Deploy**

✅ **Auto-deploys on every push!**

---

## **VERIFY DEPLOYMENT CHECKLIST**

- [ ] App loads without blank page
- [ ] Navigation works (click buttons)
- [ ] Firebase auth loads (sign in/sign up works)
- [ ] Maps display (if applicable)
- [ ] No console errors (F12 → Console tab)

---

## **DEBUGGING IN BROWSER**

1. Open your deployed URL
2. Press `F12` (Developer Tools)
3. Go to **Console** tab
4. Look for red errors
5. Common issues:
   - `Firebase not initialized` → Add env variables (see above)
   - `CORS error` → Firebase security rules issue
   - `404 on resources` → Vercel caching issue (hard refresh: Ctrl+Shift+R)

---

## **Quick Commands Reference**

```bash
# Check deployment status
vercel status

# View logs
vercel logs

# Redeploy latest
vercel --prod

# List all deployments
vercel list
```

---

**Done! Your app is live on Vercel.** 🎉
