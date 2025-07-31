#!/bin/bash

echo "🔧 Fixing Railway MySQL connection..."

# 1. Update app.module.ts with proper Railway MySQL connection logic
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
        };
      },
    }),
    AuthModule, UsersModule, DoctorsModule, AppointmentsModule, QueueModule, SeedModule,
  ],
})
export class AppModule {}
EOF

# 2. Update .env with Railway-compatible variables
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

# 3. Update main.ts to use Railway's PORT variable
cat << 'EOF' > src/main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
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

echo ""
echo "✅ Railway MySQL connection fix applied!"
echo "======================================================"
echo "🔧 CHANGES MADE:"
echo "✅ Updated app.module.ts with Railway MySQL detection"
echo "✅ Added support for MYSQL_URL (Railway's preferred method)"
echo "✅ Added fallback to individual MySQL variables"
echo "✅ Updated main.ts to use Railway's PORT variable"
echo "✅ Updated CORS to allow Railway's domain"
echo ""
echo "🚨 IMPORTANT: Railway MySQL Setup"
echo "======================================================"
echo "1. In your Railway project dashboard:"
echo "   - Go to your project"
echo "   - Click '+ New' → 'Database' → 'Add MySQL'"
echo "   - Wait for it to deploy (this creates the database service)"
echo ""
echo "2. The MySQL service will automatically provide these variables:"
echo "   ✅ MYSQL_URL (complete connection string)"
echo "   ✅ MYSQLHOST, MYSQLPORT, MYSQLUSER, MYSQLPASSWORD, MYSQLDATABASE"
echo ""
echo "3. Deploy your backend:"
echo "   git add ."
echo "   git commit -m 'fix: Railway MySQL connection with auto-detection'"
echo "   git push"
echo ""
echo "🔍 DEBUGGING TIPS:"
echo "======================================================"
echo "• Check Railway logs to see which connection method is used"
echo "• The app will log all MySQL environment variables on startup"
echo "• If connection fails, verify MySQL service is running in Railway"
echo ""
echo "Expected log output:"
echo "✅ Using MYSQL_URL connection"
echo "🚀 Backend is running on port: XXXX"