import 'package:get/get.dart';
import '../../../data/models/hadith.dart';
import '../../../data/models/hadith_book.dart';
import '../../../data/repositories/hadith_repository.dart';
import '../../../data/services/hadith_database_service.dart';

class HadithController extends GetxController {
  final HadithRepository _repository;

  HadithController() : _repository = HadithRepository(HadithDatabaseService());

  final books = <HadithBook>[].obs;
  final isLoadingBooks = true.obs;

  // Selection
  final selectedBook = Rxn<HadithBook>();
  final hadiths = <Hadith>[].obs;
  final isLoadingHadiths = false.obs;

  // Pagination
  final int _pageSize = 20;
  int _currentPage = 0;
  bool _hasMore = true;

  // Search
  final searchQuery = ''.obs;
  final searchResults = <Hadith>[].obs;
  final isSearching = false.obs;

  // Memorization
  final memorizedHadithIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadBooks();
    loadMemorizedHadiths();

    // Debounce search
    debounce(
      searchQuery,
      (query) => _performSearch(query),
      time: const Duration(milliseconds: 500),
    );
  }

  void search(String query) {
    searchQuery.value = query;
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      isSearching.value = true;
      final results = await _repository.search(query);
      searchResults.assignAll(results);
    } catch (e) {
      print('Error searching hadiths: $e');
    } finally {
      isSearching.value = false;
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
  }

  Future<void> toggleFavorite(Hadith hadith) async {
    try {
      final newStatus = !hadith.isFavorite;

      // Updates in lists
      _updateHadithInList(hadiths, hadith, newStatus);
      _updateHadithInList(searchResults, hadith, newStatus);

      await _repository.toggleFavorite(hadith.id!, newStatus);
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  void _updateHadithInList(RxList<Hadith> list, Hadith hadith, bool newStatus) {
    final index = list.indexWhere((h) => h.id == hadith.id);
    if (index != -1) {
      list[index] = Hadith(
        id: hadith.id,
        bookId: hadith.bookId,
        hadithNumber: hadith.hadithNumber,
        text: hadith.text,
        explanation: hadith.explanation,
        searchTerm: hadith.searchTerm,
        isFavorite: newStatus,
        pageNumber: hadith.pageNumber,
      );
    }
  }

  // --- Memorization Logic ---

  Future<void> loadMemorizedHadiths() async {
    try {
      final ids = await _repository.getMemorizedHadithIds();
      memorizedHadithIds.assignAll(ids);
    } catch (e) {
      print('Error loading memorized hadiths: $e');
    }
  }

  bool isMemorized(int hadithId) => memorizedHadithIds.contains(hadithId);

  Future<void> toggleMemorization(int hadithId) async {
    if (memorizedHadithIds.contains(hadithId)) {
      memorizedHadithIds.remove(hadithId);
    } else {
      memorizedHadithIds.add(hadithId);
    }
    await _repository.toggleMemorization(hadithId);
  }

  Future<void> loadBooks() async {
    try {
      isLoadingBooks.value = true;
      print('📚 Loading hadith books...');
      final result = await _repository.getBooks();
      print('📚 Loaded ${result.length} hadith books');
      books.assignAll(result);
      if (result.isEmpty) {
        print('⚠️ No hadith books found in database!');
      }
    } catch (e) {
      print('❌ Error loading books: $e');
    } finally {
      isLoadingBooks.value = false;
    }
  }

  Future<void> selectBook(HadithBook book) async {
    selectedBook.value = book;
    hadiths.clear();
    _currentPage = 0;
    _hasMore = true;
    await loadHadiths();
  }

  Future<void> loadHadiths() async {
    if (!_hasMore || isLoadingHadiths.value) return;
    if (selectedBook.value == null) return;

    try {
      isLoadingHadiths.value = true;
      final newHadiths = await _repository.getHadithsByBook(
        selectedBook.value!.id!,
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      if (newHadiths.length < _pageSize) {
        _hasMore = false;
      }

      hadiths.addAll(newHadiths);
      _currentPage++;
    } catch (e) {
      print('Error loading hadiths: $e');
    } finally {
      isLoadingHadiths.value = false;
    }
  }
}
