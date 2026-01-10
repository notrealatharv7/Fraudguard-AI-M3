# 🚀 Railway Deployment Guide - FastAPI Fraud Detection Backend

**⚠️ IMPORTANT: This guide contains NO code changes. All instructions are UI-level only.**

---

## 📋 Prerequisites

Before starting, ensure you have:

1. ✅ A **GitHub account** with your code repository
2. ✅ Your code **pushed to GitHub** (repository must be public or connected to Railway)
3. ✅ A **Railway account** (sign up at [railway.app](https://railway.app) - free tier available)
4. ✅ Your `backend/requirements.txt` file exists
5. ✅ Your `ml/model.pkl` file exists and is committed to the repository

---

## 🎯 Step-by-Step Deployment Instructions

### **Step 1: Prepare Your Repository (Verify Structure)**

Your repository should have this structure:

```
Fraudguard-AI/
├── backend/
│   ├── main.py          ← FastAPI application
│   ├── requirements.txt ← Python dependencies
│   └── ml/
│       └── model.pkl    ← ML model file (must be committed to Git)
└── ml/                  ← (Optional: old location, kept for compatibility)
    └── model.pkl
```

**Action:** Verify your repository on GitHub contains these files before proceeding. The model should be in `backend/ml/model.pkl` for Railway deployment.

---

### **Step 2: Create Railway Account & New Project**

1. Go to [railway.app](https://railway.app)
2. Click **"Login"** or **"Start a New Project"**
3. Sign in with **GitHub** (recommended) or email
4. Once logged in, click **"+ New Project"**
5. Select **"Deploy from GitHub repo"**

---

### **Step 3: Connect Your GitHub Repository**

1. Railway will show your GitHub repositories
2. **Search for** or **select** your `Fraudguard-AI` repository
3. Click on the repository to connect it
4. Railway will automatically create a new **service** from your repo

---

### **Step 4: Configure Root Directory**

**This is critical!** Railway needs to know where your backend code is located.

1. In your Railway project dashboard, click on the **service** (usually named after your repo)
2. Click the **"Settings"** tab (gear icon)
3. Scroll down to **"Root Directory"**
4. Click **"Edit"** or the input field
5. Enter: `backend`
6. Click **"Save"** or press Enter

**What this does:** Tells Railway to run commands from the `backend/` folder, where `main.py` and `requirements.txt` are located.

---

### **Step 5: Configure Build Command (Auto-Detection)**

Railway **automatically detects Python** and installs dependencies, but verify:

1. In the same **Settings** tab, scroll to **"Build Command"**
2. **Leave it empty** or ensure it shows:
   ```
   pip install -r requirements.txt
   ```
3. Railway auto-detects `requirements.txt` and runs this automatically

---

### **Step 6: Configure Start Command**

1. In **Settings**, scroll to **"Start Command"**
2. Enter one of these (both work the same):
   ```
   python main.py
   ```
   OR
   ```
   uvicorn main:app --host 0.0.0.0 --port $PORT
   ```

   **Note:** Railway sets `$PORT` automatically. Your code uses port 8000 by default, but Railway will handle port mapping.

3. Click **"Save"**

**Why `0.0.0.0`?** This allows Railway to bind to the correct network interface.

---

### **Step 7: Set Environment Variables (Explanation Service - Optional)**

**If deploying explanation service separately** (recommended for production):

1. In **Settings**, scroll to **"Environment Variables"**
2. Click **"+ New Variable"**
3. **Variable Name:** `EXPLANATION_SERVICE_URL`
4. **Value:** Your explanation service Railway domain (e.g., `https://fraudguard-explanation-service-production.up.railway.app`)
   - **Important:** Use `https://` and don't include `/explain` - the code adds that automatically
   - **No trailing slash**
5. Click **"Add"**

**⚠️ Note:** 
- If you deploy the explanation service separately (see `RAILWAY_DEPLOYMENT_EXPLANATION_SERVICE.md`), set this environment variable **after** the explanation service is deployed.
- If you don't set this variable, predictions will still work but `explanation` will be `null` or show an error message.
- The code defaults to `http://localhost:8081` if not set (for local development).

---

### **Step 8: Verify Model File Location**

Your code looks for the model at:
- First: `ml/model.pkl` (relative to backend/) ← **This will work with new structure**
- Fallback: `../ml/model.pkl` (parent directory - kept for compatibility)

**Action:** Verify in Railway's **"Deployments"** tab logs that the model loads. With root directory set to `backend/`, the model at `backend/ml/model.pkl` will be found at `ml/model.pkl` relative to the working directory.

---

### **Step 9: Deploy**

1. Railway automatically deploys when you connect the repo
2. If not, click **"Deploy"** or **"Redeploy"** in the **"Deployments"** tab
3. Watch the **logs** in real-time to see:
   - Dependencies installing (`pip install -r requirements.txt`)
   - FastAPI starting
   - Model loading message: `[OK] Model loaded successfully from ...`

---

### **Step 10: Get Your Public Domain**

1. After deployment completes (check logs show "API ready to accept requests!"), go to **"Settings"**
2. Scroll to **"Domains"** section
3. Click **"Generate Domain"** (or use an existing one)
4. Railway provides a domain like: `your-app-name-production.up.railway.app`
5. **Copy this domain** - you'll need it for your Flutter app

---

### **Step 11: Verify Deployment**

Test your deployed API:

1. Open your Railway domain in a browser:
   ```
   https://your-app-name-production.up.railway.app/health
   ```

2. You should see:
   ```json
   {
     "status": "healthy",
     "model_loaded": true
   }
   ```

3. Test the root endpoint:
   ```
   https://your-app-name-production.up.railway.app/
   ```

4. View API docs (interactive):
   ```
   https://your-app-name-production.up.railway.app/docs
   ```

---

## 🔍 Troubleshooting: What to Check (NOT Code Fixes)

### ❌ **Deployment Fails / Build Errors**

**Check:**
- ✅ `requirements.txt` exists in `backend/` folder
- ✅ All dependencies in `requirements.txt` are valid (no typos)
- ✅ Root Directory is set to `backend` (not empty, not `/`)
- ✅ Python version: Railway auto-detects, but check logs for compatibility issues

**Don't do:**
- ❌ Don't modify `requirements.txt` without testing locally first
- ❌ Don't change Python version unless absolutely necessary

---

### ❌ **Model Not Found Error**

**Check:**
- ✅ `backend/ml/model.pkl` exists in your GitHub repository (not in `.gitignore`)
- ✅ File size: Large models (>100MB) might cause issues
- ✅ Check Railway logs for the exact path it's trying to access

**Action if model is missing:**
- Ensure model is at `backend/ml/model.pkl` (relative to repository root)
- Commit and push `backend/ml/model.pkl` to GitHub
- Redeploy in Railway

**Don't do:**
- ❌ Don't change `MODEL_PATH` in `main.py`
- ❌ Don't move the model file

---

### ❌ **Application Crashes on Startup**

**Check:**
- ✅ Start Command is correct: `python main.py` or `uvicorn main:app --host 0.0.0.0 --port $PORT`
- ✅ Port binding: Code should use `0.0.0.0` (already set in your code)
- ✅ Dependencies installed successfully (check logs)

**Don't do:**
- ❌ Don't change port numbers in `main.py`
- ❌ Don't modify startup code

---

### ❌ **Health Check Returns `model_loaded: false`**

**Check:**
- ✅ Model file path in logs matches your repo structure
- ✅ Model file is committed to Git (check GitHub web interface)
- ✅ File permissions: Railway should handle this automatically

**Don't do:**
- ❌ Don't modify model loading logic

---

### ❌ **CORS Errors (if accessing from Flutter app)**

**Current code allows all origins** (`allow_origins=["*"]`), so this shouldn't happen.

**If it does:**
- Check Railway domain matches what you're calling from Flutter
- Verify `/health` endpoint works in browser first

**Don't do:**
- ❌ Don't change CORS settings (unless you understand the implications)

---

### ❌ **Explanation Service Not Working**

**The code now uses `EXPLANATION_SERVICE_URL` environment variable** (defaults to `http://localhost:8081` for local dev).

**If explanation service is not working:**
- ✅ Check if `EXPLANATION_SERVICE_URL` environment variable is set in Railway
- ✅ Verify the explanation service is deployed separately (see `RAILWAY_DEPLOYMENT_EXPLANATION_SERVICE.md`)
- ✅ Make sure URL doesn't include `/explain` (code adds it automatically)
- ✅ Verify explanation service `/health` endpoint works
- ✅ Check Railway logs for connection errors

**If you haven't deployed explanation service:**
- Predictions will still work (fraud detection works fine)
- `explanation` field will be `null` or show "AI explanation service is currently unavailable"
- This is expected behavior - main fraud detection still functions

---

## 🔗 Separate Deployment Strategy

**Recommended for Production:** Deploy ML service and Explanation service separately.

1. **Deploy ML Service first** (this guide)
2. **Deploy Explanation Service** (see `RAILWAY_DEPLOYMENT_EXPLANATION_SERVICE.md`)
3. **Set `EXPLANATION_SERVICE_URL`** in ML service after explanation service is deployed
4. **Redeploy ML service** to pick up the environment variable

**Benefits:**
- ✅ Independent scaling
- ✅ Separate resource allocation
- ✅ Can update one without affecting the other
- ✅ Better for production workloads

---

## 📝 Summary Checklist

Before deploying:
- [ ] Repository pushed to GitHub
- [ ] `backend/main.py` exists
- [ ] `backend/requirements.txt` exists
- [ ] `backend/ml/model.pkl` committed to Git
- [ ] **Optional:** Decide if you want to deploy explanation service separately (recommended for production)

Railway configuration:
- [ ] Root Directory = `backend`
- [ ] Start Command = `python main.py` (or uvicorn command)
- [ ] Build Command = (auto-detected, can leave empty)
- [ ] Environment Variables:
  - [ ] `EXPLANATION_SERVICE_URL` = `https://your-explanation-service-domain.up.railway.app` (only if deploying explanation service separately - see `RAILWAY_DEPLOYMENT_EXPLANATION_SERVICE.md`)

After deployment:
- [ ] Deployment completes without errors
- [ ] Logs show "Model loaded successfully"
- [ ] `/health` endpoint returns `{"status": "healthy", "model_loaded": true}`
- [ ] Copy Railway domain for Flutter app

---

## 🎯 Quick Reference Commands (for Railway UI)

**Settings to configure:**
- **Root Directory:** `backend`
- **Start Command:** `python main.py`
- **Build Command:** (leave empty, auto-detected)

**Endpoints to test:**
- Health: `https://your-domain.up.railway.app/health`
- Docs: `https://your-domain.up.railway.app/docs`
- Root: `https://your-domain.up.railway.app/`

---

## 🚫 What NOT to Do

❌ **Don't create Dockerfile** - Railway handles this automatically  
❌ **Don't modify `main.py`** - Code works as-is  
❌ **Don't change port numbers** - Railway handles port mapping  
❌ **Don't create `Procfile`** - Not needed for Python/FastAPI  
❌ **Don't change model path logic** - Fallback paths work correctly  
❌ **Don't modify `requirements.txt`** - Unless you've tested locally first  

---

## ✅ Success Indicators

You'll know deployment succeeded when:

1. ✅ Railway logs show: `[OK] Model loaded successfully from ...`
2. ✅ Railway logs show: `API ready to accept requests!`
3. ✅ `/health` returns `{"status": "healthy", "model_loaded": true}`
4. ✅ `/docs` shows interactive API documentation
5. ✅ `/predict` endpoint accepts POST requests (test via `/docs`)

---

## 📞 Next Steps

After successful deployment:

1. **Update Flutter app** to use your Railway domain instead of `localhost:8000`
2. **Test end-to-end** from Flutter app to Railway backend
3. **Monitor Railway dashboard** for usage and errors
4. **Set up custom domain** (optional, Railway Pro feature)

---

**🎉 That's it! Your FastAPI backend is now live on Railway without any code changes!**
