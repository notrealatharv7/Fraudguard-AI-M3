# 🚀 Railway Deployment Guide - Explanation Service (Separate)

**⚠️ IMPORTANT: Deploy this service separately from the ML service.**

---

## 📋 Overview

This guide deploys the **Explanation Service** as a separate Railway service. The main ML service will connect to this service via its public URL.

**Deployment Strategy:**
- **ML Service** → Deploy from `backend/` directory (see `RAILWAY_DEPLOYMENT.md`)
- **Explanation Service** → Deploy from `backend/explanation_service/` directory (this guide)

---

## 📋 Prerequisites

1. ✅ Your repository is pushed to GitHub
2. ✅ `backend/explanation_service/main.py` exists
3. ✅ `backend/explanation_service/requirements.txt` exists
4. ✅ **Note:** This service uses `transformers` and `torch` - deployment may take longer and use more resources

---

## 🎯 Step-by-Step Deployment Instructions

### **Step 1: Create a New Railway Service**

1. Go to your Railway project dashboard
2. Click **"+ New Service"** (or **"+ Add Service"**)
3. Select **"Deploy from GitHub repo"**
4. **Select the SAME repository** (`Fraudguard-AI`)
5. Click on the repository to connect

**Why same repo?** Both services are in the same repository, just different root directories.

---

### **Step 2: Name Your Service**

1. Click on the service name (defaults to repository name)
2. Rename it to something like: **"fraudguard-explanation-service"**
3. Press Enter to save

This helps distinguish it from the ML service.

---

### **Step 3: Configure Root Directory**

**Critical step!** This service has a different root directory than the ML service.

1. Click the **"Settings"** tab (gear icon)
2. Scroll to **"Root Directory"**
3. Click **"Edit"**
4. Enter: `backend/explanation_service`
5. Click **"Save"**

**What this does:** Tells Railway to run commands from `backend/explanation_service/` folder.

---

### **Step 4: Configure Start Command**

1. In **Settings**, scroll to **"Start Command"**
2. Enter:
   ```
   python main.py
   ```
   OR
   ```
   uvicorn main:app --host 0.0.0.0 --port $PORT
   ```

3. Click **"Save"**

---

### **Step 5: Configure Resources (Optional but Recommended)**

**Note:** This service uses `transformers` and `torch`, which are memory-intensive.

1. In **Settings**, scroll to **"Resources"**
2. If on Railway Pro, increase memory allocation (recommended: 2GB+)
3. On free tier, Railway auto-allocates (may be slow on first request)

---

### **Step 6: Deploy**

1. Railway will automatically start deploying
2. Watch the **"Deployments"** tab logs
3. You'll see:
   - Dependencies installing (`pip install transformers torch fastapi uvicorn`)
   - **First-time model download** from Hugging Face (this can take 5-10 minutes)
   - FastAPI starting
   - `distilgpt2` model loading

**⚠️ Warning:** First deployment will be slow due to model download (~500MB). Subsequent deployments are faster.

---

### **Step 7: Get Your Public Domain**

1. After deployment completes, go to **"Settings"**
2. Scroll to **"Domains"** section
3. Click **"Generate Domain"**
4. Railway provides a domain like: `fraudguard-explanation-service-production.up.railway.app`
5. **Copy this domain** - you'll need it for the ML service configuration

---

### **Step 8: Verify Explanation Service**

Test your deployed service:

1. Open your Railway domain in a browser:
   ```
   https://fraudguard-explanation-service-production.up.railway.app/health
   ```

2. You should see:
   ```json
   {
     "status": "ok"
   }
   ```

3. View API docs:
   ```
   https://fraudguard-explanation-service-production.up.railway.app/docs
   ```

---

### **Step 9: Update ML Service Environment Variable**

Now that the Explanation Service is deployed, you need to tell the ML service where to find it:

1. Go back to your **ML service** in Railway (the one deployed from `backend/` directory)
2. Click **"Settings"** tab
3. Scroll to **"Environment Variables"**
4. Click **"+ New Variable"**
5. **Variable Name:** `EXPLANATION_SERVICE_URL`
6. **Value:** `https://fraudguard-explanation-service-production.up.railway.app`
   - **Important:** Use `https://` and don't include `/explain` - the code adds that automatically
7. Click **"Add"**

---

### **Step 10: Redeploy ML Service**

After adding the environment variable:

