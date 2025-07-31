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
