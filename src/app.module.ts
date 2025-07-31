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
        // Log the values to debug
        console.log('DB Config:', {
          host: configService.get<string>('MYSQL_HOST') || configService.get<string>('MYSQLHOST') || configService.get<string>('DB_HOST'),
          port: parseInt(configService.get('MYSQL_PORT') || configService.get('MYSQLPORT') || configService.get('DB_PORT')),
          username: configService.get<string>('MYSQL_USER') || configService.get<string>('MYSQLUSER') || configService.get<string>('DB_USERNAME'),
          database: configService.get<string>('MYSQL_DATABASE') || configService.get<string>('MYSQLDATABASE') || configService.get<string>('DB_DATABASE'),
          // Don't log password for security
        });
        
        return {
          type: 'mysql', 
          host: configService.get<string>('MYSQL_HOST') || configService.get<string>('MYSQLHOST') || configService.get<string>('DB_HOST'),
          port: parseInt(configService.get('MYSQL_PORT') || configService.get('MYSQLPORT') || configService.get('DB_PORT')), 
          username: configService.get<string>('MYSQL_USER') || configService.get<string>('MYSQLUSER') || configService.get<string>('DB_USERNAME'),
          password: configService.get<string>('MYSQL_PASSWORD') || configService.get<string>('MYSQLPASSWORD') || configService.get<string>('DB_PASSWORD'), 
          database: configService.get<string>('MYSQL_DATABASE') || configService.get<string>('MYSQLDATABASE') || configService.get<string>('DB_DATABASE'),
          entities: [User, Doctor, Appointment, Queue], 
          synchronize: true,
          ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
          connectTimeout: 60000,
        };
      },
    }),
    AuthModule, UsersModule, DoctorsModule, AppointmentsModule, QueueModule, SeedModule,
  ],
})
export class AppModule {}