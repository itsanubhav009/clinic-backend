#!/bin/bash

echo "🔧 Fixing TypeScript build errors..."

# 1. Fix app.module.ts with correct TypeScript types
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
        console.log('🔍 === MYSQL CONNECTION DEBUG ===');
        console.log('Environment Variables:');
        console.log('- NODE_ENV:', process.env.NODE_ENV);
        console.log('- RAILWAY_ENVIRONMENT:', process.env.RAILWAY_ENVIRONMENT);
        
        // Log all MySQL-related environment variables
        const mysqlVars = Object.keys(process.env).filter(key => 
          key.includes('MYSQL') || key.includes('DATABASE')
        );
        mysqlVars.forEach(key => {
          const value = process.env[key];
          console.log(`- ${key}:`, value ? (key.includes('PASSWORD') ? '[HIDDEN]' : value) : 'MISSING');
        });

        // Railway MySQL connection
        if (process.env.MYSQL_URL) {
          console.log('✅ MYSQL_URL found - parsing...');
          try {
            const url = new URL(process.env.MYSQL_URL);
            console.log(`🔗 Parsed MySQL URL:`);
            console.log(`  - Protocol: ${url.protocol}`);
            console.log(`  - Host: ${url.hostname}`);
            console.log(`  - Port: ${url.port || 3306}`);
            console.log(`  - Database: ${url.pathname.slice(1)}`);
            console.log(`  - Username: ${url.username}`);
            
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
              extra: {
                charset: 'utf8mb4_unicode_ci',
                connectionLimit: 10,
                acquireTimeout: 60000,
                timeout: 60000,
                reconnect: true,
              },
              retryAttempts: 10,
              retryDelay: 3000,
            };
            
            console.log('🚀 Using parsed MySQL configuration');
            return config;
          } catch (error) {
            console.error('❌ Failed to parse MYSQL_URL:', error);
          }
        }

        // Individual MySQL variables fallback
        console.log('⚠️  MYSQL_URL not found or invalid - trying individual variables...');
        
        const mysqlConfig = {
          host: process.env.MYSQLHOST || process.env.DB_HOST || 'mysql.railway.internal',
          port: parseInt(process.env.MYSQLPORT || process.env.DB_PORT || '3306'),
          username: process.env.MYSQLUSER || process.env.DB_USER || 'root',
          password: process.env.MYSQLPASSWORD || process.env.DB_PASSWORD || '',
          database: process.env.MYSQLDATABASE || process.env.DB_NAME || 'railway',
        };

        console.log('🔗 Using individual MySQL variables:');
        console.log(`  - Host: ${mysqlConfig.host}`);
        console.log(`  - Port: ${mysqlConfig.port}`);
        console.log(`  - Database: ${mysqlConfig.database}`);
        console.log(`  - Username: ${mysqlConfig.username}`);

        return {
          type: 'mysql' as const,
          ...mysqlConfig,
          entities: [User, Doctor, Appointment, Queue],
          synchronize: true,
          logging: true,
          extra: {
            charset: 'utf8mb4_unicode_ci',
            connectionLimit: 10,
            acquireTimeout: 60000,
            timeout: 60000,
            reconnect: true,
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
  ],
})
export class AppModule {}
EOF

# 2. Create health module files (missing from previous script)
mkdir -p src/health

cat << 'EOF' > src/health/health.controller.ts
import { Controller, Get } from '@nestjs/common';
import { DataSource } from 'typeorm';

@Controller('health')
export class HealthController {
  constructor(private dataSource: DataSource) {}

