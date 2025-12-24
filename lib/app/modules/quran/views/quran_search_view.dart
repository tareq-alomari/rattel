import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/quran_search_controller.dart';
import '../controllers/quran_controller.dart';
import '../../../data/models/quran_models.dart';
import 'quran_reader_view.dart';

/// Advanced Quran search view
class QuranSearchView extends StatefulWidget {
  const QuranSearchView({super.key});

  @override
  State<QuranSearchView> createState() => _QuranSearchViewState();
}

class _QuranSearchViewState extends State<QuranSearchView> {
  late final QuranSearchController searchController;
  late final QuranController quranController;
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController = Get.put(QuranSearchController());
    quranController = Get.find<QuranController>();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Quran'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Search in Quran...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() {
                  if (searchController.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        textController.clear();
                        searchController.clearSearch();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) => searchController.search(value),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search options
          _buildSearchOptions(),

          // Results count
          Obx(() {
            if (searchController.searchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Text(
                    searchController.getResultCountText(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            );
          }),

          // Search results or history
          Expanded(
            child: Obx(() {
              if (searchController.isSearching.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (searchController.searchQuery.value.isEmpty) {
                return _buildSearchHistory();
              }

              if (searchController.searchResults.isEmpty) {
                return _buildEmptyState();
              }

              return _buildSearchResults();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search mode selector
          Obx(() {
            return Row(
              children: [
                _buildModeChip('Arabic', 'arabic'),
                const SizedBox(width: 8),
                _buildModeChip('Translation', 'translation'),
                const SizedBox(width: 8),
                _buildModeChip('All', 'all'),
              ],
            );
          }),

          const SizedBox(height: 12),

          // Filters
          Row(
            children: [
              // Language selector (for translation mode)
              Obx(() {
                if (searchController.searchMode.value != 'arabic') {
                  return Expanded(child: _buildLanguageSelector());
                }
                return const SizedBox.shrink();
              }),

              const SizedBox(width: 8),

              // Surah filter
              Expanded(child: _buildSurahFilter()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip(String label, String mode) {
    final isSelected = searchController.searchMode.value == mode;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => searchController.changeSearchMode(mode),
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildLanguageSelector() {
    return Obx(() {
      return DropdownButtonFormField<String>(
        initialValue: searchController.selectedLanguage.value,
        decoration: InputDecoration(
          labelText: 'Language',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: quranController.availableLanguages.map((lang) {
          return DropdownMenuItem(
            value: lang,
            child: Text(quranController.getLanguageName(lang)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            searchController.changeLanguage(value);
          }
        },
      );
    });
  }

  Widget _buildSurahFilter() {
    return Obx(() {
      return DropdownButtonFormField<int>(
        initialValue: searchController.filterSurah.value,
        decoration: InputDecoration(
          labelText: 'Surah',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: [
          const DropdownMenuItem(value: 0, child: Text('All Surahs')),
          ...quranController.surahs.map((surah) {
            return DropdownMenuItem(
              value: surah.surahNumber,
              child: Text('${surah.surahNumber}. ${surah.surahName}'),
            );
          }),
        ],
        onChanged: (value) {
          if (value != null) {
            searchController.setSurahFilter(value);
          }
        },
      );
    });
  }

  Widget _buildSearchHistory() {
    return Obx(() {
      if (searchController.searchHistory.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Search for verses in the Quran',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                TextButton(
                  onPressed: searchController.clearHistory,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchController.searchHistory.length,
              itemBuilder: (context, index) {
                final query = searchController.searchHistory[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(query),
                  onTap: () {
                    textController.text = query;
                    searchController.search(query);
                  },
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or search mode',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchController.searchResults.length,
      itemBuilder: (context, index) {
        final ayah = searchController.searchResults[index];
        return _buildResultCard(ayah);
      },
    );
  }

  Widget _buildResultCard(Ayah ayah) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Get.to(
            () => QuranReaderView(
              surahNumber: ayah.surahNumber,
              initialAyahNumber: ayah.ayahNumber,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Surah info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${ayah.surahName} ${ayah.ayahNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Arabic text
              Text(
                ayah.ayahText,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(fontSize: 20, height: 1.8),
              ),

              // Translation (if available)
              if (ayah.translations != null && ayah.translations!.isNotEmpty)
                ...ayah.translations!.entries.take(1).map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
