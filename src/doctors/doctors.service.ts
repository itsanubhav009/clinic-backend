import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like } from 'typeorm';
import { Doctor, DoctorStatus } from './entities/doctor.entity';
import { CreateDoctorDto } from './dto/create-doctor.dto';
import { UpdateDoctorDto } from './dto/update-doctor.dto';
@Injectable()
export class DoctorsService {
  constructor(@InjectRepository(Doctor) private repo: Repository<Doctor>) {}
  create(dto: CreateDoctorDto) { return this.repo.save(this.repo.create(dto)); }
  findAll(specialization?: string, location?: string, status?: DoctorStatus) {
    const where: any = {};
    if (specialization) { where.specialization = Like(`%${specialization}%`); }
    if (location) { where.location = Like(`%${location}%`); }
    if (status) { where.status = status; }
    return this.repo.find({ where });
  }
  async findOne(id: number) {
    const doctor = await this.repo.findOneBy({ id });
    if (!doctor) throw new NotFoundException(`Doctor with ID ${id} not found.`);
    return doctor;
  }
  async update(id: number, dto: UpdateDoctorDto) { await this.repo.update(id, dto); return this.findOne(id); }
  remove(id: number) { return this.repo.delete(id); }
}
