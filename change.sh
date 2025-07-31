#!/bin/bash

echo "🔧 Railway MySQL Service Setup & Debug Fix"

# 1. Create an enhanced main.ts with early debugging
cat << 'EOF' > src/main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  console.log('🚀 === RAILWAY STARTUP DEBUG ===');
  console.log('Node.js version:', process.version);
  console.log('Environment:', process.env.NODE_ENV);
  console.log('Railway environment:', process.env.RAILWAY_ENVIRONMENT);
  console.log('');
  
  console.log('🔍 === MYSQL ENVIRONMENT VARIABLES ===');
  const mysqlEnvVars = [
    'MYSQL_URL',
    'MYSQLHOST', 'MYSQLPORT', 'MYSQLUSER', 'MYSQLPASSWORD', 'MYSQLDATABASE',
    'DB_HOST', 'DB_PORT', 'DB_USER', 'DB_PASSWORD', 'DB_NAME'
  ];
  
  mysqlEnvVars.forEach(key => {
    const value = process.env[key];
    if (value) {
      console.log(`✅ ${key}:`, key.includes('PASSWORD') ? '[HIDDEN]' : value);
    } else {
      console.log(`❌ ${key}: MISSING`);
    }
  });
  
  console.log('');
  console.log('📊 Total environment variables:', Object.keys(process.env).length);
  console.log('');

  const app = await NestFactory.create(AppModule);
  
  const port = process.env.PORT || 3000;
  await app.listen(port);
  
  console.log(`🌐 Application is running on port ${port}`);
}

bootstrap().catch(error => {
  console.error('💥 Bootstrap failed:', error);
  process.exit(1);
});
EOF

# 2. Create a simplified TypeORM config that logs more info
cat << 'EOF' > src/app.module.ts
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { DoctorsModule } from './doctors/doctors.module';
import { AppointmentsModule } from './appointments/appointments.module';
import { QueueModule } from './queue/queue.module';
import { HealthModule } from './health/health.module';
import { User } from './users/entities/user.entity';
import { Doctor } from './doctors/entities/doctor.entity';
import { Appointment } from './appointments/entities/appointment.entity';
import { Queue } from './queue/entities/queue.entity';
import { SeedModule } from './seed/seed.module';

@Module({
  imports: [
    ConfigModule.forRoot({ 
      isGlobal: true, 
      envFilePath: '.env'
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule], 
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => {
        console.log('');
        console.log('🔍 === TYPEORM CONFIGURATION ===');
        
        // Check for Railway MySQL URL first (most reliable)
        if (process.env.MYSQL_URL) {
          console.log('✅ MYSQL_URL detected - parsing...');
          try {
            const url = new URL(process.env.MYSQL_URL);
            const config = {
              type: 'mysql' as const,
              host: url.hostname,
              port: parseInt(url.port) || 3306,
              username: url.username,
              password: url.password,
              database: url.pathname.slice(1),
              entities: [User, Doctor, Appointment, Queue],
              synchronize: true,
              logging: true,
              dropSchema: false,
              extra: {
                charset: 'utf8mb4_unicode_ci',
              },
              retryAttempts: 10,
              retryDelay: 3000,
            };
            
            console.log('🔗 MySQL Connection Config:');
            console.log(`   Host: ${config.host}`);
            console.log(`   Port: ${config.port}`);
            console.log(`   Database: ${config.database}`);
            console.log(`   Username: ${config.username}`);
            console.log('   Password: [HIDDEN]');
            console.log('');
            
            return config;
          } catch (error) {
            console.error('❌ Failed to parse MYSQL_URL:', error.message);
          }
        }

        // Fallback to individual variables
        console.log('⚠️  No MYSQL_URL - trying individual variables...');
        
        const host = process.env.MYSQLHOST || process.env.DB_HOST || 'localhost';
        const port = parseInt(process.env.MYSQLPORT || process.env.DB_PORT || '3306');
        const username = process.env.MYSQLUSER || process.env.DB_USER || 'root';
        const password = process.env.MYSQLPASSWORD || process.env.DB_PASSWORD || '';
        const database = process.env.MYSQLDATABASE || process.env.DB_NAME || 'railway';
        
        console.log('🔗 Fallback MySQL Config:');
        console.log(`   Host: ${host}`);
        console.log(`   Port: ${port}`);
        console.log(`   Database: ${database}`);
        console.log(`   Username: ${username}`);
        console.log('   Password:', password ? '[HIDDEN]' : 'EMPTY');
        console.log('');

        return {
          type: 'mysql' as const,
          host,
          port,
          username,
          password,
          database,
          entities: [User, Doctor, Appointment, Queue],
          synchronize: true,
          logging: true,
          dropSchema: false,
          extra: {
            charset: 'utf8mb4_unicode_ci',
          },
          retryAttempts: 10,
          retryDelay: 3000,
        };
      },
    }),
    AuthModule, 
    UsersModule, 
    DoctorsModule, 
    AppointmentsModule, 
    QueueModule, 
    SeedModule,
    HealthModule,
  ],
})
export class AppModule {}
EOF

