import { Module } from '@nestjs/common';
import { SeedService } from './seed.service';
import { SeedController } from './seed.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Doctor } from '../doctors/entities/doctor.entity';
import { Queue } from '../queue/entities/queue.entity';
import { Appointment } from '../appointments/entities/appointment.entity';
@Module({
  imports: [TypeOrmModule.forFeature([Doctor, Queue, Appointment])],
  controllers: [SeedController],
  providers: [SeedService],
})
export class SeedModule {}
