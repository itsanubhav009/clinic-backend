import { Injectable, NotFoundException, Inject, forwardRef } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { Queue } from './entities/queue.entity';
import { CreateQueueDto } from './dto/create-queue.dto';
import { UpdateQueueDto } from './dto/update-queue.dto';
import { DoctorsService } from '../doctors/doctors.service';
import { DoctorStatus } from '../doctors/entities/doctor.entity';
import { PatientStatus } from './entities/queue.entity';
import { Appointment, AppointmentStatus } from '../appointments/entities/appointment.entity';

@Injectable()
export class QueueService {
  constructor(
    @InjectRepository(Queue) private repo: Repository<Queue>,
    @InjectRepository(Appointment) private appointmentRepo: Repository<Appointment>,
    @Inject(forwardRef(() => DoctorsService)) private doctorsService: DoctorsService,
  ) {}

  private async updateDoctorAvailability(doctorId: number) {
    const today = new Date();
    const todayString = today.toISOString().split('T')[0];
    const currentTime = today.toTimeString().split(' ')[0].substring(0, 5);

    const nextAppointment = await this.appointmentRepo.findOne({
        where: {
            doctorId: doctorId,
            status: AppointmentStatus.BOOKED,
            date: todayString,
            time: MoreThan(currentTime)
        },
        order: { time: 'ASC' }
    });

    if (nextAppointment) {
        await this.doctorsService.update(doctorId, {
            status: DoctorStatus.AVAILABLE,
            nextAvailable: nextAppointment.time,
        });
    } else {
        await this.doctorsService.update(doctorId, {
            status: DoctorStatus.AVAILABLE,
            nextAvailable: 'Now',
        });
    }
  }

  create(dto: CreateQueueDto) { return this.repo.save(this.repo.create(dto)); }
  findAll() { return this.repo.find(); }
  findOne(id: number) { return this.repo.findOneBy({ id }); }

  async update(id: number, dto: UpdateQueueDto) {
    const patientInQueue = await this.findOne(id);
    if (!patientInQueue) throw new NotFoundException('Patient not in queue');
    
    if (dto.status === PatientStatus.WITH_DOCTOR && dto.doctorId) {
        await this.doctorsService.update(dto.doctorId, { status: DoctorStatus.BUSY });
    }
    
    if (dto.status === PatientStatus.COMPLETED && patientInQueue.doctorId) {
        if(patientInQueue.appointmentId) {
            await this.appointmentRepo.update(patientInQueue.appointmentId, { status: AppointmentStatus.COMPLETED });
        }
        await this.updateDoctorAvailability(patientInQueue.doctorId);
    }

    await this.repo.update(id, dto);
    return this.findOne(id);
  }

  async remove(id: number) {
    const patientInQueue = await this.findOne(id);
    if (patientInQueue && patientInQueue.doctorId) {
        await this.updateDoctorAvailability(patientInQueue.doctorId);
    }
    await this.repo.delete(id);
    return { message: 'Patient removed successfully' };
  }
}
