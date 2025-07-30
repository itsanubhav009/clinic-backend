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
exports.QueueService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const queue_entity_1 = require("./entities/queue.entity");
const doctors_service_1 = require("../doctors/doctors.service");
const doctor_entity_1 = require("../doctors/entities/doctor.entity");
const queue_entity_2 = require("./entities/queue.entity");
const appointment_entity_1 = require("../appointments/entities/appointment.entity");
let QueueService = class QueueService {
    constructor(repo, appointmentRepo, doctorsService) {
        this.repo = repo;
        this.appointmentRepo = appointmentRepo;
        this.doctorsService = doctorsService;
    }
    async updateDoctorAvailability(doctorId) {
        const today = new Date();
        const todayString = today.toISOString().split('T')[0];
        const currentTime = today.toTimeString().split(' ')[0].substring(0, 5);
        const nextAppointment = await this.appointmentRepo.findOne({
            where: {
                doctorId: doctorId,
                status: appointment_entity_1.AppointmentStatus.BOOKED,
                date: todayString,
                time: (0, typeorm_2.MoreThan)(currentTime)
            },
            order: { time: 'ASC' }
        });
        if (nextAppointment) {
            await this.doctorsService.update(doctorId, {
                status: doctor_entity_1.DoctorStatus.AVAILABLE,
                nextAvailable: nextAppointment.time,
            });
        }
        else {
            await this.doctorsService.update(doctorId, {
                status: doctor_entity_1.DoctorStatus.AVAILABLE,
                nextAvailable: 'Now',
            });
        }
    }
    create(dto) { return this.repo.save(this.repo.create(dto)); }
    findAll() { return this.repo.find(); }
    findOne(id) { return this.repo.findOneBy({ id }); }
    async update(id, dto) {
        const patientInQueue = await this.findOne(id);
        if (!patientInQueue)
            throw new common_1.NotFoundException('Patient not in queue');
        if (dto.status === queue_entity_2.PatientStatus.WITH_DOCTOR && dto.doctorId) {
            await this.doctorsService.update(dto.doctorId, { status: doctor_entity_1.DoctorStatus.BUSY });
        }
        if (dto.status === queue_entity_2.PatientStatus.COMPLETED && patientInQueue.doctorId) {
            if (patientInQueue.appointmentId) {
                await this.appointmentRepo.update(patientInQueue.appointmentId, { status: appointment_entity_1.AppointmentStatus.COMPLETED });
            }
            await this.updateDoctorAvailability(patientInQueue.doctorId);
        }
        await this.repo.update(id, dto);
        return this.findOne(id);
    }
    async remove(id) {
        const patientInQueue = await this.findOne(id);
        if (patientInQueue && patientInQueue.doctorId) {
            await this.updateDoctorAvailability(patientInQueue.doctorId);
        }
        await this.repo.delete(id);
        return { message: 'Patient removed successfully' };
    }
};
exports.QueueService = QueueService;
exports.QueueService = QueueService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(queue_entity_1.Queue)),
    __param(1, (0, typeorm_1.InjectRepository)(appointment_entity_1.Appointment)),
    __param(2, (0, common_1.Inject)((0, common_1.forwardRef)(() => doctors_service_1.DoctorsService))),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        doctors_service_1.DoctorsService])
], QueueService);
//# sourceMappingURL=queue.service.js.map