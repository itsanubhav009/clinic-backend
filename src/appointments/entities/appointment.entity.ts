import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';
export enum AppointmentStatus { BOOKED = 'Booked', COMPLETED = 'Completed', CANCELED = 'Canceled' }
@Entity()
export class Appointment {
  @PrimaryGeneratedColumn() id: number;
  @Column() patientName: string;
  @Column() doctorName: string;
  @Column() doctorId: number;
  @Column() date: string; 
  @Column() time: string; 
  @Column({ type: 'enum', enum: AppointmentStatus, default: AppointmentStatus.BOOKED }) status: AppointmentStatus;
}
