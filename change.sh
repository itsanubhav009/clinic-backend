#!/bin/bash

echo "🔍 Quick Railway MySQL Debug"
echo "============================="

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Not in a Node.js project directory"
    echo "Make sure you're in your clinic-backend folder"
    exit 1
fi

# Check if Railway CLI is available
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found"
    echo "Install: npm install -g @railway/cli"
    exit 1
fi

# Check Railway login status
if ! railway whoami &> /dev/null; then
    echo "❌ Not logged into Railway"
    echo "Run: railway login"
    exit 1
fi

echo "✅ Railway CLI ready"

# Check current environment variables
echo ""
echo "1. Checking current .env file:"
if [ -f ".env" ]; then
    echo "Current .env contents:"
    cat .env
else
    echo "❌ No .env file found"
fi

echo ""
echo "2. Fetching Railway variables:"
railway variables > railway_vars.txt 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Railway variables fetched"
    echo "MySQL-related variables from Railway:"
    grep -i mysql railway_vars.txt || echo "❌ No MySQL variables found"
else
    echo "❌ Failed to fetch Railway variables"
    echo "Error:"
    cat railway_vars.txt
    echo ""
    echo "Try: railway link (to link to your project)"
fi

echo ""
echo "3. Checking app.module.ts:"
if [ -f "src/app.module.ts" ]; then
    if grep -q "MYSQL_URL" src/app.module.ts; then
        echo "✅ app.module.ts has Railway MySQL logic"
    else
        echo "❌ app.module.ts needs Railway MySQL configuration"
        echo "Apply the fix now? (y/n)"
        read -r apply_fix
        if [[ $apply_fix =~ ^[Yy]$ ]]; then
            echo "Applying fix..."
            # Apply the Railway fix from the first script
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
        };
      },
    }),
    AuthModule, UsersModule, DoctorsModule, AppointmentsModule, QueueModule, SeedModule,
  ],
})
export class AppModule {}
EOF
            echo "✅ Applied Railway MySQL fix to app.module.ts"
        fi
    fi
else
    echo "❌ src/app.module.ts not found"
fi

echo ""
echo "4. Creating .env with Railway variables:"
if [ -f "railway_vars.txt" ]; then
    # Extract variables and create .env
    {
        echo "# Railway MySQL Configuration"
        grep "MYSQL_URL" railway_vars.txt | head -1
        grep "MYSQLHOST" railway_vars.txt | head -1
        grep "MYSQLPORT" railway_vars.txt | head -1
        grep "MYSQLUSER" railway_vars.txt | head -1
        grep "MYSQLPASSWORD" railway_vars.txt | head -1
        grep "MYSQLDATABASE" railway_vars.txt | head -1
        echo ""
        echo "# Application Configuration"
        echo "JWT_SECRET=a-very-strong-and-secret-key-for-jwt"
        echo ""
        echo "# Local Development Fallback"
        echo "DB_HOST=127.0.0.1"
        echo "DB_PORT=3306"
        echo "DB_USERNAME=clinic_admin"
        echo "DB_PASSWORD=password"
        echo "DB_DATABASE=clinic_db"
    } > .env.new
    
    if [ -s .env.new ]; then
        mv .env.new .env
        echo "✅ Created new .env with Railway variables"
        echo "New .env contents:"
        cat .env
    else
        echo "❌ Failed to create .env - no Railway MySQL variables found"
        rm -f .env.new
    fi
fi

# Cleanup
rm -f railway_vars.txt

echo ""
echo "5. Testing connection:"
echo "Run this command to test with Railway variables:"
echo "railway run npm run start:dev"
echo ""
echo "Or test locally with the new .env:"
echo "npm run start:dev"