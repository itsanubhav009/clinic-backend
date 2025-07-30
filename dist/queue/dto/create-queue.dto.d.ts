import { PatientStatus, Priority } from '../entities/queue.entity';
export declare class CreateQueueDto {
    patientName: string;
    arrival: string;
    estWait: string;
    status: PatientStatus;
    priority: Priority;
    doctorId?: number;
    appointmentId?: number;
}
