export declare enum DoctorStatus {
    AVAILABLE = "Available",
    BUSY = "Busy",
    OFF_DUTY = "Off Duty"
}
export declare class Doctor {
    id: number;
    name: string;
    specialization: string;
    gender: string;
    location: string;
    status: DoctorStatus;
    nextAvailable: string;
}
