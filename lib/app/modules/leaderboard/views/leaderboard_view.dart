import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/leaderboard_controller.dart';

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LeaderboardController());

    return Scaffold(
      appBar: AppBar(title: Text('leaderboard'.tr), centerTitle: true),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.leaderboard.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.leaderboard_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'no_leaderboard_data'.tr,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadLeaderboard,
          child: CustomScrollView(
            slivers: [
              // Top 3 Podium
              SliverToBoxAdapter(
                child: _buildPodium(context, controller.leaderboard),
              ),

              const SliverToBoxAdapter(child: Divider(height: 32)),

              // Remaining List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Start from index 3 (4th place)
                    if (index + 3 >= controller.leaderboard.length) return null;

                    final user = controller.leaderboard[index + 3];
                    return _buildLeaderboardTile(context, user, index + 4);
                  },
                  childCount: (controller.leaderboard.length - 3).clamp(0, 100),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPodium(BuildContext context, List<Map<String, dynamic>> users) {
    if (users.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (users.length > 1)
            Expanded(child: _buildPodiumPlace(context, users[1], 2, 140)),

          const SizedBox(width: 8),

          // 1st Place
          Expanded(child: _buildPodiumPlace(context, users[0], 1, 180)),

          const SizedBox(width: 8),

          // 3rd Place
          if (users.length > 2)
            Expanded(child: _buildPodiumPlace(context, users[2], 3, 120)),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(
    BuildContext context,
    Map<String, dynamic> user,
    int rank,
    double height,
  ) {
    Color color;
    switch (rank) {
      case 1:
        color = const Color(0xFFFFD700);
        break; // Gold
      case 2:
        color = const Color(0xFFC0C0C0);
        break; // Silver
      case 3:
        color = const Color(0xFFCD7F32);
        break; // Bronze
      default:
        color = Colors.grey;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.1),
          child: Text(
            user['name'][0].toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${user['total_verses']} ${'verses'.tr}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border(top: BorderSide(color: color, width: 4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$rank',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(
    BuildContext context,
    Map<String, dynamic> user,
    int rank,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Text(
          '$rank',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(user['name']),
      subtitle: Row(
        children: [
          Icon(
            Icons.verified,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text('${user['badges_count']} ${'badges'.tr}'),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${user['total_verses']} ${'verses_short'.tr}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
