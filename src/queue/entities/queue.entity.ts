import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';
export enum PatientStatus { WAITING = 'Waiting', WITH_DOCTOR = 'With Doctor', COMPLETED = 'Completed' }
export enum Priority { NORMAL = 'Normal', URGENT = 'Urgent' }
@Entity()
export class Queue {
  @PrimaryGeneratedColumn() id: number;
  @Column() patientName: string;
  @Column() arrival: string;
  @Column() estWait: string;
  @Column({ type: 'enum', enum: PatientStatus, default: PatientStatus.WAITING }) status: PatientStatus;
  @Column({ type: 'enum', enum: Priority, default: Priority.NORMAL }) priority: Priority;
  @Column({ type: 'int', nullable: true }) doctorId: number | null;
  @Column({ type: 'int', nullable: true }) appointmentId: number | null;
  @CreateDateColumn() createdAt: Date;
}
