import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  app.enableCors();
  
  const port = 8080;
  await app.listen(port);
  
  console.log('\n' + '='.repeat(60));
  console.log('COBOL REST API Server with NestJS + TypeScript');
  console.log('='.repeat(60));
  console.log(`Server running at http://localhost:${port}`);
  console.log(`Usage: http://localhost:${port}/movie?id=5`);
  console.log(`API Docs: http://localhost:${port}/`);
  console.log(`Health check: http://localhost:${port}/health`);
  console.log('Press Ctrl+C to stop the server\n');
}

bootstrap();
