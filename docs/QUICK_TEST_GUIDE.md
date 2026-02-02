# Quick Start Guide for Testing MetaMask Wallet Authentication

## 🚀 Quick Test (Easiest Method)

### Option 1: Use the Batch Script
```bash
# Double-click this file or run in terminal:
test-wallet-auth.bat
```

This will:
1. Start the backend (if not running)
2. Start the frontend in Chrome
3. Show you instructions

### Option 2: Manual Testing

**Terminal 1 - Backend:**
```bash
cd backend
go run ./cmd/cognify
```

**Terminal 2 - Frontend:**
```bash
cd frontend
flutter run -d chrome
```

**Terminal 3 - Test Backend APIs (Optional):**
```bash
# PowerShell
.\test-wallet-backend.ps1

# Or Go
cd backend
go run scripts/test_wallet_api.go
```

---

## 📱 Frontend Testing Steps

1. **Find the Test Button**
   - The login screen now has a **purple "Test MetaMask Authentication"** button
   - It's below the instructor login link

2. **Click "Connect Wallet"**
   - MetaMask popup will appear
   - Select your account
   - Click "Connect"

3. **Enter Your Details**
   - Enter your name
   - Optionally enter email
   - Click "Sign In"

4. **Sign the Message**
   - MetaMask will ask you to sign a message
   - Click "Sign" (it's free, no gas required)

5. **Success!**
   - You'll be redirected to the dashboard
   - Check backend terminal for logs

---

## 🔍 What to Look For

### ✅ Success Indicators

**Frontend:**
- MetaMask popup appears
- Wallet address shows after connection (e.g., `0x1234...5678`)
- No errors in browser console (F12)
- Redirects to dashboard after signing

**Backend Terminal:**
```
✅ New user created: 0x742d35cc6634c0532925a3b844bc9e7595f0beb
```
or
```
✅ User logged in: 0x742d35cc6634c0532925a3b844bc9e7595f0beb
```

### ❌ Common Issues

**"MetaMask is not installed"**
- Install MetaMask extension
- Refresh the page

**MetaMask doesn't open**
- Make sure MetaMask is unlocked
- Check browser console (F12) for errors
- Try running in Chrome (not Edge)

**"Signature verification failed"**
- This is a backend issue
- Check backend logs for details
- Make sure backend is running

---

## 🧪 Backend API Testing

### Test All Endpoints
```powershell
# PowerShell
.\test-wallet-backend.ps1
```

### Test Individual Endpoints
```bash
# Get user profile
curl http://localhost:8080/api/user/0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb

# Get certificate history
curl "http://localhost:8080/api/certificate/history/0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb?wallet=0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"

# Get verification stats
curl http://localhost:8080/api/verify/stats
```

---

## 🐛 Debugging

### Enable Browser Console
1. Press **F12** in Chrome
2. Go to **Console** tab
3. Watch for errors when clicking buttons

### Check Backend Logs
Watch the terminal where you ran `go run ./cmd/cognify`

Look for:
- `✅ User created/logged in` - Success
- `Signature verification error` - Check MetaMask signature
- `Database error` - Check Firebase config

### Common Fixes

**CORS Error:**
- Backend needs to allow frontend origin
- Check if backend is running on port 8080

**"Cannot read property 'ethereum'":**
- MetaMask not installed
- Not running on web (must use Chrome)

**Signature Always Fails:**
- Check that message format matches exactly
- Ensure wallet address is lowercase in backend

---

## 📝 Next Steps After Testing

1. **Deploy Smart Contract**
   ```bash
   cd blockchain
   npm install
   npm run deploy:mumbai
   ```

2. **Update Backend Config**
   - Add contract address to `.env`
   - Set `BLOCKCHAIN_MODE=real`

3. **Test Certificate Generation**
   - Generate a certificate
   - Verify on PolygonScan

---

## 📞 Need Help?

Check these files:
- Full testing guide: `testing_guide.md`
- Implementation details: `walkthrough.md`
- Backend logs: Terminal where backend is running
- Frontend logs: Browser console (F12)
