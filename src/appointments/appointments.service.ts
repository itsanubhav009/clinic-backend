import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like } from 'typeorm';
import { Appointment, AppointmentStatus } from './entities/appointment.entity';
import { CreateAppointmentDto } from './dto/create-appointment.dto';
import { UpdateAppointmentDto } from './dto/update-appointment.dto';
import { DoctorsService } from '../doctors/doctors.service';

@Injectable()
export class AppointmentsService {
  constructor(
    @InjectRepository(Appointment) private repo: Repository<Appointment>,
    private doctorsService: DoctorsService,
  ) {}

  async create(dto: CreateAppointmentDto) {
    const doctor = await this.doctorsService.findOne(dto.doctorId);
    const appointmentData = { ...dto, doctorName: doctor.name };
    return this.repo.save(this.repo.create(appointmentData));
  }

  findAll(search?: string) {
    if (!search) { return this.repo.find({order: {date: 'DESC', time: 'ASC'}}); }
    return this.repo.find({
        where: [
            { patientName: Like(`%${search}%`) },
            { doctorName: Like(`%${search}%`) },
        ],
        order: {date: 'DESC', time: 'ASC'}
    });
  }

  findAllByDoctor(doctorId: number) {
    return this.repo.find({
        where: {
            doctorId: doctorId,
            status: AppointmentStatus.BOOKED,
        },
        order: {date: 'ASC', time: 'ASC'}
    });
  }

  findOne(id: number) { return this.repo.findOneBy({ id }); }

  async update(id: number, dto: UpdateAppointmentDto) {
    const appointment = await this.repo.findOneBy({ id });
    if (!appointment) throw new NotFoundException('Appointment not found');

    let doctorName = appointment.doctorName;
    if (dto.doctorId && dto.doctorId !== appointment.doctorId) {
        const doctor = await this.doctorsService.findOne(dto.doctorId);
        doctorName = doctor.name;
    }

    await this.repo.update(id, {...dto, doctorName});
    return this.findOne(id);
  }

  remove(id: number) { return this.repo.delete(id); }
}
