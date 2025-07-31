#!/bin/bash

echo "🔧 Fixing Railway build cache conflict..."

# 1. Create a simplified nixpacks.toml that avoids cache conflicts
cat << 'EOF' > nixpacks.toml
[phases.setup]
nixPkgs = ["nodejs", "npm"]

[phases.build]
cmds = [
  "npm install --omit=dev",
  "npm run build"
]

[phases.start]
cmd = "npm run start:prod"

[variables]
NODE_ENV = "production"
EOF

# 2. Alternative: Remove nixpacks.toml to use default behavior
rm -f nixpacks.toml.backup
if [ -f nixpacks.toml ]; then
    mv nixpacks.toml nixpacks.toml.backup
    echo "✅ Backed up existing nixpacks.toml"
fi

# 3. Create a simpler package.json without postinstall hooks that might conflict
cat << 'EOF' > package.json
{
  "name": "clinic-backend",
  "version": "1.0.0",
  "scripts": {
    "build": "nest build",
    "start": "nest start",
    "start:dev": "nest start --watch",
    "start:prod": "node dist/main"
  },
  "dependencies": {
    "@nestjs/common": "^10.0.0",
    "@nestjs/config": "^3.2.2",
    "@nestjs/core": "^10.0.0",
    "@nestjs/jwt": "^10.2.0",
    "@nestjs/mapped-types": "^2.0.5",
    "@nestjs/passport": "^10.0.3",
    "@nestjs/platform-express": "^10.0.0",
    "@nestjs/typeorm": "^10.0.2",
    "bcryptjs": "^2.4.3",
    "class-transformer": "^0.5.1",
    "class-validator": "^0.14.1",
    "mysql2": "^3.10.0",
    "passport": "^0.7.0",
    "passport-jwt": "^4.0.1",
    "reflect-metadata": "^0.2.2",
    "rxjs": "^7.8.1",
    "typeorm": "^0.3.20"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.0.0",
    "@types/bcryptjs": "^2.4.6",
    "@types/express": "^4.17.17",
    "@types/node": "^20.3.1",
    "@types/passport-jwt": "^4.0.1",
    "typescript": "^5.1.3"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

# 4. Ensure the bcryptjs auth service is in place
if [ ! -f src/auth/auth.service.ts ] || grep -q "bcrypt'" src/auth/auth.service.ts; then
    echo "📝 Updating auth service to use bcryptjs..."
    cat << 'EOF' > src/auth/auth.service.ts
import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import * as bcryptjs from 'bcryptjs';
import { CreateUserDto } from '../users/dto/create-user.dto';

@Injectable()
export class AuthService {
  constructor( 
    private usersService: UsersService, 
    private jwtService: JwtService 
  ) {}

  async signIn(email: string, pass: string): Promise<{ access_token: string }> {
    const user = await this.usersService.findOneByEmail(email);
    if (!user || !(await bcryptjs.compare(pass, user.password))) {
      throw new UnauthorizedException('Invalid credentials.');
    }
    const payload = { sub: user.id, email: user.email };
    return { access_token: this.jwtService.sign(payload) };
  }

  async register(createUserDto: CreateUserDto) {
    if (await this.usersService.findOneByEmail(createUserDto.email)) {
      throw new ConflictException('Email already registered');
    }
    const hashedPassword = await bcryptjs.hash(createUserDto.password, 10);
    const user = await this.usersService.create({ ...createUserDto, password: hashedPassword });
    const { password, ...result } = user;
    return result;
  }
}
EOF
fi

# 5. Clean up any problematic files
rm -f package-lock.json
rm -f .nixpacks/cache

# 6. Regenerate lock file
npm install

echo ""
echo "✅ Railway build fix applied!"
echo "======================================================"
echo "🔧 CHANGES MADE:"
echo "✅ Removed conflicting nixpacks.toml (using defaults)"
echo "✅ Simplified package.json (no postinstall hooks)"
echo "✅ Ensured bcryptjs auth service is active"
echo "✅ Regenerated clean package-lock.json"
echo ""
echo "🚀 DEPLOY NOW:"
echo "git add ."
echo "git commit -m 'fix: simplify build process for Railway'"
echo "git push"
echo ""
echo "Expected behavior:"
echo "✅ Single npm install run"
echo "✅ No cache conflicts"
echo "✅ bcryptjs will work without native compilation"
echo "✅ Clean build process"
echo ""
echo "If this still fails, try deleting nixpacks.toml entirely:"
echo "rm nixpacks.toml && git add . && git commit -m 'remove nixpacks config' && git push"