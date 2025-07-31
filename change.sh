#!/bin/bash

echo "🔧 Applying complete Railway MySQL connection fix..."

# 1. Update app.module.ts with Railway MySQL connection logic
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

# 2. Update main.ts for Railway deployment
cat << 'EOF' > src/main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Enable CORS for Railway deployment
  app.enableCors({ 
    origin: true, // Allow all origins for Railway deployment
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE', 
    credentials: true 
  });
  
  app.useGlobalPipes(new ValidationPipe({ 
    whitelist: true, 
    forbidNonWhitelisted: true, 
    transform: true 
  }));
  
  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`🚀 Backend is running on port: ${port}`);
}
bootstrap();
EOF

# 3. Update .env with Railway-compatible variables
cat << 'EOF' > .env
# Local Development (fallback)
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USERNAME=clinic_admin
DB_PASSWORD=password
DB_DATABASE=clinic_db

# Railway will automatically provide these:
# MYSQL_URL=mysql://user:password@host:port/database
# MYSQLHOST=<host>
# MYSQLPORT=<port>
# MYSQLUSER=<username>
# MYSQLPASSWORD=<password>
# MYSQLDATABASE=<database>

JWT_SECRET=a-very-strong-and-secret-key-for-jwt
PORT=3000
EOF

# 4. Create Railway-specific package.json build scripts
echo "📦 Updating package.json for Railway..."
# Check if package.json exists and update it
if [ -f "package.json" ]; then
    # Create a temporary file with updated scripts
    cat package.json | sed 's/"start:prod": "node dist\/main"/"start:prod": "node dist\/main",\n    "railway:build": "npm install \&\& npm run build",\n    "railway:start": "npm run start:prod"/' > package.json.tmp
    mv package.json.tmp package.json
fi

# 5. Create Railway deployment configuration
cat << 'EOF' > railway.json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "npm run start:prod",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
EOF

# 6. Create Dockerfile for Railway (optional but recommended)
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

# Start the application
CMD ["npm", "run", "start:prod"]
EOF

# 7. Create .dockerignore
cat << 'EOF' > .dockerignore
node_modules
.git
.gitignore
README.md
.env
.nyc_output
coverage
.docker
.dockerignore
Dockerfile
Dockerfile.dev
.railway
EOF

# 8. Update .gitignore for Railway
cat << 'EOF' > .gitignore
# Dependencies
node_modules/
npm-debug.log*

# Build outputs
dist/
build/

# Environment variables
.env.local
.env.production

# IDE files
.vscode/
.idea/

# OS files
.DS_Store
Thumbs.db

# Railway
.railway/
EOF

echo ""
echo "✅ Complete Railway MySQL fix applied!"
echo "======================================================"
echo "🔧 CHANGES MADE:"
echo "✅ Updated app.module.ts with Railway MySQL auto-detection"
echo "✅ Added connection timeouts for better Railway compatibility"
echo "✅ Updated main.ts to use Railway's PORT variable"
echo "✅ Updated CORS to allow Railway's domains"
echo "✅ Created railway.json for deployment configuration"
echo "✅ Created Dockerfile for containerized deployment"
echo "✅ Updated .gitignore and .dockerignore"
echo ""
echo "🚨 RAILWAY SETUP STEPS:"
echo "======================================================"
echo "1. In your Railway project dashboard:"
echo "   - Go to your project"
echo "   - Click '+ New' → 'Database' → 'Add MySQL'"
echo "   - Wait for it to deploy (this creates the database service)"
echo ""
echo "2. Connect your backend service to the database:"
echo "   - Go to your backend service"
echo "   - Click 'Variables' tab"
echo "   - Click 'Reference' and select your MySQL service"
echo "   - This will automatically add all MySQL variables"
echo ""
echo "3. Deploy your backend:"
echo "   git add ."
echo "   git commit -m 'feat: Railway MySQL connection with auto-detection'"
echo "   git push"
echo ""
echo "🔍 DEBUGGING TIPS:"
echo "======================================================"
echo "• Check Railway deployment logs to see connection method used"
echo "• Expected log: '✅ Using MYSQL_URL connection' or '✅ Using individual MySQL variables'"
echo "• If still failing, check that MySQL service is fully deployed"
echo "• Verify all environment variables are properly set in Railway dashboard"
echo ""
echo "🌐 IMPORTANT NOTES:"
echo "======================================================"
echo "• Railway automatically provides MYSQL_URL and individual MySQL variables"
echo "• The app will try MYSQL_URL first, then fall back to individual variables"
echo "• Local development still uses .env file variables"
echo "• CORS is now configured to work with Railway's domains"