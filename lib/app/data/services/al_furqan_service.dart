import 'package:get/get.dart';
import '../models/reciter_model.dart';
import '../models/surah_model.dart';
import '../models/athan_model.dart';
import '../repositories/alfurqan_repository.dart';
import '../providers/alfurqan_provider.dart';

class AlFurqanService extends GetxService {
  static AlFurqanService get to => Get.find();

  late final AlFurqanRepository _repository;

  @override
  void onInit() {
    super.onInit();
    final provider = AlFurqanProvider();
    provider.onInit(); // Ensure baseUrl is set
    _repository = AlFurqanRepository(provider: provider);
  }

  /// Fetch all available reciters
  Future<List<Reciter>> getReciters() => _repository.getReciters();

  /// Get specific reciter
  Future<Reciter> getReciter(String id) => _repository.getReciter(id);

  /// Fetch all surahs
  Future<List<Surah>> getSurahs() => _repository.getSurahs();

  /// Get specific surah
  Future<Surah> getSurah(int number) => _repository.getSurah(number);

  /// Get audio URL for a specific ayah and reciter
  String getAudioUrl({
    required String reciterId,
    required int surahNumber,
    required int ayahNumber,
  }) {
    return _repository.getAudioUrl(reciterId, surahNumber, ayahNumber);
  }

  /// Fetch all athans
  Future<List<Athan>> getAthans() => _repository.getAthans();

  /// Search
  Future<List<dynamic>> search(String query, String type) =>
      _repository.search(query, type);

  /// Get SVG page URL (for future use when API supports it)
  String getSvgPageUrl(int pageNumber) => _repository.getSvgPageUrl(pageNumber);

  /// Fetch SVG page content
  Future<String> fetchSvgPageContent(int pageNumber) =>
      _repository.fetchSvgPageContent(pageNumber);
}
