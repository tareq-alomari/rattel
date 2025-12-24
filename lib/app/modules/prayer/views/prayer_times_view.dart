import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Prayer Times View - Placeholder
class PrayerTimesView extends StatelessWidget {
  const PrayerTimesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('prayer_times'.tr)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'prayer_times'.tr,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'coming_soon'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 32),
            _buildPrayerTimeCard(context, 'fajr'.tr, '--:--'),
            _buildPrayerTimeCard(context, 'dhuhr'.tr, '--:--'),
            _buildPrayerTimeCard(context, 'asr'.tr, '--:--'),
            _buildPrayerTimeCard(context, 'maghrib'.tr, '--:--'),
            _buildPrayerTimeCard(context, 'isha'.tr, '--:--'),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeCard(
    BuildContext context,
    String prayer,
    String time,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: ListTile(
          leading: Icon(
            Icons.mosque,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(prayer),
          trailing: Text(
            time,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
