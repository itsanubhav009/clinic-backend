#!/bin/bash

echo "🔍 Railway MySQL Connection Debug & Fix"

# 1. Create enhanced app.module.ts with better debugging and error handling
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
              logging: ['error', 'warn', 'migration'],
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
          type: 'mysql',
          ...mysqlConfig,
          entities: [User, Doctor, Appointment, Queue],
          synchronize: true,
          logging: ['error', 'warn', 'migration'],
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

# 2. Create a database health check endpoint
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

# 3. Create health module
cat << 'EOF' > src/health/health.module.ts
import { Module } from '@nestjs/common';
import { HealthController } from './health.controller';

@Module({
  controllers: [HealthController],
})
export class HealthModule {}
EOF

# 4. Update main app.module.ts to include health module
cat << 'EOF' > src/app.module.updated.ts
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
              logging: ['error', 'warn', 'migration'],
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
          type: 'mysql',
          ...mysqlConfig,
          entities: [User, Doctor, Appointment, Queue],
          synchronize: true,
          logging: ['error', 'warn', 'migration'],
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

echo ""
echo "✅ MySQL debug configuration created!"
echo "======================================================"
echo "🔧 DEBUG FEATURES ADDED:"
echo "✅ Enhanced connection logging"
echo "✅ Better error handling and retries"
echo "✅ Health check endpoints"
echo "✅ Environment variable debugging"
echo ""
echo "🚀 DEPLOY STEPS:"
echo "1. cp src/app.module.updated.ts src/app.module.ts"
echo "2. git add ."
echo "3. git commit -m 'add mysql debug and health checks'"
echo "4. git push"
echo ""
echo "📊 AFTER DEPLOYMENT - CHECK LOGS FOR:"
echo "🔍 '=== MYSQL CONNECTION DEBUG ==='"
echo "🔍 All environment variables"
echo "🔍 Connection configuration details"
echo ""
echo "🌐 TEST HEALTH ENDPOINTS:"
echo "- GET https://your-app.railway.app/health"
echo "- GET https://your-app.railway.app/health/db"
echo ""
echo "🎯 COMMON ISSUES TO CHECK IN RAILWAY:"
echo "1. Is MySQL service running?"
echo "2. Are environment variables set correctly?"
echo "3. Is the MySQL service in the same Railway project?"
echo "4. Check Railway service variables tab"