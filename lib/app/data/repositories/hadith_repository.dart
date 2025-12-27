import '../models/hadith.dart';
import '../models/hadith_book.dart';
import '../services/hadith_database_service.dart';

class HadithRepository {
  final HadithDatabaseService _service;

  HadithRepository(this._service);

  Future<List<HadithBook>> getBooks() {
    return _service.getAllBooks();
  }

  Future<List<Hadith>> getHadithsByBook(
    int bookId, {
    int limit = 20,
    int offset = 0,
  }) {
    return _service.getHadithsByBook(bookId, limit: limit, offset: offset);
  }

  Future<List<Hadith>> search(String query) {
    return _service.searchHadiths(query);
  }

  Future<void> toggleFavorite(int hadithId, bool isFavorite) {
    return _service.updateHadithFavoriteStatus(hadithId, isFavorite);
  }

  Future<void> toggleMemorization(int hadithId) {
    return _service.toggleMemorization(hadithId);
  }

  Future<bool> isMemorized(int hadithId) {
    return _service.isMemorized(hadithId);
  }

  Future<Set<int>> getMemorizedHadithIds() {
    return _service.getMemorizedHadithIds();
  }
}
