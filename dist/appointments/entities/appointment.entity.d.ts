export declare enum AppointmentStatus {
    BOOKED = "Booked",
    COMPLETED = "Completed",
    CANCELED = "Canceled"
}
export declare class Appointment {
    id: number;
    patientName: string;
    doctorName: string;
    doctorId: number;
    date: string;
    time: string;
    status: AppointmentStatus;
}
