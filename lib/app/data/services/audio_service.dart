import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import '../models/reciter_model.dart';
import 'al_furqan_service.dart';

class AudioService extends GetxService {
  static AudioService get to => Get.find();

  final AudioPlayer _player = AudioPlayer();

  // State
  final RxInt currentSurah = 0.obs;
  final RxInt currentAyah = 0.obs;
  final RxBool isPlaying = false.obs;
  final RxBool isBuffering = false.obs;

  // Advanced Features
  final RxDouble playbackSpeed = 1.0.obs;
  final Rx<RepeatMode> repeatMode = RepeatMode.none.obs;
  final RxString currentReciterId = 'mishary_rashid_alafasy'.obs;

  // Repeat range (for range mode)
  int? repeatRangeStart;
  int? repeatRangeEnd;
  int? repeatRangeSurah;

  // Available Reciters
  // Available Reciters (Loaded from API)
  final RxList<Reciter> availableReciters = <Reciter>[].obs;

  // Default Reciter (Mishary)
  final Reciter _defaultReciter = Reciter(
    id: 'mishary_rashid_alafasy',
    name: 'Mishary Rashid Alafasy',
    arabicName: 'مشاري راشد العفاسي',
  );

  @override
  void onInit() {
    super.onInit();
    _initAudioSession();
    _loadReciters();

    // Listen to player state
    _player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      isBuffering.value =
          state.processingState == ProcessingState.buffering ||
          state.processingState == ProcessingState.loading;

      if (state.processingState == ProcessingState.completed) {
        isPlaying.value = false;
        _handlePlaybackCompleted();
      }
    });
  }

  // Event trigger for completion
  final Rxn<void> playbackCompleted = Rxn<void>();

  Future<void> _loadReciters() async {
    try {
      // Ensure service is initialized
      if (!Get.isRegistered<AlFurqanService>()) {
        Get.put(AlFurqanService());
      }

      final reciters = await AlFurqanService.to.getReciters();
      if (reciters.isNotEmpty) {
        availableReciters.assignAll(reciters);
      }
    } catch (e) {
      debugPrint('Error loading reciters: $e');
      // Optionally show a snackbar or retry logic
    }
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  /// Get current reciter
  Reciter get currentReciter {
    return availableReciters.firstWhere(
      (r) => r.id == currentReciterId.value,
      orElse: () => _defaultReciter,
    );
  }

  /// Change reciter
  Future<void> changeReciter(String reciterId) async {
    currentReciterId.value = reciterId;
    // If currently playing, restart with new reciter
    if (isPlaying.value && currentSurah.value > 0) {
      await playAyah(currentSurah.value, currentAyah.value);
    }
  }

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    if (speed >= 0.5 && speed <= 2.0) {
      playbackSpeed.value = speed;
      await _player.setSpeed(speed);
    }
  }

  /// Set repeat mode
  void setRepeatMode(RepeatMode mode) {
    repeatMode.value = mode;
  }

  /// Set repeat range (for range mode)
  void setRepeatRange(int surah, int startAyah, int endAyah) {
    repeatRangeSurah = surah;
    repeatRangeStart = startAyah;
    repeatRangeEnd = endAyah;
  }

  /// Handle playback completion based on repeat mode
  void _handlePlaybackCompleted() {
    switch (repeatMode.value) {
      case RepeatMode.ayah:
        // Repeat the same ayah
        if (currentSurah.value > 0 && currentAyah.value > 0) {
          Future.delayed(const Duration(milliseconds: 500), () {
            playAyah(currentSurah.value, currentAyah.value);
          });
        }
        break;

      case RepeatMode.range:
        // Play next ayah in range or loop back
        if (repeatRangeSurah != null &&
            repeatRangeStart != null &&
            repeatRangeEnd != null) {
          if (currentAyah.value < repeatRangeEnd!) {
            Future.delayed(const Duration(milliseconds: 500), () {
              playAyah(currentSurah.value, currentAyah.value + 1);
            });
          } else {
            // Loop back to start
            Future.delayed(const Duration(milliseconds: 500), () {
              playAyah(repeatRangeSurah!, repeatRangeStart!);
            });
          }
        }
        break;

      case RepeatMode.none:
        playbackCompleted.trigger(null);
        break;
    }
  }

  /// Play specific Ayah
  Future<void> playAyah(int surah, int ayah) async {
    try {
      // Update state for UI highlighting
      currentSurah.value = surah;
      currentAyah.value = ayah;

      // Stop current if playing
      await _player.stop();

      // Use AlFurqan API
      if (!Get.isRegistered<AlFurqanService>()) {
        Get.put(AlFurqanService());
      }

      final String url = AlFurqanService.to.getAudioUrl(
        reciterId: currentReciterId.value,
        surahNumber: surah,
        ayahNumber: ayah,
      );

      debugPrint('Playing URL: $url');
      try {
        await _player.setUrl(url);
        await _player.setSpeed(playbackSpeed.value);
        await _player.play();
      } catch (e) {
        debugPrint('Error in setUrl or play: $e');
      }
    } catch (e) {
      // Use logger instead of print in production
      Get.snackbar('خطأ', 'فشل تشغيل الصوت: $e');
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
    currentSurah.value = 0;
    currentAyah.value = 0;
  }

  /// Play audio from direct URL (for Athan, etc.)
  Future<void> playUrl(String url) async {
    try {
      // Stop current if playing
      await _player.stop();

      debugPrint('Playing URL: $url');
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تشغيل الصوت: $e');
      rethrow;
    }
  }

  Future<void> playAthan(String athanId) async {
    try {
      // Stop current if playing
      await _player.stop();

      // Use AlFurqan API to get list (since we don't have a direct "get athan url" method separately that takes ID only without fetching list,
      // but actually the API endpoint for streaming is /athan/:id.
      // The provider/repo should support getting that URL or we construct it.
      // Looking at provider, we only have getAthans().
      // The API says: GET /api/v1/athan/:id to stream.
      // So the URL is https://alfurqan.online/api/v1/athan/$athanId

      const baseUrl = 'https://alfurqan.online/api/v1';
      final url = '$baseUrl/athan/$athanId';

      debugPrint('Playing Athan URL: $url');
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تشغيل الآذان: $e');
    }
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}
