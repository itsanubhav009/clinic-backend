import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  /* --------------- CORS ---------------- */
  // Take the comma-separated list from .env
  const allowedOrigins = (process.env.ALLOWED_ORIGINS ??
                          'http://localhost:3001').split(',');

  app.enableCors({
    origin: (origin, cb) => {
      // ─ allow calls from Postman / curl (no Origin header) ─
      if (!origin) return cb(null, true);
      return allowedOrigins.includes(origin)
        ? cb(null, true)
        : cb(new Error(`Origin ${origin} not allowed by CORS`));
    },
    credentials: true,
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    allowedHeaders: 'Content-Type, Authorization',
    optionsSuccessStatus: 204,
  });

  /* ------------- global pipes ----------- */
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  const port = process.env.PORT ?? 3000;
  await app.listen(port, '0.0.0.0');
  console.log(`🚀 Backend is running on: ${await app.getUrl()}`);
}
bootstrap();
