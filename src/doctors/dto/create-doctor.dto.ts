import { IsString, IsNotEmpty, IsEnum, IsOptional } from 'class-validator';
import { DoctorStatus } from '../entities/doctor.entity';
export class CreateDoctorDto {
  @IsString() @IsNotEmpty() name: string;
  @IsString() @IsNotEmpty() specialization: string;
  @IsString() @IsNotEmpty() gender: string;
  @IsString() @IsNotEmpty() location: string;
  @IsEnum(DoctorStatus) @IsOptional() status: DoctorStatus;
  @IsString() @IsNotEmpty() nextAvailable: string;
}
