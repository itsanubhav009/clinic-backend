import { AppointmentsService } from './appointments.service';
import { CreateAppointmentDto } from './dto/create-appointment.dto';
import { UpdateAppointmentDto } from './dto/update-appointment.dto';
export declare class AppointmentsController {
    private readonly service;
    constructor(service: AppointmentsService);
    create(dto: CreateAppointmentDto): Promise<import("./entities/appointment.entity").Appointment>;
    findAll(search?: string): Promise<import("./entities/appointment.entity").Appointment[]>;
    findAllByDoctor(doctorId: string): Promise<import("./entities/appointment.entity").Appointment[]>;
    findOne(id: string): Promise<import("./entities/appointment.entity").Appointment>;
    update(id: string, dto: UpdateAppointmentDto): Promise<import("./entities/appointment.entity").Appointment>;
    remove(id: string): Promise<import("typeorm").DeleteResult>;
}
