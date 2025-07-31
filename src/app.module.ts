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
        console.log('🔍 MySQL Connection Variables Debug:');
        console.log('MYSQL_URL:', configService.get('MYSQL_URL') ? 'Present' : 'Missing');
        console.log('MYSQLHOST:', configService.get('MYSQLHOST') || 'Missing');
        console.log('MYSQLPORT:', configService.get('MYSQLPORT') || 'Missing');
        console.log('MYSQLDATABASE:', configService.get('MYSQLDATABASE') || 'Missing');
        console.log('MYSQLUSER:', configService.get('MYSQLUSER') || 'Missing');
        console.log('MYSQLPASSWORD:', configService.get('MYSQLPASSWORD') ? 'Present' : 'Missing');
        console.log('DB_HOST (fallback):', configService.get('DB_HOST') || 'Missing');

        // First try: Use MYSQL_URL if available (Railway's preferred method)
        const mysqlUrl = configService.get<string>('MYSQL_URL');
        if (mysqlUrl) {
          console.log('✅ Using MYSQL_URL connection string');
          console.log('Connection URL format:', mysqlUrl.replace(/:[^:]*@/, ':****@')); // Hide password
          return {
            type: 'mysql',
            url: mysqlUrl,
            entities: [User, Doctor, Appointment, Queue],
            synchronize: true,
            ssl: false,
            connectTimeout: 60000,
            acquireTimeout: 60000,
            timeout: 60000,
            retryAttempts: 3,
            retryDelay: 3000,
          };
        }

        // Second try: Use individual Railway variables
        const host = configService.get<string>('MYSQLHOST');
        const port = parseInt(configService.get('MYSQLPORT')) || 3306;
        const username = configService.get<string>('MYSQLUSER');
        const password = configService.get<string>('MYSQLPASSWORD');
        const database = configService.get<string>('MYSQLDATABASE');

        if (host && username && password && database) {
          console.log('✅ Using individual MySQL variables');
          console.log(`🔗 Connecting to: ${username}@${host}:${port}/${database}`);
          return {
            type: 'mysql',
            host,
            port,
            username,
            password,
            database,
            entities: [User, Doctor, Appointment, Queue],
            synchronize: true,
            ssl: false,
            connectTimeout: 60000,
            acquireTimeout: 60000,
            timeout: 60000,
            retryAttempts: 3,
            retryDelay: 3000,
          };
        }

        // Fallback for local development
        console.log('⚠️ Using fallback local MySQL connection');
        const fallbackHost = configService.get<string>('DB_HOST') || 'localhost';
        const fallbackPort = parseInt(configService.get('DB_PORT')) || 3306;
        const fallbackUser = configService.get<string>('DB_USERNAME') || 'root';
        const fallbackDb = configService.get<string>('DB_DATABASE') || 'clinic_db';
        
        console.log(`🔗 Fallback connecting to: ${fallbackUser}@${fallbackHost}:${fallbackPort}/${fallbackDb}`);
        
        return {
          type: 'mysql',
          host: fallbackHost,
          port: fallbackPort,
          username: fallbackUser,
          password: configService.get<string>('DB_PASSWORD') || 'password',
          database: fallbackDb,
          entities: [User, Doctor, Appointment, Queue],
          synchronize: true,
          ssl: false,
          connectTimeout: 60000,
          acquireTimeout: 60000,
          timeout: 60000,
          retryAttempts: 3,
          retryDelay: 3000,
        };
      },
    }),
    AuthModule, UsersModule, DoctorsModule, AppointmentsModule, QueueModule, SeedModule,
  ],
})
export class AppModule {}
