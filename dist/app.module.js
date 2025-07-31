"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const typeorm_1 = require("@nestjs/typeorm");
const auth_module_1 = require("./auth/auth.module");
const users_module_1 = require("./users/users.module");
const doctors_module_1 = require("./doctors/doctors.module");
const appointments_module_1 = require("./appointments/appointments.module");
const queue_module_1 = require("./queue/queue.module");
const user_entity_1 = require("./users/entities/user.entity");
const doctor_entity_1 = require("./doctors/entities/doctor.entity");
const appointment_entity_1 = require("./appointments/entities/appointment.entity");
const queue_entity_1 = require("./queue/entities/queue.entity");
const seed_module_1 = require("./seed/seed.module");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({ isGlobal: true }),
            typeorm_1.TypeOrmModule.forRootAsync({
                imports: [config_1.ConfigModule],
                inject: [config_1.ConfigService],
                useFactory: (configService) => {
                    const mysqlUrl = configService.get('MYSQL_URL') ||
                        configService.get('DATABASE_URL') ||
                        configService.get('MYSQL_PRIVATE_URL');
                    if (mysqlUrl) {
                        console.log('✅ Using MySQL URL connection');
                        return {
                            type: 'mysql',
                            url: mysqlUrl,
                            entities: [user_entity_1.User, doctor_entity_1.Doctor, appointment_entity_1.Appointment, queue_entity_1.Queue],
                            synchronize: true,
                            ssl: false,
                        };
                    }
                    const config = {
                        type: 'mysql',
                        host: configService.get('MYSQLHOST'),
                        port: parseInt(configService.get('MYSQLPORT') || '3306', 10),
                        username: configService.get('MYSQLUSER'),
                        password: configService.get('MYSQLPASSWORD'),
                        database: configService.get('MYSQLDATABASE'),
                        entities: [user_entity_1.User, doctor_entity_1.Doctor, appointment_entity_1.Appointment, queue_entity_1.Queue],
                        synchronize: true,
                        ssl: false,
                        connectTimeout: 60000,
                    };
                    console.log('🔍 MySQL Configuration:');
                    console.log(`Host: ${config.host || 'NOT SET'}`);
                    console.log(`Port: ${config.port}`);
                    console.log(`Username: ${config.username || 'NOT SET'}`);
                    console.log(`Database: ${config.database || 'NOT SET'}`);
                    if (!config.host || config.host === 'localhost' || config.host === '127.0.0.1') {
                        console.error('❌ MySQL host is not properly set. Make sure to reference MySQL variables from MySQL service.');
                        throw new Error('MySQL host configuration error');
                    }
                    return config;
                },
            }),
            auth_module_1.AuthModule, users_module_1.UsersModule, doctors_module_1.DoctorsModule, appointments_module_1.AppointmentsModule, queue_module_1.QueueModule, seed_module_1.SeedModule,
        ],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map