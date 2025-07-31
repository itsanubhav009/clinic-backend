import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  // Enable CORS for Railway deployment
  app.enableCors({ 
    origin: true, // Allow all origins for Railway deployment
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE', 
    credentials: true 
  });
  
  app.useGlobalPipes(new ValidationPipe({ 
    whitelist: true, 
    forbidNonWhitelisted: true, 
    transform: true 
  }));
  
  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`🚀 Backend is running on port: ${port}`);
}
bootstrap();
