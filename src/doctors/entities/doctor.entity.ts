import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';
export enum DoctorStatus { AVAILABLE = 'Available', BUSY = 'Busy', OFF_DUTY = 'Off Duty' }
@Entity()
export class Doctor {
  @PrimaryGeneratedColumn() id: number;
  @Column() name: string;
  @Column() specialization: string;
  @Column() gender: string;
  @Column() location: string;
  @Column({ type: 'enum', enum: DoctorStatus, default: DoctorStatus.AVAILABLE }) status: DoctorStatus;
  @Column() nextAvailable: string;
}
