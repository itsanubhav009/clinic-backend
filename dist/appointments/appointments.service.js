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
exports.AppointmentsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const appointment_entity_1 = require("./entities/appointment.entity");
const doctors_service_1 = require("../doctors/doctors.service");
let AppointmentsService = class AppointmentsService {
    constructor(repo, doctorsService) {
        this.repo = repo;
        this.doctorsService = doctorsService;
    }
    async create(dto) {
        const doctor = await this.doctorsService.findOne(dto.doctorId);
        const appointmentData = { ...dto, doctorName: doctor.name };
        return this.repo.save(this.repo.create(appointmentData));
    }
    findAll(search) {
        if (!search) {
            return this.repo.find({ order: { date: 'DESC', time: 'ASC' } });
        }
        return this.repo.find({
            where: [
                { patientName: (0, typeorm_2.Like)(`%${search}%`) },
                { doctorName: (0, typeorm_2.Like)(`%${search}%`) },
            ],
            order: { date: 'DESC', time: 'ASC' }
        });
    }
    findAllByDoctor(doctorId) {
        return this.repo.find({
            where: {
                doctorId: doctorId,
                status: appointment_entity_1.AppointmentStatus.BOOKED,
            },
            order: { date: 'ASC', time: 'ASC' }
        });
    }
    findOne(id) { return this.repo.findOneBy({ id }); }
    async update(id, dto) {
        const appointment = await this.repo.findOneBy({ id });
        if (!appointment)
            throw new common_1.NotFoundException('Appointment not found');
        let doctorName = appointment.doctorName;
        if (dto.doctorId && dto.doctorId !== appointment.doctorId) {
            const doctor = await this.doctorsService.findOne(dto.doctorId);
            doctorName = doctor.name;
        }
        await this.repo.update(id, { ...dto, doctorName });
        return this.findOne(id);
    }
    remove(id) { return this.repo.delete(id); }
};
exports.AppointmentsService = AppointmentsService;
exports.AppointmentsService = AppointmentsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(appointment_entity_1.Appointment)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        doctors_service_1.DoctorsService])
], AppointmentsService);
//# sourceMappingURL=appointments.service.js.map