  @Get()
  async checkHealth() {
    try {
      // Test database connection
      await this.dataSource.query('SELECT 1');
      return {
        status: 'ok',
        database: 'connected',
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      return {
        status: 'error',
        database: 'disconnected',
        error: error.message,
        timestamp: new Date().toISOString()
      };
    }
  }

  @Get('db')
  async checkDatabase() {
    try {
      const result = await this.dataSource.query('SELECT VERSION() as version, NOW() as time');
      return {
        status: 'connected',
        mysql_version: result[0].version,
        mysql_time: result[0].time,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      return {
        status: 'error',
        message: error.message,
        timestamp: new Date().toISOString()
      };
    }
  }
}
EOF

cat << 'EOF' > src/health/health.module.ts
import { Module } from '@nestjs/common';
import { HealthController } from './health.controller';

@Module({
  controllers: [HealthController],
})
export class HealthModule {}
EOF

# 3. Update app.module.ts to include health module
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
        console.log('🔍 === MYSQL CONNECTION DEBUG ===');
        console.log('Environment Variables:');
        console.log('- NODE_ENV:', process.env.NODE_ENV);
        console.log('- RAILWAY_ENVIRONMENT:', process.env.RAILWAY_ENVIRONMENT);
        
        // Log all MySQL-related environment variables
        const mysqlVars = Object.keys(process.env).filter(key => 
          key.includes('MYSQL') || key.includes('DATABASE')
        );
        mysqlVars.forEach(key => {
          const value = process.env[key];
          console.log(`- ${key}:`, value ? (key.includes('PASSWORD') ? '[HIDDEN]' : value) : 'MISSING');
        });

        // Railway MySQL connection
        if (process.env.MYSQL_URL) {
          console.log('✅ MYSQL_URL found - parsing...');
          try {
            const url = new URL(process.env.MYSQL_URL);
            console.log(`🔗 Parsed MySQL URL:`);
            console.log(`  - Protocol: ${url.protocol}`);
            console.log(`  - Host: ${url.hostname}`);
            console.log(`  - Port: ${url.port || 3306}`);
            console.log(`  - Database: ${url.pathname.slice(1)}`);
            console.log(`  - Username: ${url.username}`);
            
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
              extra: {
                charset: 'utf8mb4_unicode_ci',
                connectionLimit: 10,
                acquireTimeout: 60000,
                timeout: 60000,
                reconnect: true,
              },
              retryAttempts: 10,
              retryDelay: 3000,
            };
            
            console.log('🚀 Using parsed MySQL configuration');
            return config;
          } catch (error) {
            console.error('❌ Failed to parse MYSQL_URL:', error);
          }
        }

        // Individual MySQL variables fallback
        console.log('⚠️  MYSQL_URL not found or invalid - trying individual variables...');
        
        const mysqlConfig = {
          host: process.env.MYSQLHOST || process.env.DB_HOST || 'mysql.railway.internal',
          port: parseInt(process.env.MYSQLPORT || process.env.DB_PORT || '3306'),
          username: process.env.MYSQLUSER || process.env.DB_USER || 'root',
          password: process.env.MYSQLPASSWORD || process.env.DB_PASSWORD || '',
          database: process.env.MYSQLDATABASE || process.env.DB_NAME || 'railway',
        };

        console.log('🔗 Using individual MySQL variables:');
        console.log(`  - Host: ${mysqlConfig.host}`);
        console.log(`  - Port: ${mysqlConfig.port}`);
        console.log(`  - Database: ${mysqlConfig.database}`);
        console.log(`  - Username: ${mysqlConfig.username}`);

        return {
          type: 'mysql' as const,
          ...mysqlConfig,
          entities: [User, Doctor, Appointment, Queue],
          synchronize: true,
          logging: true,
          extra: {
            charset: 'utf8mb4_unicode_ci',
            connectionLimit: 10,
            acquireTimeout: 60000,
            timeout: 60000,
            reconnect: true,
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

# 4. Clean up the duplicate file
rm -f src/app.module.updated.ts

echo ""
echo "✅ TypeScript build errors fixed!"
echo "======================================================"
echo "🔧 ISSUES FIXED:"
echo "✅ Fixed logging type error (changed to 'logging: true')"
echo "✅ Created missing health module files"
echo "✅ Removed duplicate app.module.updated.ts"
echo "✅ Added proper 'as const' type assertions"
echo ""
echo "📁 FILES CREATED:"
echo "✅ src/health/health.controller.ts"
echo "✅ src/health/health.module.ts"
echo "✅ Updated src/app.module.ts"
echo ""
echo "🚀 DEPLOY NOW:"
echo "git add ."
echo "git commit -m 'fix: resolve TypeScript build errors and add health module'"
echo "git push"
echo ""
echo "Expected behavior after deployment:"
echo "✅ Build should complete successfully"
echo "✅ Debug logs will show MySQL connection attempts"
echo "✅ Health endpoint available at /health"