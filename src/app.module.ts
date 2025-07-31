import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './users/entities/user.entity';
import { Doctor } from './doctors/entities/doctor.entity';
import { Appointment } from './appointments/entities/appointment.entity';
import { Queue } from './queue/entities/queue.entity';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { DoctorsModule } from './doctors/doctors.module';
import { AppointmentsModule } from './appointments/appointments.module';
import { QueueModule } from './queue/queue.module';
import { SeedModule } from './seed/seed.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),

    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (cfg: ConfigService) => {
        /* -----------------------------------------------
           1️⃣  full URL first  (works everywhere)
        -------------------------------------------------*/
        const url =
          cfg.get<string>('MYSQL_PUBLIC_URL')    // outside Railway
          ?? cfg.get<string>('MYSQL_URL')        // inside Railway
          ?? cfg.get<string>('DATABASE_URL');

        if (url) {
          console.log('✅ Using MySQL URL → ' + url.split('@')[1]);
          return {
            type: 'mysql',
            url,
            entities: [User, Doctor, Appointment, Queue],
            synchronize: true,
            ssl: false,          // internal proxy is plaintext
          };
        }

        /* -----------------------------------------------
           2️⃣  fallback to discrete fields (internal only)
        -------------------------------------------------*/
        return {
          type: 'mysql' as const,
          host: cfg.get<string>('MYSQLHOST'),
          port: Number(cfg.get('MYSQLPORT') ?? 3306),
          username: cfg.get<string>('MYSQLUSER'),
          password: cfg.get<string>('MYSQLPASSWORD'),
          database: cfg.get<string>('MYSQLDATABASE'),
          entities: [User, Doctor, Appointment, Queue],
          synchronize: true,
          ssl: false,
          connectTimeout: 60_000,
        };
      },
    }),

    AuthModule, UsersModule, DoctorsModule,
    AppointmentsModule, QueueModule, SeedModule,
  ],
})
export class AppModule {}