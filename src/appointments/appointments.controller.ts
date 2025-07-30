import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query } from '@nestjs/common';
import { AppointmentsService } from './appointments.service';
import { CreateAppointmentDto } from './dto/create-appointment.dto';
import { UpdateAppointmentDto } from './dto/update-appointment.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
@UseGuards(JwtAuthGuard)
@Controller('appointments')
export class AppointmentsController {
  constructor(private readonly service: AppointmentsService) {}
  @Post() create(@Body() dto: CreateAppointmentDto) { return this.service.create(dto); }
  @Get() findAll(@Query('search') search?: string) { return this.service.findAll(search); }
  @Get('doctor/:doctorId') findAllByDoctor(@Param('doctorId') doctorId: string) { return this.service.findAllByDoctor(+doctorId); }
  @Get(':id') findOne(@Param('id') id: string) { return this.service.findOne(+id); }
  @Patch(':id') update(@Param('id') id: string, @Body() dto: UpdateAppointmentDto) { return this.service.update(+id, dto); }
  @Delete(':id') remove(@Param('id') id: string) { return this.service.remove(+id); }
}
