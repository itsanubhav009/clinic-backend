"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SeedService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const doctor_entity_1 = require("../doctors/entities/doctor.entity");
const queue_entity_1 = require("../queue/entities/queue.entity");
const appointment_entity_1 = require("../appointments/entities/appointment.entity");
let SeedService = class SeedService {
    constructor(doctorRepo, queueRepo, appointmentRepo) {
        this.doctorRepo = doctorRepo;
        this.queueRepo = queueRepo;
        this.appointmentRepo = appointmentRepo;
    }
    async seed() {
        await this.doctorRepo.clear();
        await this.queueRepo.clear();
        await this.appointmentRepo.clear();
        const doctors = await this.doctorRepo.save([
            { name: 'Dr. Evelyn Reed', specialization: 'General Practice', gender: 'Female', location: 'Room 101', status: doctor_entity_1.DoctorStatus.AVAILABLE, nextAvailable: 'Now' },
            { name: 'Dr. Marcus Chen', specialization: 'Pediatrics', gender: 'Male', location: 'Room 102', status: doctor_entity_1.DoctorStatus.BUSY, nextAvailable: 'Now' },
            { name: 'Dr. Sofia Rossi', specialization: 'Cardiology', gender: 'Female', location: 'Room 201', status: doctor_entity_1.DoctorStatus.OFF_DUTY, nextAvailable: 'Tomorrow 9:00 AM' },
            { name: 'Dr. Leo Grant', specialization: 'Dermatology', gender: 'Male', location: 'Room 202', status: doctor_entity_1.DoctorStatus.AVAILABLE, nextAvailable: 'Now' },
        ]);
        const today = new Date();
        const tomorrow = new Date();
        tomorrow.setDate(today.getDate() + 1);
        const formatDate = (date) => date.toISOString().split('T')[0];
        const appointments = await this.appointmentRepo.save([
            { patientName: 'Alice Brown', doctorId: doctors[0].id, doctorName: doctors[0].name, date: formatDate(today), time: '10:00', status: appointment_entity_1.AppointmentStatus.BOOKED },
            { patientName: 'Charlie Davis', doctorId: doctors[1].id, doctorName: doctors[1].name, date: formatDate(today), time: '11:30', status: appointment_entity_1.AppointmentStatus.BOOKED },
            { patientName: 'Eva White', doctorId: doctors[0].id, doctorName: doctors[0].name, date: formatDate(tomorrow), time: '14:00', status: appointment_entity_1.AppointmentStatus.BOOKED },
        ]);
        const queue = [
            { patientName: 'John Doe', arrival: '09:30 AM', estWait: '15 min', status: queue_entity_1.PatientStatus.WAITING, priority: queue_entity_1.Priority.NORMAL, doctorId: null, appointmentId: null },
            { patientName: 'Jane Smith', arrival: '09:45 AM', estWait: '0 min', status: queue_entity_1.PatientStatus.WITH_DOCTOR, priority: queue_entity_1.Priority.NORMAL, doctorId: doctors[1].id, appointmentId: appointments[1].id },
        ];
        await this.queueRepo.save(queue);
        return { message: 'Database seeded successfully!' };
    }
};
exports.SeedService = SeedService;
exports.SeedService = SeedService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(doctor_entity_1.Doctor)),
    __param(1, (0, typeorm_1.InjectRepository)(queue_entity_1.Queue)),
    __param(2, (0, typeorm_1.InjectRepository)(appointment_entity_1.Appointment)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository])
], SeedService);
//# sourceMappingURL=seed.service.js.map