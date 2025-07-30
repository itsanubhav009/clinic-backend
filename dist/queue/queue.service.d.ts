import { Repository } from 'typeorm';
import { Queue } from './entities/queue.entity';
import { CreateQueueDto } from './dto/create-queue.dto';
import { UpdateQueueDto } from './dto/update-queue.dto';
import { DoctorsService } from '../doctors/doctors.service';
import { Appointment } from '../appointments/entities/appointment.entity';
export declare class QueueService {
    private repo;
    private appointmentRepo;
    private doctorsService;
    constructor(repo: Repository<Queue>, appointmentRepo: Repository<Appointment>, doctorsService: DoctorsService);
    private updateDoctorAvailability;
    create(dto: CreateQueueDto): Promise<Queue>;
    findAll(): Promise<Queue[]>;
    findOne(id: number): Promise<Queue>;
    update(id: number, dto: UpdateQueueDto): Promise<Queue>;
    remove(id: number): Promise<{
        message: string;
    }>;
}
