#!/bin/bash

# ==============================================================================
# Railway bcrypt Fix - Force rebuild native modules
# ==============================================================================

echo "🔧 Fixing bcrypt native module issue for Railway..."

# 1. Create a proper .dockerignore to ensure clean builds
cat << 'EOF' > .dockerignore
node_modules
npm-debug.log
dist
.env
.git
README.md
EOF

# 2. Create nixpacks.toml to control the build process
cat << 'EOF' > nixpacks.toml
[phases.build]
cmds = [
  "npm ci --production=false",
  "npm run build"
]

[phases.start]
cmd = "npm run start:prod"

[variables]
NODE_ENV = "production"
EOF

# 3. Update package.json with proper build configuration
cat << 'EOF' > package.json
{
  "name": "clinic-backend",
  "version": "1.0.0",
  "scripts": {
    "build": "nest build",
    "start": "nest start",
    "start:dev": "nest start --watch",
    "start:prod": "node dist/main",
    "postinstall": "npm rebuild bcrypt --build-from-source"
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
    "bcrypt": "^5.1.1",
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
    "@types/bcrypt": "^5.0.2",
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

# 4. Alternative: Create auth service with bcryptjs (more reliable on Railway)
cat << 'EOF' > src/auth/auth.service.alternative.ts
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

# 5. Create bcryptjs package.json (more reliable alternative)
cat << 'EOF' > package.bcryptjs.json
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

# 6. Create deployment script with multiple strategies
cat << 'EOF' > deploy-fix.sh
#!/bin/bash

echo "🔧 Applying Railway bcrypt fix..."

# Strategy 1: Try to rebuild bcrypt
echo "📦 Strategy 1: Rebuilding bcrypt native module..."
rm -rf node_modules package-lock.json
npm install
npm rebuild bcrypt --build-from-source

# If that fails, switch to bcryptjs
if [ $? -ne 0 ]; then
    echo "❌ bcrypt rebuild failed"
    echo "📦 Strategy 2: Switching to bcryptjs..."
    
    # Use bcryptjs package.json
    cp package.bcryptjs.json package.json
    
    # Use bcryptjs auth service
    cp src/auth/auth.service.alternative.ts src/auth/auth.service.ts
    
    # Clean install
    rm -rf node_modules package-lock.json
    npm install
    
    echo "✅ Switched to bcryptjs successfully"
else
    echo "✅ bcrypt rebuild successful"
fi

echo "🚀 Ready to deploy!"
EOF

chmod +x deploy-fix.sh

# 7. Create Railway-optimized railway.json
cat << 'EOF' > railway.json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
EOF

echo ""
echo "✅ Railway bcrypt fix created!"
echo "======================================================"
echo "🔧 SOLUTIONS PROVIDED:"
echo ""
echo "1️⃣  NIXPACKS CONFIG (nixpacks.toml)"
echo "   - Forces proper build process"
echo "   - Rebuilds native modules"
echo ""
echo "2️⃣  PACKAGE.JSON POSTINSTALL"
echo "   - Automatically rebuilds bcrypt after install"
echo "   - Uses --build-from-source flag"
echo ""
echo "3️⃣  BCRYPTJS ALTERNATIVE"
echo "   - Pure JavaScript implementation"
echo "   - No native dependencies"
echo "   - More reliable on Railway"
echo ""
echo "🚀 DEPLOYMENT OPTIONS:"
echo ""
echo "OPTION A - Try bcrypt rebuild:"
echo "1. Deploy with current files"
echo "2. Should rebuild bcrypt automatically"
echo ""
echo "OPTION B - Switch to bcryptjs (RECOMMENDED):"
echo "1. cp package.bcryptjs.json package.json"
echo "2. cp src/auth/auth.service.alternative.ts src/auth/auth.service.ts"
echo "3. Deploy (most reliable)"
echo ""
echo "OPTION C - Run deploy script:"
echo "1. ./deploy-fix.sh"
echo "2. Commit and deploy"
echo ""
echo "🎯 RECOMMENDED: Use bcryptjs for Railway deployment"
echo "   It's more reliable and has no native dependencies!"
echo ""