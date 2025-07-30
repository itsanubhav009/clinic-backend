import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { CreateUserDto } from './dto/create-user.dto';
@Injectable()
export class UsersService {
  constructor(@InjectRepository(User) private repo: Repository<User>) {}
  create(dto: CreateUserDto): Promise<User> { return this.repo.save(this.repo.create(dto)); }
  findOneByEmail(email: string): Promise<User | undefined> { return this.repo.findOne({ where: { email } }); }
  findOneById(id: number): Promise<User | undefined> { return this.repo.findOne({ where: { id } }); }
}
