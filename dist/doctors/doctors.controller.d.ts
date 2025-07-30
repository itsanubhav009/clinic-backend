import { DoctorsService } from './doctors.service';
import { CreateDoctorDto } from './dto/create-doctor.dto';
import { UpdateDoctorDto } from './dto/update-doctor.dto';
import { DoctorStatus } from './entities/doctor.entity';
export declare class DoctorsController {
    private readonly service;
    constructor(service: DoctorsService);
    create(dto: CreateDoctorDto): Promise<import("./entities/doctor.entity").Doctor>;
    findAll(specialization?: string, location?: string, status?: DoctorStatus): Promise<import("./entities/doctor.entity").Doctor[]>;
    findOne(id: string): Promise<import("./entities/doctor.entity").Doctor>;
    update(id: string, dto: UpdateDoctorDto): Promise<import("./entities/doctor.entity").Doctor>;
    remove(id: string): Promise<import("typeorm").DeleteResult>;
}
