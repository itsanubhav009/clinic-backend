import { IsString, IsNotEmpty, IsEnum, IsOptional, IsNumber } from 'class-validator';
import { PatientStatus, Priority } from '../entities/queue.entity';
export class CreateQueueDto {
  @IsString() @IsNotEmpty() patientName: string;
  @IsString() @IsNotEmpty() arrival: string;
  @IsString() @IsNotEmpty() estWait: string;
  @IsEnum(PatientStatus) @IsOptional() status: PatientStatus;
  @IsEnum(Priority) @IsOptional() priority: Priority;
  @IsNumber() @IsOptional() doctorId?: number;
  @IsNumber() @IsOptional() appointmentId?: number;
}
