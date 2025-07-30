import { Repository } from 'typeorm';
import { Doctor } from '../doctors/entities/doctor.entity';
import { Queue } from '../queue/entities/queue.entity';
import { Appointment } from '../appointments/entities/appointment.entity';
export declare class SeedService {
    private doctorRepo;
    private queueRepo;
    private appointmentRepo;
    constructor(doctorRepo: Repository<Doctor>, queueRepo: Repository<Queue>, appointmentRepo: Repository<Appointment>);
    seed(): Promise<{
        message: string;
    }>;
}
