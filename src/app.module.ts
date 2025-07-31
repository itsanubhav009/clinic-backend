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
