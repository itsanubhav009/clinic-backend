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
      // Load environment variables
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule], 
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => {
        console.log('🔍 Database Connection Debug Information:');
        console.log('==========================================');
        
        // Check for Railway MySQL URL first (preferred method)
        const mysqlUrl = configService.get<string>('MYSQL_URL');
        const railwayHost = configService.get<string>('MYSQLHOST');
        const railwayPort = configService.get<string>('MYSQLPORT');
        const railwayUser = configService.get<string>('MYSQLUSER');
        const railwayPassword = configService.get<string>('MYSQLPASSWORD');
        const railwayDatabase = configService.get<string>('MYSQLDATABASE');
        
        // Check for local MySQL configuration
        const localHost = configService.get<string>('DB_HOST');
        const localPort = configService.get<string>('DB_PORT');
        const localUser = configService.get<string>('DB_USERNAME');
        const localPassword = configService.get<string>('DB_PASSWORD');
        const localDatabase = configService.get<string>('DB_DATABASE');
        
        console.log('Railway MySQL URL:', mysqlUrl ? 'Present' : 'Missing');
        console.log('Railway Host:', railwayHost || 'Missing');
        console.log('Railway Port:', railwayPort || 'Missing');
        console.log('Railway User:', railwayUser || 'Missing');
        console.log('Railway Password:', railwayPassword ? 'Present' : 'Missing');
        console.log('Railway Database:', railwayDatabase || 'Missing');
        console.log('---');
        console.log('Local Host:', localHost || 'Missing');
        console.log('Local Port:', localPort || 'Missing');
        console.log('Local User:', localUser || 'Missing');
        console.log('Local Password:', localPassword ? 'Present' : 'Missing');
        console.log('Local Database:', localDatabase || 'Missing');
        console.log('==========================================');

        // Strategy 1: Use MYSQL_URL if available (Railway's preferred method)
        if (mysqlUrl) {
          console.log('✅ Using Railway MySQL URL connection');
          const maskedUrl = mysqlUrl.replace(/:[^:]*@/, ':****@');
          console.log('Connection URL:', maskedUrl);
          
          return {
            type: 'mysql',
            url: mysqlUrl,
            entities: [User, Doctor, Appointment, Queue],
            synchronize: true,
            ssl: false,
            connectTimeout: 60000,
            acquireTimeout: 60000,
            timeout: 60000,
            retryAttempts: 5,
            retryDelay: 3000,
            // Additional connection options for Railway
            extra: {
              charset: 'utf8mb4_unicode_ci',
            },
          };
        }

        // Strategy 2: Use individual Railway variables
        if (railwayHost && railwayUser && railwayPassword && railwayDatabase) {
          console.log('✅ Using Railway individual MySQL variables');
          console.log(`🔗 Connecting to: ${railwayUser}@${railwayHost}:${railwayPort}/${railwayDatabase}`);
          
          return {
            type: 'mysql',
            host: railwayHost,
            port: parseInt(railwayPort) || 3306,
            username: railwayUser,
            password: railwayPassword,
            database: railwayDatabase,
            entities: [User, Doctor, Appointment, Queue],
            synchronize: true,
            ssl: false,
            connectTimeout: 60000,
            acquireTimeout: 60000,
            timeout: 60000,
            retryAttempts: 5,
            retryDelay: 3000,
            extra: {
              charset: 'utf8mb4_unicode_ci',
            },
          };
        }

        // Strategy 3: Use local MySQL configuration
        if (localHost && localUser && localDatabase) {
          console.log('✅ Using local MySQL configuration');
          console.log(`🔗 Connecting to: ${localUser}@${localHost}:${localPort}/${localDatabase}`);
          
          return {
            type: 'mysql',
            host: localHost || '127.0.0.1',
            port: parseInt(localPort) || 3306,
            username: localUser,
            password: localPassword || '',
            database: localDatabase,
            entities: [User, Doctor, Appointment, Queue],
            synchronize: true,
            ssl: false,
            connectTimeout: 60000,
            acquireTimeout: 60000,
            timeout: 60000,
            retryAttempts: 5,
            retryDelay: 3000,
          };
        }

        // Strategy 4: Fallback to default local MySQL
        console.log('⚠️  Using fallback default MySQL configuration');
        console.log('🔗 Fallback: root@127.0.0.1:3306/clinic_db');
        
        return {
          type: 'mysql',
          host: '127.0.0.1',
          port: 3306,
          username: 'root',
          password: 'password',
          database: 'clinic_db',
          entities: [User, Doctor, Appointment, Queue],
          synchronize: true,
          ssl: false,
          connectTimeout: 60000,
          acquireTimeout: 60000,
          timeout: 60000,
          retryAttempts: 5,
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
export class AppModule {
  constructor() {
    console.log('🚀 AppModule initialized');
  }
}