import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { CreateUserDto } from '../users/dto/create-user.dto';
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}
  @HttpCode(HttpStatus.OK) @Post('login')
  signIn(@Body() loginDto: LoginDto) { return this.authService.signIn(loginDto.email, loginDto.password); }
  @Post('register')
  register(@Body() createUserDto: CreateUserDto) { return this.authService.register(createUserDto); }
}
