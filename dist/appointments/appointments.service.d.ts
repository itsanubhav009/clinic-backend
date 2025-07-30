import { Repository } from 'typeorm';
import { Appointment } from './entities/appointment.entity';
import { CreateAppointmentDto } from './dto/create-appointment.dto';
import { UpdateAppointmentDto } from './dto/update-appointment.dto';
import { DoctorsService } from '../doctors/doctors.service';
export declare class AppointmentsService {
    private repo;
    private doctorsService;
    constructor(repo: Repository<Appointment>, doctorsService: DoctorsService);
    create(dto: CreateAppointmentDto): Promise<Appointment>;
    findAll(search?: string): Promise<Appointment[]>;
    findAllByDoctor(doctorId: number): Promise<Appointment[]>;
    findOne(id: number): Promise<Appointment>;
    update(id: number, dto: UpdateAppointmentDto): Promise<Appointment>;
    remove(id: number): Promise<import("typeorm").DeleteResult>;
}
