import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/prayer_controller.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class PrayerTimesView extends StatelessWidget {
  const PrayerTimesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrayerController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('prayer_times'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.orange, size: 48),
                const SizedBox(height: 16),
                Text('error_loading_prayers'.tr),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => controller.onInit(), // Re-trigger init
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final prayers = controller.prayerTimes.value;
        if (prayers == null) {
          // Should be caught by errorMessage check above usually, but just in case
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('error_loading_prayers'.tr),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.onInit(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Top Card: Countdown
            Container(
              margin: const EdgeInsets.all(16),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage(
                    'assets/images/islamic_pattern.png',
                  ), // Placeholder or just gradient
                  opacity: 0.1,
                  fit: BoxFit.cover,
                ),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1B5E20), // Dark Green
                    theme.colorScheme.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            controller.locationName.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'next_prayer'.tr,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getPrayerName(controller.nextPrayerName.value),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black26,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.formattedNextPrayerTime,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48, // Larger
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),

            // Prayer List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildPrayerTile(
                    context,
                    'fajr',
                    prayers.fajr,
                    controller.nextPrayerName.value == 'fajr',
                  ),
                  _buildPrayerTile(context, 'sunrise', prayers.sunrise, false),
                  _buildPrayerTile(
                    context,
                    'dhuhr',
                    prayers.dhuhr,
                    controller.nextPrayerName.value == 'dhuhr',
                  ),
                  _buildPrayerTile(
                    context,
                    'asr',
                    prayers.asr,
                    controller.nextPrayerName.value == 'asr',
                  ),
                  _buildPrayerTile(
                    context,
                    'maghrib',
                    prayers.maghrib,
                    controller.nextPrayerName.value == 'maghrib',
                  ),
                  _buildPrayerTile(
                    context,
                    'isha',
                    prayers.isha,
                    controller.nextPrayerName.value == 'isha',
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPrayerTile(
    BuildContext context,
    String prayerKey,
    DateTime time,
    bool isNext,
  ) {
    final theme = Theme.of(context);
    final timeStr = DateFormat.jm().format(time);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isNext ? theme.primaryColor.withOpacity(0.1) : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isNext ? Border.all(color: theme.primaryColor) : null,
      ),
      child: ListTile(
        leading: Icon(
          _getPrayerIcon(prayerKey),
          color: isNext ? theme.primaryColor : Colors.grey,
        ),
        title: Text(
          prayerKey.tr, // Ensure keys exist
          style: TextStyle(
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
            color: isNext ? theme.primaryColor : null,
          ),
        ),
        trailing: Text(
          timeStr,
          style: TextStyle(
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
            color: isNext ? theme.primaryColor : null,
          ),
        ),
      ),
    );
  }

  IconData _getPrayerIcon(String key) {
    switch (key) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'sunrise':
        return Icons.wb_sunny;
      case 'dhuhr':
        return Icons.wb_sunny_outlined;
      case 'asr':
        return Icons.cloud_queue;
      case 'maghrib':
        return Icons.nights_stay_outlined;
      case 'isha':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }

  String _getPrayerName(String key) {
    // Basic mapping, assuming keys match enum names or manual strings
    return key.toLowerCase().tr;
  }
}
