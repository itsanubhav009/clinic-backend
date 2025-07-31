#!/bin/bash

echo "🔧 Railway MySQL Connection Troubleshooting Script"
echo "=================================================="

# Step 1: Check if Railway CLI is installed and you're logged in
echo "1. Checking Railway CLI status..."
if command -v railway &> /dev/null; then
    echo "✅ Railway CLI is installed"
    if railway whoami &> /dev/null; then
        echo "✅ Logged into Railway"
    else
        echo "❌ Not logged into Railway CLI"
        echo "Run: railway login"
        exit 1
    fi
else
    echo "❌ Railway CLI not found"
    echo "Install it: npm install -g @railway/cli"
    exit 1
fi

# Step 2: Check current environment variables
echo ""
echo "2. Checking current environment variables..."
echo "Current .env file:"
if [ -f .env ]; then
    cat .env
else
    echo "❌ No .env file found"
fi

echo ""
echo "3. Fetching Railway environment variables..."
railway variables --json > railway_vars.json 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Railway variables fetched successfully"
    echo "Available Railway variables:"
    cat railway_vars.json | jq -r 'to_entries[] | "\(.key)=\(.value)"' | head -20
else
    echo "❌ Failed to fetch Railway variables"
    echo "Make sure you're in the right project directory and linked to Railway"
    echo "Run: railway link"
fi

# Step 4: Create updated .env file with Railway variables
echo ""
echo "4. Creating updated .env file with Railway MySQL variables..."

# Extract MySQL variables from Railway
if [ -f railway_vars.json ]; then
    MYSQL_URL=$(cat railway_vars.json | jq -r '.MYSQL_URL // empty')
    MYSQLHOST=$(cat railway_vars.json | jq -r '.MYSQLHOST // empty')
    MYSQLPORT=$(cat railway_vars.json | jq -r '.MYSQLPORT // empty')
    MYSQLUSER=$(cat railway_vars.json | jq -r '.MYSQLUSER // empty')
    MYSQLPASSWORD=$(cat railway_vars.json | jq -r '.MYSQLPASSWORD // empty')
    MYSQLDATABASE=$(cat railway_vars.json | jq -r '.MYSQLDATABASE // empty')
    
    # Create new .env file
    cat << EOF > .env.railway
# Railway MySQL Configuration
MYSQL_URL=${MYSQL_URL}
MYSQLHOST=${MYSQLHOST}
MYSQLPORT=${MYSQLPORT}
MYSQLUSER=${MYSQLUSER}
MYSQLPASSWORD=${MYSQLPASSWORD}
MYSQLDATABASE=${MYSQLDATABASE}

# Application Configuration
JWT_SECRET=a-very-strong-and-secret-key-for-jwt

# Local Development Fallback (if Railway vars not available)
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USERNAME=clinic_admin
DB_PASSWORD=password
DB_DATABASE=clinic_db
EOF

    echo "✅ Created .env.railway with Railway MySQL configuration"
    echo "Railway MySQL variables found:"
    [ ! -z "$MYSQL_URL" ] && echo "✅ MYSQL_URL: Present"
    [ ! -z "$MYSQLHOST" ] && echo "✅ MYSQLHOST: $MYSQLHOST"
    [ ! -z "$MYSQLPORT" ] && echo "✅ MYSQLPORT: $MYSQLPORT"
    [ ! -z "$MYSQLUSER" ] && echo "✅ MYSQLUSER: $MYSQLUSER"
    [ ! -z "$MYSQLPASSWORD" ] && echo "✅ MYSQLPASSWORD: Present"
    [ ! -z "$MYSQLDATABASE" ] && echo "✅ MYSQLDATABASE: $MYSQLDATABASE"
else
    echo "❌ No Railway variables file found"
fi

# Step 5: Apply the Railway MySQL connection fix
echo ""
echo "5. Applying Railway MySQL connection fix to app.module.ts..."

