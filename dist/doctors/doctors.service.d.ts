import { Repository } from 'typeorm';
import { Doctor, DoctorStatus } from './entities/doctor.entity';
import { CreateDoctorDto } from './dto/create-doctor.dto';
import { UpdateDoctorDto } from './dto/update-doctor.dto';
export declare class DoctorsService {
    private repo;
    constructor(repo: Repository<Doctor>);
    create(dto: CreateDoctorDto): Promise<Doctor>;
    findAll(specialization?: string, location?: string, status?: DoctorStatus): Promise<Doctor[]>;
    findOne(id: number): Promise<Doctor>;
    update(id: number, dto: UpdateDoctorDto): Promise<Doctor>;
    remove(id: number): Promise<import("typeorm").DeleteResult>;
}
