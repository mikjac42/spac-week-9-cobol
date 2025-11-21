import { Module } from '@nestjs/common';
import { MovieModule } from './movie/movie.module';
import { HealthController } from './health/health.controller';

@Module({
  imports: [MovieModule],
  controllers: [HealthController],
})
export class AppModule {}
