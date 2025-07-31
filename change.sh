#!/bin/bash

# ==============================================================================
# Complete Railway Fix - MySQL + bcrypt + all issues
# ==============================================================================

echo "🔧 Applying complete Railway fix..."

# 1. Fix bcrypt import issue
cat << 'EOF' > src/auth/auth.service.ts
import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { CreateUserDto } from '../users/dto/create-user.dto';

@Injectable()
export class AuthService {
  constructor( 
    private usersService: UsersService, 
    private jwtService: JwtService 
  ) {}

  async signIn(email: string, pass: string): Promise<{ access_token: string }> {
    const user = await this.usersService.findOneByEmail(email);
    if (!user || !(await bcrypt.compare(pass, user.password))) {
      throw new UnauthorizedException('Invalid credentials.');
    }
    const payload = { sub: user.id, email: user.email };
    return { access_token: this.jwtService.sign(payload) };
  }

  async register(createUserDto: CreateUserDto) {
    if (await this.usersService.findOneByEmail(createUserDto.email)) {
      throw new ConflictException('Email already registered');
    }
    const hashedPassword = await bcrypt.hash(createUserDto.password, 10);
    const user = await this.usersService.create({ ...createUserDto, password: hashedPassword });
    const { password, ...result } = user;
    return result;
  }
}
EOF

# 2. Fix app.module.ts with MYSQL_URL support
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
      envFilePath: '.env'
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule], 
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => {
        console.log('🔍 MySQL Connection Variables:');
        console.log('MYSQL_URL:', process.env.MYSQL_URL ? 'Available' : 'Missing');
        console.log('MYSQLHOST:', process.env.MYSQLHOST);
        console.log('MYSQLPORT:', process.env.MYSQLPORT);
        console.log('MYSQLDATABASE:', process.env.MYSQLDATABASE);

        // Use Railway's MYSQL_URL if available
        if (process.env.MYSQL_URL) {
          console.log('✅ Using MYSQL_URL for connection');
          try {
            const url = new URL(process.env.MYSQL_URL);
            const config = {
              type: 'mysql' as const,
              host: url.hostname,
              port: parseInt(url.port) || 3306,
              username: url.username,
              password: url.password,
              database: url.pathname.slice(1), // Remove leading /
              entities: [User, Doctor, Appointment, Queue],
              synchronize: true,
              logging: false,
              extra: {
                charset: 'utf8mb4_unicode_ci',
              },
            };
            
            console.log('🔗 MySQL Connection:');
            console.log(`  Host: ${config.host}`);
            console.log(`  Port: ${config.port}`);
            console.log(`  Database: ${config.database}`);
            
            return config;
          } catch (error) {
            console.log('❌ Failed to parse MYSQL_URL:', error);
          }
        }

        // Fallback to individual variables
        console.log('⚠️  Using individual MySQL variables');
        const host = process.env.MYSQLHOST || 'mysql.railway.internal';
        const port = parseInt(process.env.MYSQLPORT || '3306');
        const username = process.env.MYSQLUSER || 'root';
        const password = process.env.MYSQLPASSWORD || '';
        const database = process.env.MYSQLDATABASE || 'railway';

        console.log('🔗 Fallback connection:', { host, port, database });
        
        return {
          type: 'mysql',
          host,
          port,
          username,
          password,
          database,
          entities: [User, Doctor, Appointment, Queue],
          synchronize: true,
          logging: false,
          extra: {
            charset: 'utf8mb4_unicode_ci',
          },
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

# 3. Ensure correct package.json
cat << 'EOF' > package.json
{
  "name": "clinic-backend",
  "version": "1.0.0",
  "scripts": {
    "build": "nest build",
    "start": "nest start",
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

# 4. Clean railway.json
cat << 'EOF' > railway.json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS"
  }
}
EOF

echo ""
echo "✅ Complete fix applied!"
echo "======================================================"
echo "Fixed issues:"
echo "✅ bcrypt import (was trying to use bcryptjs)"
echo "✅ MySQL connection using MYSQL_URL"
echo "✅ Proper fallback to individual variables"
echo "✅ Clean package.json with correct dependencies"
echo ""
echo "🚀 Deploy now - should build and connect successfully!"
echo ""
echo "Expected logs:"
echo "✅ Using MYSQL_URL for connection"
echo "🔗 MySQL Connection: Host: mysql.railway.internal"
echo ""
echo "Then test with: POST https://your-app.railway.app/seed"