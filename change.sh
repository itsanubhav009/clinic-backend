#!/bin/bash

# ==============================================================================
# Fixed Railway Deployment Script for NestJS Backend
# ==============================================================================

echo "🔧 Fixing Railway MySQL connection..."

# Update the .env file to use Railway variables
cat << 'EOF' > .env
# Railway will automatically provide these variables, but we can set defaults for local development
DB_HOST=${MYSQLHOST:-127.0.0.1}
DB_PORT=${MYSQLPORT:-3306}
DB_USERNAME=${MYSQLUSER:-clinic_admin}
DB_PASSWORD=${MYSQLPASSWORD:-password}
DB_DATABASE=${MYSQLDATABASE:-clinic_db}
JWT_SECRET=a-very-strong-and-secret-key-for-jwt
EOF

# Update app.module.ts to handle Railway environment variables properly
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
    ConfigModule.forRoot({ 
      isGlobal: true, 
      envFilePath: '.env',
      // Load environment variables from process.env (Railway variables)
      load: [() => ({
        DB_HOST: process.env.MYSQLHOST || process.env.DB_HOST || '127.0.0.1',
        DB_PORT: parseInt(process.env.MYSQLPORT || process.env.DB_PORT || '3306'),
        DB_USERNAME: process.env.MYSQLUSER || process.env.DB_USERNAME || 'root',
        DB_PASSWORD: process.env.MYSQLPASSWORD || process.env.DB_PASSWORD || 'password',
        DB_DATABASE: process.env.MYSQLDATABASE || process.env.DB_DATABASE || 'clinic_db',
        JWT_SECRET: process.env.JWT_SECRET || 'a-very-strong-and-secret-key-for-jwt',
      })]
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule], 
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => {
        console.log('🔗 Connecting to MySQL with:', {
          host: configService.get<string>('DB_HOST'),
          port: configService.get<number>('DB_PORT'),
          username: configService.get<string>('DB_USERNAME'),
          database: configService.get<string>('DB_DATABASE'),
        });
        
        return {
          type: 'mysql',
          host: configService.get<string>('DB_HOST'),
          port: configService.get<number>('DB_PORT'),
          username: configService.get<string>('DB_USERNAME'),
          password: configService.get<string>('DB_PASSWORD'),
          database: configService.get<string>('DB_DATABASE'),
          entities: [User, Doctor, Appointment, Queue],
          synchronize: true, // Set to false in production
          logging: process.env.NODE_ENV !== 'production',
          // Additional MySQL connection options for Railway
          extra: {
            charset: 'utf8mb4_unicode_ci',
          },
          // Retry connection options
          retryAttempts: 3,
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
  ],
})
export class AppModule {}
EOF

# Create a railway.json configuration file
cat << 'EOF' > railway.json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "numReplicas": 1,
    "sleepApplication": false,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
EOF

# Create a Dockerfile for better control (optional but recommended)
cat << 'EOF' > Dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Expose port
EXPOSE 3000

# Set environment to production
ENV NODE_ENV=production

# Start the application
CMD ["npm", "run", "start:prod"]
EOF

# Update package.json with Railway-friendly scripts
cat << 'EOF' > package.json
{
  "name": "clinic-backend",
  "version": "1.0.0",
  "scripts": {
    "build": "nest build",
    "start": "nest start",
    "start:dev": "nest start --watch",
    "start:prod": "node dist/main",
    "railway:deploy": "npm run build && npm run start:prod"
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
    "bcrypt": "^5.1.1",
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
    "@types/bcrypt": "^5.0.2",
    "@types/express": "^4.17.17",
    "@types/node": "^20.3.1",
    "@types/passport-jwt": "^4.0.1",
    "typescript": "^5.1.3"
  }
}
EOF

echo ""
echo "✅ Railway configuration updated!"
echo "======================================================"
echo "📋 Next Steps:"
echo ""
echo "1. 🔄 REDEPLOY your Railway service:"
echo "   - Go to your Railway dashboard"
echo "   - Click 'Deploy' or push changes to trigger redeploy"
echo ""
echo "2. 🔍 VERIFY Railway Environment Variables:"
echo "   - Make sure these variables are set in Railway:"
echo "   - MYSQLHOST, MYSQLPORT, MYSQLUSER, MYSQLPASSWORD, MYSQLDATABASE"
echo ""
echo "3. 🔗 CHECK MySQL Service Connection:"
echo "   - Ensure your MySQL service is running on Railway"
echo "   - Use the private networking: mysql.railway.internal"
echo ""
echo "4. 📝 If still having issues, manually set these in Railway Variables:"
echo "   DB_HOST=mysql.railway.internal"
echo "   DB_PORT=3306"
echo "   (Railway should auto-provide MYSQL* variables)"
echo ""
echo "5. 🎯 Test the connection after redeployment:"
echo "   curl https://your-app.railway.app/seed -X POST"
echo ""
echo "🚨 IMPORTANT: Railway automatically provides MYSQL* variables"
echo "   when you connect a MySQL service. Make sure they're connected!"