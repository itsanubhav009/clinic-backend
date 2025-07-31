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
