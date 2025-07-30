import { DoctorStatus } from '../entities/doctor.entity';
export declare class CreateDoctorDto {
    name: string;
    specialization: string;
    gender: string;
    location: string;
    status: DoctorStatus;
    nextAvailable: string;
}
