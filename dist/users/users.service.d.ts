import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { CreateUserDto } from './dto/create-user.dto';
export declare class UsersService {
    private repo;
    constructor(repo: Repository<User>);
    create(dto: CreateUserDto): Promise<User>;
    findOneByEmail(email: string): Promise<User | undefined>;
    findOneById(id: number): Promise<User | undefined>;
}