1. Go to ML service **"Deployments"** tab
2. Click **"Redeploy"** (or trigger a new deployment)
3. This will pick up the new `EXPLANATION_SERVICE_URL` environment variable

---

## 🔍 Troubleshooting: Explanation Service

### ❌ **Build Fails / Out of Memory**

**Check:**
- ✅ `requirements.txt` exists in `backend/explanation_service/`
- ✅ Railway has enough resources (free tier may struggle with torch)
- ✅ Root Directory is set to `backend/explanation_service`

**Solution:**
- Upgrade to Railway Pro for more resources, OR
- Consider using a smaller model in `main.py` (e.g., use rule-based explanations instead)

---

### ❌ **Model Download Takes Forever / Times Out**

**Check:**
- ✅ Internet connection in Railway build environment
- ✅ Hugging Face is accessible (may be blocked in some regions)

**Solution:**
- Be patient - first deployment downloads ~500MB model
- If it consistently fails, consider hosting model externally or using a smaller model

---

### ❌ **Service Works But ML Service Can't Connect**

**Check:**
- ✅ Explanation service `/health` endpoint works
- ✅ ML service has `EXPLANATION_SERVICE_URL` set correctly (without `/explain`)
- ✅ Both services are deployed and running

**Common mistake:**
- ❌ Setting `EXPLANATION_SERVICE_URL` to `http://localhost:8081` (won't work in production)
- ❌ Including `/explain` in the URL (code adds it automatically)

---

### ❌ **Explanation Requests Time Out**

**Check:**
- ✅ Explanation service logs show it's receiving requests
- ✅ Model is loaded (check startup logs)
- ✅ Service has enough resources

**Note:** Generation can take 10-30 seconds on free tier. This is normal behavior.

---

## 📝 Summary Checklist

Before deploying Explanation Service:
- [ ] Repository pushed to GitHub
- [ ] `backend/explanation_service/main.py` exists
- [ ] `backend/explanation_service/requirements.txt` exists

Railway Configuration:
- [ ] Create NEW service (separate from ML service)
- [ ] Root Directory = `backend/explanation_service`
- [ ] Start Command = `python main.py`
- [ ] Generate domain and copy URL

After Explanation Service Deployment:
- [ ] `/health` returns `{"status": "ok"}`
- [ ] Copy Railway domain URL

ML Service Configuration:
- [ ] Set `EXPLANATION_SERVICE_URL` environment variable in ML service
- [ ] Value = `https://your-explanation-service-domain.up.railway.app` (no trailing slash, no `/explain`)
- [ ] Redeploy ML service
- [ ] Test end-to-end: ML service → Explanation service

---

## 🎯 Quick Reference

**Explanation Service Settings:**
- **Root Directory:** `backend/explanation_service`
- **Start Command:** `python main.py`
- **Domain:** `https://fraudguard-explanation-service-production.up.railway.app`

**ML Service Environment Variable:**
- **Variable:** `EXPLANATION_SERVICE_URL`
- **Value:** `https://fraudguard-explanation-service-production.up.railway.app`

**Endpoints to Test:**
- Health: `https://your-domain.up.railway.app/health`
- Docs: `https://your-domain.up.railway.app/docs`
- Explain: `https://your-domain.up.railway.app/explain` (POST)

---

## 🚫 What NOT to Do

❌ **Don't deploy explanation service from `backend/` root** - use `backend/explanation_service/`  
❌ **Don't set `EXPLANATION_SERVICE_URL` to localhost** - use the Railway domain  
❌ **Don't include `/explain` in the URL** - the code adds it automatically  
❌ **Don't share the same Railway service** - deploy as separate services  

---

## ✅ Success Indicators

You'll know deployment succeeded when:

1. ✅ Explanation service logs show: `distilgpt2` model loaded
2. ✅ `/health` returns `{"status": "ok"}`
3. ✅ ML service has `EXPLANATION_SERVICE_URL` environment variable set
4. ✅ ML service `/predict` endpoint returns explanations (not null)
5. ✅ Both services show as "Active" in Railway dashboard

---

## 📊 Expected Behavior

**Without Explanation Service (or if URL not set):**
- `/predict` still works
- `fraud` and `risk_score` are returned
- `explanation` field will be `null` or show error message

**With Explanation Service Connected:**
- `/predict` works with full explanation
- `explanation` field contains human-readable explanation
- First request may be slow (10-30 seconds) as model generates text

---

**🎉 That's it! Your Explanation Service is now deployed separately and connected to your ML service!**