# 3. Create Railway setup instructions
cat << 'EOF' > RAILWAY_SETUP.md
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
EOF

# 4. Update package.json to ensure proper start command
cat << 'EOF' > package.json
{
  "name": "clinic-backend",
  "version": "1.0.0",
  "scripts": {
    "build": "nest build",
    "start": "node dist/main",
    "start:dev": "nest start --watch",
    "start:prod": "node dist/main"
  },
  "dependencies": {
    "@nestjs/common": "^10.0.0",
    "@nestjs/config": "^3.2.2",
    "@nestjs/core": "^10.0.0",
    "@nestjs/jwt": "^10.2.0",
    "@nestjs/mapped-types": "^2.0.5",
    "@nestjs/passport": "^10.0.3",
    "@nestjs/platform-express": "^10.0.0",
    "@nestjs/typeorm": "^10.0.2",
    "bcryptjs": "^2.4.3",
    "class-transformer": "^0.5.1",
    "class-validator": "^0.14.1",
    "mysql2": "^3.10.0",
    "passport": "^0.7.0",
    "passport-jwt": "^4.0.1",
    "reflect-metadata": "^0.2.2",
    "rxjs": "^7.8.1",
    "typeorm": "^0.3.20"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.0.0",
    "@types/bcryptjs": "^2.4.6",
    "@types/express": "^4.17.17",
    "@types/node": "^20.3.1",
    "@types/passport-jwt": "^4.0.1",
    "typescript": "^5.1.3"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

echo ""
echo "✅ Railway MySQL Service Setup Complete!"
echo "======================================================"
echo "🔧 CHANGES MADE:"
echo "✅ Enhanced main.ts with early environment variable debugging"
echo "✅ Improved TypeORM config with detailed logging"
echo "✅ Created RAILWAY_SETUP.md with step-by-step instructions"
echo "✅ Updated package.json with correct start command"
echo ""
echo "🚨 CRITICAL: You likely need to add MySQL service to Railway!"
echo ""
echo "📋 NEXT STEPS:"
echo "1. Go to Railway dashboard"
echo "2. Add MySQL database service (+ → Database → MySQL)"
echo "3. Wait for MySQL to deploy"
echo "4. Deploy this updated code:"
echo "   git add ."
echo "   git commit -m 'add comprehensive mysql debugging and setup'"
echo "   git push"
echo ""
echo "🔍 AFTER DEPLOYMENT - Look for these logs:"
echo "✅ 🚀 === RAILWAY STARTUP DEBUG ==="
echo "✅ Environment variables list"
echo "✅ 🔍 === TYPEORM CONFIGURATION ==="
echo "✅ MySQL connection details"
echo ""
echo "🎯 If MYSQL_URL is MISSING, you don't have a MySQL service!"