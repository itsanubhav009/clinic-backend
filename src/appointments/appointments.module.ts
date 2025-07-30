import { Module, forwardRef } from '@nestjs/common';
import { AppointmentsService } from './appointments.service';
import { AppointmentsController } from './appointments.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Appointment } from './entities/appointment.entity';
import { DoctorsModule } from '../doctors/doctors.module';
import { QueueModule } from '../queue/queue.module';
@Module({
  imports: [TypeOrmModule.forFeature([Appointment]), DoctorsModule, forwardRef(() => QueueModule)],
  controllers: [AppointmentsController],
  providers: [AppointmentsService],
  exports: [TypeOrmModule]
})
export class AppointmentsModule {}
