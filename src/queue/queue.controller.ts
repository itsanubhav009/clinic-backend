import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards } from '@nestjs/common';
import { QueueService } from './queue.service';
import { CreateQueueDto } from './dto/create-queue.dto';
import { UpdateQueueDto } from './dto/update-queue.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
@UseGuards(JwtAuthGuard)
@Controller('queue')
export class QueueController {
  constructor(private readonly service: QueueService) {}
  @Post() create(@Body() dto: CreateQueueDto) { return this.service.create(dto); }
  @Get() findAll() { return this.service.findAll(); }
  @Get(':id') findOne(@Param('id') id: string) { return this.service.findOne(+id); }
  @Patch(':id') update(@Param('id') id: string, @Body() dto: UpdateQueueDto) { return this.service.update(+id, dto); }
  @Delete(':id') remove(@Param('id') id: string) { return this.service.remove(+id); }
}
