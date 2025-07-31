#!/bin/bash

echo "🔧 Manual Railway MySQL Fix (No CLI Required)"
echo "=============================================="

# Step 1: Apply the Railway MySQL connection fix to app.module.ts
echo "1. Updating app.module.ts with Railway MySQL connection logic..."

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
    ConfigModule.forRoot({ isGlobal: true, envFilePath: '.env' }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule], 
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => {
        console.log('🔍 MySQL Connection Variables Debug:');
        console.log('MYSQL_URL:', configService.get('MYSQL_URL') ? 'Present' : 'Missing');
        console.log('MYSQLHOST:', configService.get('MYSQLHOST') || 'Missing');
        console.log('MYSQLPORT:', configService.get('MYSQLPORT') || 'Missing');
        console.log('MYSQLDATABASE:', configService.get('MYSQLDATABASE') || 'Missing');
        console.log('MYSQLUSER:', configService.get('MYSQLUSER') || 'Missing');
        console.log('MYSQLPASSWORD:', configService.get('MYSQLPASSWORD') ? 'Present' : 'Missing');
        console.log('DB_HOST (fallback):', configService.get('DB_HOST') || 'Missing');

        // First try: Use MYSQL_URL if available (Railway's preferred method)
        const mysqlUrl = configService.get<string>('MYSQL_URL');
        if (mysqlUrl) {
          console.log('✅ Using MYSQL_URL connection string');
          console.log('Connection URL format:', mysqlUrl.replace(/:[^:]*@/, ':****@')); // Hide password
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
          console.log(`🔗 Connecting to: ${username}@${host}:${port}/${database}`);
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
        const fallbackHost = configService.get<string>('DB_HOST') || 'localhost';
        const fallbackPort = parseInt(configService.get('DB_PORT')) || 3306;
        const fallbackUser = configService.get<string>('DB_USERNAME') || 'root';
        const fallbackDb = configService.get<string>('DB_DATABASE') || 'clinic_db';
        
        console.log(`🔗 Fallback connecting to: ${fallbackUser}@${fallbackHost}:${fallbackPort}/${fallbackDb}`);
        
        return {
          type: 'mysql',
          host: fallbackHost,
          port: fallbackPort,
          username: fallbackUser,
          password: configService.get<string>('DB_PASSWORD') || 'password',
          database: fallbackDb,
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

echo "✅ Updated app.module.ts with enhanced Railway MySQL connection logic"

# Step 2: Create a template .env file for Railway variables
echo ""
echo "2. Creating .env template for Railway variables..."

cat << 'EOF' > .env.template
# ==============================================
# Railway MySQL Configuration
# ==============================================
# Get these values from your Railway dashboard:
# 1. Go to your Railway project
# 2. Click on your MySQL service
# 3. Go to "Variables" tab
# 4. Copy the values below:

MYSQL_URL=mysql://root:password@containers-us-west-xxx.railway.app:6543/railway
MYSQLHOST=containers-us-west-xxx.railway.app
MYSQLPORT=6543
MYSQLUSER=root
MYSQLPASSWORD=your-mysql-password
MYSQLDATABASE=railway

# ==============================================
# Application Configuration
# ==============================================
JWT_SECRET=a-very-strong-and-secret-key-for-jwt

# ==============================================
# Local Development Fallback (for testing)
# ==============================================
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USERNAME=clinic_admin
DB_PASSWORD=password
DB_DATABASE=clinic_db
EOF

echo "✅ Created .env.template with Railway variable placeholders"

# Step 3: Check current .env
echo ""
echo "3. Current .env file status:"
if [ -f ".env" ]; then
    echo "✅ .env file exists"
    echo "Current contents:"
    cat .env
else
    echo "❌ No .env file found"
    echo "Creating basic .env for local testing..."
    cp .env.template .env
fi

echo ""
echo "=========================================="
echo "🎯 NEXT STEPS TO FIX YOUR CONNECTION:"
echo "=========================================="
echo ""
echo "OPTION 1: Get Railway Variables Manually"
echo "1. Go to https://railway.app/dashboard"
echo "2. Open your project"
echo "3. Click on your MySQL service"
echo "4. Go to 'Variables' tab"
echo "5. Copy the MYSQL_* variables"
echo "6. Update your .env file with those values"
echo ""
echo "OPTION 2: Install Railway CLI (Recommended)"
echo "1. npm install -g @railway/cli"
echo "2. railway login"
echo "3. railway link"
echo "4. railway variables > railway-vars.txt"
echo "5. Copy MYSQL_* variables to .env file"
echo ""
echo "OPTION 3: Test Locally First"
echo "1. Install MySQL locally"
echo "2. Create database 'clinic_db'"
echo "3. Update .env with local credentials"
echo "4. Test with: npm run start:dev"
echo ""
echo "=========================================="
echo "After updating .env, run: npm run start:dev"
echo "You should see debug output showing which connection method is being used"
echo "=========================================="