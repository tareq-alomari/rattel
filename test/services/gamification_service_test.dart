import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
// import 'package:mockito/mockito.dart'; // Removing mockito to avoid code gen dependency issues for now
import 'package:rattel/app/data/services/database_service.dart';
import 'package:rattel/app/data/services/gamification_service.dart';
import 'package:rattel/app/data/models/badge_model.dart'; // Added import for BadgeModel

class MockDatabaseService extends GetxService implements DatabaseService {
  @override
  Future<int> getUserPoints(int userId) async => 0;

  @override
  Future<List<BadgeModel>> getAllBadges(int userId) async => [];

  // Implement other required members as no-ops or throws if not used
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late GamificationService service;

  setUp(() {
    Get.reset(); // Reset before putting
    Get.put<DatabaseService>(MockDatabaseService());
    service = Get.put(GamificationService());
  });

  tearDown(() {
    Get.reset();
  });

  test('should initialize with default values', () async {
    // Manually trigger init because Get.put might have done it but we want to be sure about the async part if needed
    await service.init();
    expect(service.currentPoints.value, 0);
    expect(service.earnedBadges, isEmpty);
  });
}
