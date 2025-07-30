import { QueueService } from './queue.service';
import { CreateQueueDto } from './dto/create-queue.dto';
import { UpdateQueueDto } from './dto/update-queue.dto';
export declare class QueueController {
    private readonly service;
    constructor(service: QueueService);
    create(dto: CreateQueueDto): Promise<import("./entities/queue.entity").Queue>;
    findAll(): Promise<import("./entities/queue.entity").Queue[]>;
    findOne(id: string): Promise<import("./entities/queue.entity").Queue>;
    update(id: string, dto: UpdateQueueDto): Promise<import("./entities/queue.entity").Queue>;
    remove(id: string): Promise<{
        message: string;
    }>;
}
