import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/services/audio_service.dart';
import '../../../data/models/reciter_model.dart';

class AudioSettingsView extends StatelessWidget {
  const AudioSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = AudioService.to;

    return Scaffold(
      appBar: AppBar(title: Text('audio_settings'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Reciter Selection
          Text(
            'select_reciter'.tr,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Obx(() {
            return Column(
              children: audioService.availableReciters.map((reciter) {
                final isSelected =
                    audioService.currentReciterId.value == reciter.id;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isSelected ? 4 : 1,
                  color: isSelected
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                      : null,
                  child: ListTile(
                    leading: Icon(
                      isSelected ? Icons.radio_button_checked : Icons.person,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    title: Text(
                      reciter.nameAr,
                      style: GoogleFonts.cairo(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      reciter.description ?? reciter.nameEn,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                    onTap: () {
                      audioService.changeReciter(reciter.id);
                      Get.snackbar(
                        'تم التغيير',
                        'تم اختيار القارئ: ${reciter.nameAr}',
                        duration: const Duration(seconds: 2),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 32),

          // Playback Speed
          Text(
            'playback_speed'.tr,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Obx(() {
            return Column(
              children: [
                Slider(
                  value: audioService.playbackSpeed.value,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  label:
                      '${audioService.playbackSpeed.value.toStringAsFixed(1)}x',
                  onChanged: (value) {
                    audioService.setPlaybackSpeed(value);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0.5x', style: const TextStyle(fontSize: 12)),
                    Text(
                      '${audioService.playbackSpeed.value.toStringAsFixed(1)}x',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text('2.0x', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
                    final isSelected =
                        audioService.playbackSpeed.value == speed;
                    return ChoiceChip(
                      label: Text('${speed}x'),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          audioService.setPlaybackSpeed(speed);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            );
          }),

          const SizedBox(height: 32),

          // Repeat Mode
          Text('repeat_mode'.tr, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Obx(() {
            return Column(
              children: [
                RadioListTile<RepeatMode>(
                  title: Text('no_repeat'.tr),
                  subtitle: Text('play_once'.tr),
                  value: RepeatMode.none,
                  // ignore: deprecated_member_use
                  groupValue: audioService.repeatMode.value,
                  // ignore: deprecated_member_use
                  onChanged: (value) {
                    if (value != null) {
                      audioService.setRepeatMode(value);
                    }
                  },
                ),
                RadioListTile<RepeatMode>(
                  title: Text('repeat_ayah'.tr),
                  subtitle: Text('repeat_current_ayah'.tr),
                  value: RepeatMode.ayah,
                  // ignore: deprecated_member_use
                  groupValue: audioService.repeatMode.value,
                  // ignore: deprecated_member_use
                  onChanged: (value) {
                    if (value != null) {
                      audioService.setRepeatMode(value);
                    }
                  },
                ),
                RadioListTile<RepeatMode>(
                  title: Text('repeat_range'.tr),
                  subtitle: Text('repeat_ayah_range'.tr),
                  value: RepeatMode.range,
                  // ignore: deprecated_member_use
                  groupValue: audioService.repeatMode.value,
                  // ignore: deprecated_member_use
                  onChanged: (value) {
                    if (value != null) {
                      audioService.setRepeatMode(value);
                      _showRangeDialog(context, audioService);
                    }
                  },
                ),
              ],
            );
          }),

          const SizedBox(height: 32),

          // Test Audio Button
          ElevatedButton.icon(
            onPressed: () {
              // Play Al-Fatiha verse 1 as test
              audioService.playAyah(1, 1);
            },
            icon: const Icon(Icons.play_arrow),
            label: Text('test_audio'.tr),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ],
      ),
    );
  }

  void _showRangeDialog(BuildContext context, AudioService audioService) {
    final startController = TextEditingController(
      text: audioService.repeatRangeStart?.toString() ?? '1',
    );
    final endController = TextEditingController(
      text: audioService.repeatRangeEnd?.toString() ?? '7',
    );

    Get.defaultDialog(
      title: 'set_repeat_range'.tr,
      content: Column(
        children: [
          TextField(
            controller: startController,
            decoration: InputDecoration(labelText: 'start_ayah'.tr),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: endController,
            decoration: InputDecoration(labelText: 'end_ayah'.tr),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      textConfirm: 'confirm'.tr,
      textCancel: 'cancel'.tr,
      onConfirm: () {
        final start = int.tryParse(startController.text) ?? 1;
        final end = int.tryParse(endController.text) ?? 7;
        if (start <= end) {
          audioService.setRepeatRange(
            audioService.currentSurah.value > 0
                ? audioService.currentSurah.value
                : 1,
            start,
            end,
          );
          Get.back();
        } else {
          Get.snackbar('خطأ', 'رقم البداية يجب أن يكون أقل من النهاية');
        }
      },
    );
  }
}
