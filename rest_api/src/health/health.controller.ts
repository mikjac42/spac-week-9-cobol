import { Controller, Get } from '@nestjs/common';

@Controller()
export class HealthController {
  @Get('health')
  checkHealth() {
    return {
      status: 'ok',
      message: 'COBOL REST API is running',
      timestamp: new Date().toISOString(),
    };
  }

  @Get()
  getInfo() {
    return {
      name: 'COBOL Movie REST API with NestJS',
      version: '1.0.0',
      framework: 'NestJS + TypeScript',
      endpoints: {
        'GET /': 'API information',
        'GET /movie?id=N': 'Get movie by ID',
        'GET /health': 'Health check',
      },
      example: 'http://localhost:8080/movie?id=5',
    };
  }
}
