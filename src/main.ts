import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  console.log('🚀 === RAILWAY STARTUP DEBUG ===');
  console.log('Node.js version:', process.version);
  console.log('Environment:', process.env.NODE_ENV);
  console.log('Railway environment:', process.env.RAILWAY_ENVIRONMENT);
  console.log('');
  
  console.log('🔍 === MYSQL ENVIRONMENT VARIABLES ===');
  const mysqlEnvVars = [
    'MYSQL_URL',
    'MYSQLHOST', 'MYSQLPORT', 'MYSQLUSER', 'MYSQLPASSWORD', 'MYSQLDATABASE',
    'DB_HOST', 'DB_PORT', 'DB_USER', 'DB_PASSWORD', 'DB_NAME'
  ];
  
  mysqlEnvVars.forEach(key => {
    const value = process.env[key];
    if (value) {
      console.log(`✅ ${key}:`, key.includes('PASSWORD') ? '[HIDDEN]' : value);
    } else {
      console.log(`❌ ${key}: MISSING`);
    }
  });
  
  console.log('');
  console.log('📊 Total environment variables:', Object.keys(process.env).length);
  console.log('');

  const app = await NestFactory.create(AppModule);
  
  const port = process.env.PORT || 3000;
  await app.listen(port);
  
  console.log(`🌐 Application is running on port ${port}`);
}

bootstrap().catch(error => {
  console.error('💥 Bootstrap failed:', error);
  process.exit(1);
});
