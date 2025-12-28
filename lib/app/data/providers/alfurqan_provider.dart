import 'package:get/get.dart';
import '../models/reciter_model.dart';
import '../models/surah_model.dart';
import '../models/athan_model.dart';

class AlFurqanProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'https://alfurqan.online/api/v1';
  }

  // Reciters
  Future<List<Reciter>> getReciters() async {
    final response = await get('/reciters');
    if (response.status.hasError) {
      return Future.error(response.statusText ?? 'Error fetching reciters');
    }
    final data = response.body['reciters'] as List;
    return data.map((e) => Reciter.fromMap(e)).toList();
  }

  Future<Reciter> getReciter(String id) async {
    final response = await get('/reciters/$id');
    if (response.status.hasError) {
      return Future.error(response.statusText ?? 'Error fetching reciter');
    }
    return Reciter.fromMap(response.body['reciter']);
  }

  // Surahs
  Future<List<Surah>> getSurahs() async {
    final response = await get('/surahs');
    if (response.status.hasError) {
      return Future.error(response.statusText ?? 'Error fetching surahs');
    }
    final data = response.body['surahs'] as List;
    return data.map((e) => Surah.fromMap(e)).toList();
  }

  Future<Surah> getSurah(int number) async {
    final response = await get('/surahs/$number');
    if (response.status.hasError) {
      return Future.error(response.statusText ?? 'Error fetching surah');
    }
    return Surah.fromMap(response.body['surah']);
  }

  // Audio URL Helper
  String getAudioUrl(String reciterId, int surahNumber, int ayahNumber) {
    // Ensuring no double slashes if baseUrl has one, but GetConnect usually handles it?
    // Wait, accessing httpClient.baseUrl might not be perfect for direct string concat if not used in request.
    const baseUrl = 'https://alfurqan.online/api/v1';
    return '$baseUrl/audio/$reciterId/surah/$surahNumber/ayah/$ayahNumber';
  }

  // Athans
  Future<List<Athan>> getAthans() async {
    final response = await get('/athan/list');
    if (response.status.hasError) {
      return Future.error(response.statusText ?? 'Error fetching athans');
    }
    final data = response.body['athans'] as List;
    return data.map((e) {
      // Fix relative URL to absolute
      if (e['audioUrl'] != null &&
          !e['audioUrl'].toString().startsWith('http')) {
        e['audioUrl'] = 'https://alfurqan.online${e['audioUrl']}';
      }
      return Athan.fromMap(e);
    }).toList();
  }

  // Search
  Future<List<dynamic>> search(String query, String type) async {
    final response = await get('/search?q=$query&type=$type');
    if (response.status.hasError) {
      return Future.error(response.statusText ?? 'Search error');
    }
    return response.body['results'] as List;
  }

  // SVG Pages (for future use when API supports it)
  String getSvgPageUrl(int pageNumber) {
    const baseUrl = 'https://alfurqan.online/api/v1';
    return '$baseUrl/quran/svg/page/$pageNumber';
  }

  Future<String> fetchSvgPageContent(int pageNumber) async {
    final response = await get('/quran/svg/page/$pageNumber');
    if (response.status.hasError) {
      return Future.error(response.statusText ?? 'Error fetching SVG page');
    }
    return response.bodyString ?? '';
  }
}
