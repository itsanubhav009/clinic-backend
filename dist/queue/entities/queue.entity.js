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
Object.defineProperty(exports, "__esModule", { value: true });
exports.Queue = exports.Priority = exports.PatientStatus = void 0;
const typeorm_1 = require("typeorm");
var PatientStatus;
(function (PatientStatus) {
    PatientStatus["WAITING"] = "Waiting";
    PatientStatus["WITH_DOCTOR"] = "With Doctor";
    PatientStatus["COMPLETED"] = "Completed";
})(PatientStatus || (exports.PatientStatus = PatientStatus = {}));
var Priority;
(function (Priority) {
    Priority["NORMAL"] = "Normal";
    Priority["URGENT"] = "Urgent";
})(Priority || (exports.Priority = Priority = {}));
let Queue = class Queue {
};
exports.Queue = Queue;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], Queue.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], Queue.prototype, "patientName", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], Queue.prototype, "arrival", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], Queue.prototype, "estWait", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'enum', enum: PatientStatus, default: PatientStatus.WAITING }),
    __metadata("design:type", String)
], Queue.prototype, "status", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'enum', enum: Priority, default: Priority.NORMAL }),
    __metadata("design:type", String)
], Queue.prototype, "priority", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', nullable: true }),
    __metadata("design:type", Number)
], Queue.prototype, "doctorId", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'int', nullable: true }),
    __metadata("design:type", Number)
], Queue.prototype, "appointmentId", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", Date)
], Queue.prototype, "createdAt", void 0);
exports.Queue = Queue = __decorate([
    (0, typeorm_1.Entity)()
], Queue);
//# sourceMappingURL=queue.entity.js.map