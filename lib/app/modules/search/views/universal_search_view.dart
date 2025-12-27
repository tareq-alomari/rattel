import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/app_drawer.dart';

/// Universal Search View for Quran and Hadith
class UniversalSearchView extends StatefulWidget {
  const UniversalSearchView({super.key});

  @override
  State<UniversalSearchView> createState() => _UniversalSearchViewState();
}

class _UniversalSearchViewState extends State<UniversalSearchView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'hadith'; // 'hadith' or 'quran'
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'البحث',
          style: GoogleFonts.cairo(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle
            Text(
              'ابحث في القرآن والأحاديث',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            // Search Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search Input
                  TextField(
                    controller: _searchController,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن آية أو حديث...',
                      hintStyle: GoogleFonts.cairo(color: Colors.grey.shade400),
                      suffixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _isSearching = value.isNotEmpty;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tabs
            Row(
              children: [
                Expanded(
                  child: _TabButton(
                    title: 'الأحاديث',
                    icon: Icons.menu_book,
                    isSelected: _selectedTab == 'hadith',
                    onTap: () {
                      setState(() {
                        _selectedTab = 'hadith';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TabButton(
                    title: 'القرآن',
                    icon: Icons.book,
                    isSelected: _selectedTab == 'quran',
                    onTap: () {
                      setState(() {
                        _selectedTab = 'quran';
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Empty State
            if (!_isSearching)
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.search, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'ابدأ البحث للحصول على النتائج',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            // Search Results (placeholder)
            if (_isSearching) ...[
              Text(
                'النتائج',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildResultCard(
                'نتيجة البحث 1',
                'هذا نص تجريبي لنتيجة البحث الأولى',
              ),
              const SizedBox(height: 12),
              _buildResultCard(
                'نتيجة البحث 2',
                'هذا نص تجريبي لنتيجة البحث الثانية',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF059669) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF059669) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
