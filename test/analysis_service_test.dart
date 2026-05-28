import 'package:flutter_test/flutter_test.dart';
import 'package:story_arc/services/analysis_service.dart';

void main() {
  group('AnalysisService Rate Limiting Tests', () {
    test('Allows up to 5 requests per minute, then throws RateLimitException on 6th request', () async {
      final service = AnalysisService('');

      // We expect the first 5 calls to throw the API key error (which means they passed the rate limiter check)
      for (int i = 0; i < 5; i++) {
        expect(
          () => service.analyzeTranscript('test transcript'),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('API Key is missing'))),
        );
      }

      // The 6th call should throw RateLimitException
      expect(
        () => service.analyzeTranscript('test transcript'),
        throwsA(isA<RateLimitException>().having((e) => e.toString(), 'message', contains('reflecting too quickly'))),
      );
    });
  });
}
