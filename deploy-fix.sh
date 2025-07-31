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
