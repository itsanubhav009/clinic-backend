import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query } from '@nestjs/common';
import { DoctorsService } from './doctors.service';
import { CreateDoctorDto } from './dto/create-doctor.dto';
import { UpdateDoctorDto } from './dto/update-doctor.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { DoctorStatus } from './entities/doctor.entity';
@UseGuards(JwtAuthGuard)
@Controller('doctors')
export class DoctorsController {
  constructor(private readonly service: DoctorsService) {}
  @Post() create(@Body() dto: CreateDoctorDto) { return this.service.create(dto); }
  @Get() findAll(
    @Query('specialization') specialization?: string,
    @Query('location') location?: string,
    @Query('status') status?: DoctorStatus,
  ) { return this.service.findAll(specialization, location, status); }
  @Get(':id') findOne(@Param('id') id: string) { return this.service.findOne(+id); }
  @Patch(':id') update(@Param('id') id: string, @Body() dto: UpdateDoctorDto) { return this.service.update(+id, dto); }
  @Delete(':id') remove(@Param('id') id: string) { return this.service.remove(+id); }
}
