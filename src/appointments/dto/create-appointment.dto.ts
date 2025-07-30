import { IsString, IsNotEmpty, IsEnum, IsDateString, IsNumber, IsOptional } from 'class-validator';
import { AppointmentStatus } from '../entities/appointment.entity';
export class CreateAppointmentDto {
  @IsString() @IsNotEmpty() patientName: string;
  @IsNumber() @IsNotEmpty() doctorId: number;
  @IsDateString() @IsNotEmpty() date: string;
  @IsString() @IsNotEmpty() time: string;
  @IsEnum(AppointmentStatus) @IsOptional() status: AppointmentStatus;
}
