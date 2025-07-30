import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Doctor, DoctorStatus } from '../doctors/entities/doctor.entity';
import { Queue, PatientStatus, Priority } from '../queue/entities/queue.entity';
import { Appointment, AppointmentStatus } from '../appointments/entities/appointment.entity';
@Injectable()
export class SeedService {
  constructor(
    @InjectRepository(Doctor) private doctorRepo: Repository<Doctor>,
    @InjectRepository(Queue) private queueRepo: Repository<Queue>,
    @InjectRepository(Appointment) private appointmentRepo: Repository<Appointment>,
  ) {}
  async seed() {
    await this.doctorRepo.clear();
    await this.queueRepo.clear();
    await this.appointmentRepo.clear();

    const doctors = await this.doctorRepo.save([
      { name: 'Dr. Evelyn Reed', specialization: 'General Practice', gender: 'Female', location: 'Room 101', status: DoctorStatus.AVAILABLE, nextAvailable: 'Now' },
      { name: 'Dr. Marcus Chen', specialization: 'Pediatrics', gender: 'Male', location: 'Room 102', status: DoctorStatus.BUSY, nextAvailable: 'Now' },
      { name: 'Dr. Sofia Rossi', specialization: 'Cardiology', gender: 'Female', location: 'Room 201', status: DoctorStatus.OFF_DUTY, nextAvailable: 'Tomorrow 9:00 AM' },
      { name: 'Dr. Leo Grant', specialization: 'Dermatology', gender: 'Male', location: 'Room 202', status: DoctorStatus.AVAILABLE, nextAvailable: 'Now' },
    ]);

    const today = new Date();
    const tomorrow = new Date();
    tomorrow.setDate(today.getDate() + 1);
    const formatDate = (date: Date) => date.toISOString().split('T')[0];

    const appointments = await this.appointmentRepo.save([
      { patientName: 'Alice Brown', doctorId: doctors[0].id, doctorName: doctors[0].name, date: formatDate(today), time: '10:00', status: AppointmentStatus.BOOKED },
      { patientName: 'Charlie Davis', doctorId: doctors[1].id, doctorName: doctors[1].name, date: formatDate(today), time: '11:30', status: AppointmentStatus.BOOKED },
      { patientName: 'Eva White', doctorId: doctors[0].id, doctorName: doctors[0].name, date: formatDate(tomorrow), time: '14:00', status: AppointmentStatus.BOOKED },
    ]);

    const queue = [
      { patientName: 'John Doe', arrival: '09:30 AM', estWait: '15 min', status: PatientStatus.WAITING, priority: Priority.NORMAL, doctorId: null, appointmentId: null },
      { patientName: 'Jane Smith', arrival: '09:45 AM', estWait: '0 min', status: PatientStatus.WITH_DOCTOR, priority: Priority.NORMAL, doctorId: doctors[1].id, appointmentId: appointments[1].id },
    ];
    await this.queueRepo.save(queue);

    return { message: 'Database seeded successfully!' };
  }
}
