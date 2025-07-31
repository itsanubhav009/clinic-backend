#!/bin/bash

echo "🔧 Applying Railway MySQL connection fix..."

cat > src/app.module.ts << 'EOF'
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
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule], 
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => {
        const mysqlUrl = configService.get<string>('MYSQL_URL') || 
                        configService.get<string>('DATABASE_URL') ||
                        configService.get<string>('MYSQL_PRIVATE_URL');
        
        if (mysqlUrl) {
          console.log('✅ Using MySQL URL connection');
          return {
            type: 'mysql',
            url: mysqlUrl,
            entities: [User, Doctor, Appointment, Queue],
            synchronize: true,
            ssl: false,
          };
        }
        
        const config = {
          type: 'mysql' as const,
          host: configService.get<string>('MYSQL_HOST'),
          port: parseInt(configService.get('MYSQL_PORT') || '3306'),
          username: configService.get<string>('MYSQL_USER'),
          password: configService.get<string>('MYSQL_PASSWORD'),
          database: configService.get<string>('MYSQL_DATABASE'),
          entities: [User, Doctor, Appointment, Queue],
          synchronize: true,
          ssl: false,
          connectTimeout: 60000,
        };
        
        console.log('🔍 MySQL Configuration:');
        console.log(`Host: ${config.host || 'NOT SET'}`);
        console.log(`Port: ${config.port}`);
        console.log(`Username: ${config.username || 'NOT SET'}`);
        console.log(`Database: ${config.database || 'NOT SET'}`);
        
        if (!config.host || config.host === 'localhost' || config.host === '127.0.0.1') {
          console.error('❌ MySQL host is not properly set. Make sure to reference MySQL variables from MySQL service.');
          throw new Error('MySQL host configuration error');
        }
        
        return config;
      },
    }),
    AuthModule, UsersModule, DoctorsModule, AppointmentsModule, QueueModule, SeedModule,
  ],
})
export class AppModule {}
EOF

echo "✅ Updated app.module.ts"
echo ""
echo "📋 Next steps:"
echo "1. In Railway, go to your backend service → Variables"
echo "2. Add a reference to MYSQL_URL from your MySQL service"
echo "3. Commit and push: git add . && git commit -m 'Fix MySQL connection' && git push"