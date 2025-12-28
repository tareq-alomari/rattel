import 'package:flutter_test/flutter_test.dart';
import 'package:rattel/app/data/models/reciter_model.dart';
import 'package:rattel/app/data/models/surah_model.dart';
import 'package:rattel/app/data/models/athan_model.dart';
import 'package:rattel/app/data/providers/alfurqan_provider.dart';
import 'package:rattel/app/data/repositories/alfurqan_repository.dart';

// Fake Provider to avoid GetConnect dependency issues in unit test
class FakeAlFurqanProvider extends AlFurqanProvider {
  // @override
  // var httpClient;

  @override
  void onInit() {}

  @override
  Future<List<Reciter>> getReciters() async {
    return [
      Reciter(
        id: 'test_reciter',
        name: 'Test Reciter',
        arabicName: 'مقرأ تجريبي',
      ),
    ];
  }

  @override
  Future<Reciter> getReciter(String id) async {
    return Reciter(id: id, name: 'Test Reciter', arabicName: 'مقرأ تجريبي');
  }

  @override
  Future<List<Surah>> getSurahs() async {
    return [
      Surah(
        number: 1,
        name: 'Al-Fatihah',
        transliteration: 'Al-Fatihah',
        translation: 'The Opening',
        ayahCount: 7,
        startAyah: 1,
        endAyah: 7,
        revelationType: 'Meccan',
      ),
    ];
  }

  @override
  Future<Surah> getSurah(int number) async {
    return Surah(
      number: number,
      name: 'Al-Fatihah',
      transliteration: 'Al-Fatihah',
      translation: 'The Opening',
      ayahCount: 7,
      startAyah: 1,
      endAyah: 7,
      revelationType: 'Meccan',
    );
  }

  @override
  Future<List<Athan>> getAthans() async {
    return [
      Athan(
        id: '1',
        name: 'Athan 1',
        muezzin: 'Muezzin 1',
        location: 'Mecca',
        audioUrl: 'https://example.com/athan.mp3',
      ),
    ];
  }

  @override
  Future<List<dynamic>> search(String query, String type) async {
    return [
      {'id': 'test', 'name': 'Search Result'},
    ];
  }

  @override
  String getAudioUrl(String reciterId, int surahNumber, int ayahNumber) {
    return 'https://alfurqan.online/api/v1/audio/$reciterId/surah/$surahNumber/ayah/$ayahNumber';
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AlFurqanRepository Test', () {
    final provider = FakeAlFurqanProvider();
    final repository = AlFurqanRepository(provider: provider);

    test('getReciters returns list of reciters', () async {
      final result = await repository.getReciters();
      expect(result.length, 1);
      expect(result.first.id, 'test_reciter');
    });

    test('getSurahs returns list of surahs', () async {
      final result = await repository.getSurahs();
      expect(result.length, 1);
      expect(result.first.number, 1);
    });

    test('getAudioUrl returns correct URL format', () {
      final url = repository.getAudioUrl('husary', 2, 255);
      expect(
        url,
        'https://alfurqan.online/api/v1/audio/husary/surah/2/ayah/255',
      );
    });
  });
}