cat << 'EOF' > src/app.module.ts
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { DoctorsModule } from './doctors/doctors.module';
import { AppointmentsModule } from './appointments/appointments.module';
import { QueueModule } from './queue/queue.module';
import { User } from './users/entities/user.entity';
import { Doctor } from './doctors/entities/doctor.entity';
import { Appointment } from './appointments/entities/appointment.entity';
import { Queue } from './queue/entities/queue.entity';
import { SeedModule } from './seed/seed.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, envFilePath: ['.env.railway', '.env'] }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule], 
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => {
        console.log('🔍 MySQL Connection Variables:');
        console.log('MYSQL_URL:', configService.get('MYSQL_URL') ? 'Present' : 'Missing');
        console.log('MYSQLHOST:', configService.get('MYSQLHOST'));
        console.log('MYSQLPORT:', configService.get('MYSQLPORT'));
        console.log('MYSQLDATABASE:', configService.get('MYSQLDATABASE'));
        console.log('MYSQLUSER:', configService.get('MYSQLUSER'));
        console.log('MYSQLPASSWORD:', configService.get('MYSQLPASSWORD') ? 'Present' : 'Missing');

        // First try: Use MYSQL_URL if available (Railway's preferred method)
        const mysqlUrl = configService.get<string>('MYSQL_URL');
        if (mysqlUrl) {
          console.log('✅ Using MYSQL_URL connection');
          return {
            type: 'mysql',
            url: mysqlUrl,
            entities: [User, Doctor, Appointment, Queue],
            synchronize: true,
            ssl: false,
            connectTimeout: 60000,
            acquireTimeout: 60000,
            timeout: 60000,
            retryAttempts: 3,
            retryDelay: 3000,
          };
        }

        // Second try: Use individual Railway variables
        const host = configService.get<string>('MYSQLHOST');
        const port = parseInt(configService.get('MYSQLPORT')) || 3306;
        const username = configService.get<string>('MYSQLUSER');
        const password = configService.get<string>('MYSQLPASSWORD');
        const database = configService.get<string>('MYSQLDATABASE');

        if (host && username && password && database) {
          console.log('✅ Using individual MySQL variables');
          console.log(`🔗 Connection: { host: '${host}', port: ${port}, database: '${database}', user: '${username}' }`);
          return {
            type: 'mysql',
            host,
            port,
            username,
            password,
            database,
            entities: [User, Doctor, Appointment, Queue],
            synchronize: true,
            ssl: false,
            connectTimeout: 60000,
            acquireTimeout: 60000,
            timeout: 60000,
            retryAttempts: 3,
            retryDelay: 3000,
          };
        }

        // Fallback for local development
        console.log('⚠️ Using fallback local MySQL connection');
        return {
          type: 'mysql',
          host: configService.get<string>('DB_HOST') || 'localhost',
          port: parseInt(configService.get('DB_PORT')) || 3306,
          username: configService.get<string>('DB_USERNAME') || 'root',
          password: configService.get<string>('DB_PASSWORD') || 'password',
          database: configService.get<string>('DB_DATABASE') || 'clinic_db',
          entities: [User, Doctor, Appointment, Queue],
          synchronize: true,
          ssl: false,
          connectTimeout: 60000,
          acquireTimeout: 60000,
          timeout: 60000,
          retryAttempts: 3,
          retryDelay: 3000,
        };
      },
    }),
    AuthModule, UsersModule, DoctorsModule, AppointmentsModule, QueueModule, SeedModule,
  ],
})
export class AppModule {}
EOF

echo "✅ Updated app.module.ts with Railway MySQL connection logic"

# Step 6: Test connection
echo ""
echo "6. Testing the connection..."
echo "Run the following commands to test:"
echo ""
echo "# Start the application:"
echo "npm run start:dev"
echo ""
echo "# Or deploy to Railway:"
echo "railway up"

# Step 7: Cleanup
rm -f railway_vars.json

echo ""
echo "🎯 Next Steps:"
echo "=============="
echo "1. If you haven't linked to Railway yet: railway link"
echo "2. Make sure your Railway MySQL service is running"
echo "3. Copy .env.railway to .env: cp .env.railway .env"
echo "4. Test locally: npm run start:dev"
echo "5. Deploy to Railway: railway up"
echo ""
echo "If connection still fails, check:"
echo "- Railway MySQL service is active and healthy"
echo "- Network connectivity to Railway"
echo "- MySQL version compatibility (ensure using mysql2 driver)"