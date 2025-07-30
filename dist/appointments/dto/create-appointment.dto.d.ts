import { AppointmentStatus } from '../entities/appointment.entity';
export declare class CreateAppointmentDto {
    patientName: string;
    doctorId: number;
    date: string;
    time: string;
    status: AppointmentStatus;
}
