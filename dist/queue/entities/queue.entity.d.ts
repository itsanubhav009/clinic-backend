export declare enum PatientStatus {
    WAITING = "Waiting",
    WITH_DOCTOR = "With Doctor",
    COMPLETED = "Completed"
}
export declare enum Priority {
    NORMAL = "Normal",
    URGENT = "Urgent"
}
export declare class Queue {
    id: number;
    patientName: string;
    arrival: string;
    estWait: string;
    status: PatientStatus;
    priority: Priority;
    doctorId: number | null;
    appointmentId: number | null;
    createdAt: Date;
}
