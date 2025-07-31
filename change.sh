#!/bin/bash

echo "🔧 Fixing package-lock.json mismatch for Railway..."

# Delete the old lock file that references bcrypt
rm -f package-lock.json

# Use the bcryptjs package.json
cp package.bcryptjs.json package.json

# Use the bcryptjs auth service
cp src/auth/auth.service.alternative.ts src/auth/auth.service.ts

# Generate new lock file with bcryptjs dependencies
npm install

echo ""
echo "✅ Lock file fix complete!"
echo "======================================================"
echo "Changes made:"
echo "✅ Deleted old package-lock.json (had bcrypt deps)"
echo "✅ Switched to bcryptjs package.json"
echo "✅ Updated auth service to use bcryptjs"
echo "✅ Generated new package-lock.json with bcryptjs"
echo ""
echo "🚀 Now commit and deploy:"
echo "git add ."
echo "git commit -m 'fix: switch to bcryptjs for Railway compatibility'"
echo "git push"
echo ""
echo "Expected build: ✅ npm ci will work with matching lock file"