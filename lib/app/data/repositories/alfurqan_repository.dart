import '../models/reciter_model.dart';
import '../models/surah_model.dart';
import '../models/athan_model.dart';
import '../providers/alfurqan_provider.dart';

class AlFurqanRepository {
  final AlFurqanProvider provider;

  AlFurqanRepository({required this.provider});

  Future<List<Reciter>> getReciters() => provider.getReciters();
  Future<Reciter> getReciter(String id) => provider.getReciter(id);
  Future<List<Surah>> getSurahs() => provider.getSurahs();
  Future<Surah> getSurah(int number) => provider.getSurah(number);
  String getAudioUrl(String reciterId, int surahNumber, int ayahNumber) =>
      provider.getAudioUrl(reciterId, surahNumber, ayahNumber);
  Future<List<Athan>> getAthans() => provider.getAthans();
  Future<List<dynamic>> search(String query, String type) =>
      provider.search(query, type);

  // SVG Pages
  String getSvgPageUrl(int pageNumber) => provider.getSvgPageUrl(pageNumber);
  Future<String> fetchSvgPageContent(int pageNumber) =>
      provider.fetchSvgPageContent(pageNumber);
}
