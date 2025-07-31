# Railway MySQL Setup Instructions

## 🚨 CRITICAL: You need a MySQL database service in Railway!

### Step 1: Add MySQL Database Service
1. Go to your Railway project dashboard
2. Click the "+" button or "Add Service"
3. Select "Database" → "MySQL"
4. Wait for it to deploy (this creates the database)

### Step 2: Verify Environment Variables
After adding MySQL, Railway auto-creates these variables:
- `MYSQL_URL` (most important)
- `MYSQLHOST`, `MYSQLPORT`, `MYSQLUSER`, `MYSQLPASSWORD`, `MYSQLDATABASE`

Check in your Railway dashboard → Your App Service → Variables tab

### Step 3: Connect Services (if needed)
Make sure your NestJS app and MySQL are in the same Railway project.

### Step 4: Deploy
After adding MySQL service, your app should connect successfully.

## 🔍 Debugging
Your app now has enhanced logging. Look for:
```
🚀 === RAILWAY STARTUP DEBUG ===
🔍 === MYSQL ENVIRONMENT VARIABLES ===
🔍 === TYPEORM CONFIGURATION ===
```

## 🌐 Health Checks
Once running, test these endpoints:
- `GET /health` - Basic app health
- `GET /health/db` - Database connection test

## ❌ Common Issues

### Issue: All MySQL variables are MISSING
**Solution:** Add MySQL database service to your Railway project

### Issue: MYSQL_URL exists but connection fails
**Solution:** Check that MySQL service is running and healthy

### Issue: Works locally but not on Railway
**Solution:** Ensure both services are in the same Railway project
