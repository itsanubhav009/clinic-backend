#!/bin/bash

echo "🔍 Database Connection Troubleshooting for NestJS + MySQL"
echo "========================================================"

# Check if .env file exists and show its contents (without sensitive data)
echo ""
echo "1. Checking .env file configuration:"
echo "===================================="
if [ -f ".env" ]; then
    echo "✅ .env file exists"
    echo ""
    echo "Current .env contents (passwords hidden):"
    while IFS= read -r line; do
        if [[ $line =~ ^[[:space:]]*# ]] || [[ -z "$line" ]]; then
            echo "$line"
        elif [[ $line =~ PASSWORD|MYSQL_URL ]]; then
            key=$(echo "$line" | cut -d'=' -f1)
            echo "$key=***HIDDEN***"
        else
            echo "$line"
        fi
    done < .env
else
    echo "❌ No .env file found!"
    echo "Creating a template .env file..."
    cat > .env << 'EOF'
# Local MySQL Configuration (for testing)
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=password
DB_DATABASE=clinic_db

# Railway MySQL Configuration (get from Railway dashboard)
# MYSQL_URL=mysql://root:password@containers-us-west-xxx.railway.app:6543/railway
# MYSQLHOST=containers-us-west-xxx.railway.app
# MYSQLPORT=6543
# MYSQLUSER=root
# MYSQLPASSWORD=your-railway-password
# MYSQLDATABASE=railway

# JWT Secret
JWT_SECRET=a-very-strong-and-secret-key-for-jwt
EOF
    echo "✅ Created template .env file"
fi

echo ""
echo "2. Testing local MySQL connection:"
echo "=================================="

# Check if MySQL is running locally
if command -v mysql &> /dev/null; then
    echo "✅ MySQL client is installed"
    
    # Try to connect to local MySQL
    echo "Testing local MySQL connection..."
    if mysql -h127.0.0.1 -P3306 -uroot -p"password" -e "SELECT 1;" 2>/dev/null; then
        echo "✅ Local MySQL connection successful"
        
        # Check if database exists
        if mysql -h127.0.0.1 -P3306 -uroot -p"password" -e "USE clinic_db; SELECT 1;" 2>/dev/null; then
            echo "✅ Database 'clinic_db' exists"
        else
            echo "⚠️  Database 'clinic_db' does not exist"
            echo "Creating database..."
            mysql -h127.0.0.1 -P3306 -uroot -p"password" -e "CREATE DATABASE IF NOT EXISTS clinic_db;" 2>/dev/null && echo "✅ Database created" || echo "❌ Failed to create database"
        fi
    else
        echo "❌ Cannot connect to local MySQL"
        echo "   - Check if MySQL server is running: brew services start mysql (macOS) or sudo service mysql start (Linux)"
        echo "   - Verify root password"
        echo "   - Try: mysql -uroot -p"
    fi
else
    echo "❌ MySQL client not installed"
    echo "   Install with: brew install mysql (macOS) or sudo apt install mysql-client (Linux)"
fi

echo ""
echo "3. Network connectivity test:"
echo "============================="

# Test if we can reach common ports
echo "Testing port 3306 (MySQL default)..."
if timeout 3 bash -c "</dev/tcp/127.0.0.1/3306" 2>/dev/null; then
    echo "✅ Port 3306 is open locally"
else
    echo "❌ Port 3306 is not accessible locally"
fi

echo ""
echo "4. Docker MySQL option:"
echo "======================="
echo "If you don't have MySQL installed locally, you can use Docker:"
echo ""
echo "# Pull and run MySQL in Docker:"
echo "docker run --name clinic-mysql -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=clinic_db -p 3306:3306 -d mysql:8.0"
echo ""
echo "# Connect to verify:"
echo "docker exec -it clinic-mysql mysql -uroot -p"

echo ""
echo "5. Railway MySQL setup:"
echo "======================="
echo "If you want to use Railway MySQL:"
echo ""
echo "Option A - Manual setup:"
echo "1. Go to https://railway.app/dashboard"
echo "2. Create new project or open existing"
echo "3. Add MySQL service"
echo "4. Go to Variables tab and copy:"
echo "   - MYSQL_URL"
echo "   - MYSQLHOST, MYSQLPORT, MYSQLUSER, MYSQLPASSWORD, MYSQLDATABASE"
echo "5. Add these to your .env file"
echo ""
echo "Option B - Railway CLI:"
echo "npm install -g @railway/cli"
echo "railway login"
echo "railway link"
echo "railway variables"

echo ""
echo "6. Quick fixes to try:"
echo "====================="
echo ""
echo "Fix 1 - Update app.module.ts to use the Railway-compatible version:"
echo "     - Use the first script (paste.txt) to update your app.module.ts"
echo ""
echo "Fix 2 - Test with local MySQL first:"
echo "     - Install MySQL locally or use Docker"
echo "     - Update .env with local credentials"
echo "     - Run: npm run start:dev"
echo ""
echo "Fix 3 - Check your current app.module.ts TypeORM config:"
echo "     - Make sure it's reading from .env correctly"
echo "     - Add console.log to debug connection params"

echo ""
echo "7. Debug your current connection:"
echo "================================"
echo "Add this debug code to your app.module.ts TypeORM factory:"
echo ""
cat << 'EOF'
useFactory: (configService: ConfigService) => {
  console.log('🔍 Debug - Database Connection Parameters:');
  console.log('DB_HOST:', configService.get('DB_HOST'));
  console.log('DB_PORT:', configService.get('DB_PORT'));
  console.log('DB_USERNAME:', configService.get('DB_USERNAME'));
  console.log('DB_DATABASE:', configService.get('DB_DATABASE'));
  console.log('DB_PASSWORD:', configService.get('DB_PASSWORD') ? 'SET' : 'NOT SET');
  
  return {
    type: 'mysql',
    host: configService.get<string>('DB_HOST'),
    port: parseInt(configService.get('DB_PORT')),
    username: configService.get<string>('DB_USERNAME'),
    password: configService.get<string>('DB_PASSWORD'),
    database: configService.get<string>('DB_DATABASE'),
    entities: [User, Doctor, Appointment, Queue],
    synchronize: true,
  };
},
EOF

echo ""
echo "========================================================"
echo "🎯 Most likely solution:"
echo "1. Install MySQL locally: brew install mysql (macOS)"
echo "2. Start MySQL service: brew services start mysql"
echo "3. Set root password: mysql_secure_installation"
echo "4. Create database: mysql -uroot -p -e 'CREATE DATABASE clinic_db;'"
echo "5. Update .env with correct local credentials"
echo "6. Run: npm run start:dev"
echo "========================================================"