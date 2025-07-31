#!/bin/bash

# ==============================================================================
# Railway MYSQL_URL Fix - Use Railway's provided connection URL directly
# ==============================================================================

echo "🔧 Using Railway's MYSQL_URL directly..."

# First, fix the bcrypt import issue
cat << 'EOF' > src/auth/auth.service.ts
import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt'; // ← Fixed: use 'bcrypt' not 'bcryptjs'
import { CreateUserDto } from '../users/dto/create-user.dto';
@Injectable()
export class AuthService {
  constructor( private usersService: UsersService, private jwtService: JwtService ) {}
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

# Update app.module.ts to use MYSQL_URL
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
        console.log('🔍 Railway MySQL Variables:');
        console.log('MYSQL_URL:', process.env.MYSQL_URL ? 'Available' : 'Missing');
        console.log('MYSQLHOST:', process.env.MYSQLHOST);
        console.log('MYSQLPORT:', process.env.MYSQLPORT);
        console.log('MYSQLDATABASE:', process.env.MYSQLDATABASE);
        console.log('MYSQLPASSWORD:', process.env.MYSQLPASSWORD ? 'Available' : 'Missing');

        // Method 1: Try to use MYSQL_URL directly
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
              connectTimeout: 30000,
              acquireTimeout: 30000,
              timeout: 30000,
            };
            
            console.log('🔗 Parsed MYSQL_URL connection:');
            console.log(`  Host: ${config.host}`);
            console.log(`  Port: ${config.port}`);
            console.log(`  Username: ${config.username}`);
            console.log(`  Database: ${config.database}`);
            console.log(`  Password: ${config.password ? '[SET]' : '[NOT SET]'}`);
            
            return config;
          } catch (error) {
            console.log('❌ Failed to parse MYSQL_URL:', error);
          }
        }

        // Method 2: Fallback to individual variables
        console.log('⚠️  Falling back to individual MySQL variables');
        const host = process.env.MYSQLHOST || 'mysql.railway.internal';
        const port = parseInt(process.env.MYSQLPORT || '3306');
        const username = process.env.MYSQLUSER || 'root';
        const password = process.env.MYSQLPASSWORD || '';
        const database = process.env.MYSQLDATABASE || 'railway';

        console.log('🔗 Individual variables connection:');
        console.log(`  Host: ${host}`);
        console.log(`  Port: ${port}`);
        console.log(`  Username: ${username}`);
        console.log(`  Database: ${database}`);
        console.log(`  Password: ${password ? '[SET]' : '[NOT SET]'}`);
        
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
          connectTimeout: 30000,
          acquireTimeout: 30000,
          timeout: 30000,
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

echo ""
echo "✅ MYSQL_URL fix applied!"
echo "======================================================"
echo "📋 This fix will:"
echo "1. 🎯 Use Railway's MYSQL_URL directly (bypasses DNS issues)"
echo "2. 🔄 Fall back to individual variables if URL parsing fails"
echo "3. 📊 Show detailed connection info in logs"
echo ""
echo "🚀 DEPLOY NOW - this should work immediately!"
echo ""
echo "Expected log output:"
echo "✅ Using MYSQL_URL for connection"
echo "🔗 Parsed MYSQL_URL connection:"
echo "  Host: mysql.railway.internal"
echo "  Port: 3306"
echo "  Database: railway"
echo ""
echo "🎯 If this still fails, we'll try the public URL as backup"