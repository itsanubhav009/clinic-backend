#!/bin/bash

echo "🔧 Applying Railway deployment fixes..."

# Update app.module.ts
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
      useFactory: (configService: ConfigService) => ({
        type: 'mysql', 
        host: configService.get<string>('MYSQLHOST') || configService.get<string>('DB_HOST'),
        port: parseInt(configService.get('MYSQLPORT') || configService.get('DB_PORT')), 
        username: configService.get<string>('MYSQLUSER') || configService.get<string>('DB_USERNAME'),
        password: configService.get<string>('MYSQLPASSWORD') || configService.get<string>('DB_PASSWORD'), 
        database: configService.get<string>('MYSQLDATABASE') || configService.get<string>('DB_DATABASE'),
        entities: [User, Doctor, Appointment, Queue], 
        synchronize: true,
        ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
        connectTimeout: 60000,
      }),
    }),
    AuthModule, UsersModule, DoctorsModule, AppointmentsModule, QueueModule, SeedModule,
  ],
})
export class AppModule {}
EOF

# Update main.ts
cat << 'EOF' > src/main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  const allowedOrigins = process.env.ALLOWED_ORIGINS 
    ? process.env.ALLOWED_ORIGINS.split(',') 
    : ['http://localhost:3001'];
  
  app.enableCors({ 
    origin: allowedOrigins, 
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE', 
    credentials: true 
  });
  
  app.useGlobalPipes(new ValidationPipe({ 
    whitelist: true, 
    forbidNonWhitelisted: true, 
    transform: true 
  }));
  
  const port = process.env.PORT || 3000;
  await app.listen(port, '0.0.0.0');
  console.log(`🚀 Backend is running on: ${await app.getUrl()}`);
}
bootstrap();
EOF

# Create .env.example
cat << 'EOF' > .env.example
# Local Development
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USERNAME=clinic_admin
DB_PASSWORD=password
DB_DATABASE=clinic_db

# Railway Production (automatically provided by Railway)
# MYSQLHOST=<provided-by-railway>
# MYSQLPORT=<provided-by-railway>
# MYSQLUSER=<provided-by-railway>
# MYSQLPASSWORD=<provided-by-railway>
# MYSQLDATABASE=<provided-by-railway>

# Common for both environments
JWT_SECRET=your-very-strong-and-secret-key-for-jwt
NODE_ENV=development

# CORS (for production)
ALLOWED_ORIGINS=http://localhost:3001
EOF

echo "✅ Files updated for Railway deployment!"
echo ""
echo "Next steps:"
echo "1. Commit and push these changes to GitHub"
echo "2. Follow the deployment guide to set up Railway"
echo "3. Don't forget to add environment variables in Railway!"