import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/reciter_model.dart';

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
  final RxString currentReciterId = 'alafasy'.obs;

  // Repeat range (for range mode)
  int? repeatRangeStart;
  int? repeatRangeEnd;
  int? repeatRangeSurah;

  // Available Reciters
  final List<Reciter> availableReciters = [
    Reciter(
      id: 'alafasy',
      nameAr: 'مشاري بن راشد العفاسي',
      nameEn: 'Mishary Rashid Alafasy',
      folder: 'Alafasy_128kbps',
      description: 'قراءة مرتلة واضحة',
    ),
    Reciter(
      id: 'husary',
      nameAr: 'محمود خليل الحصري',
      nameEn: 'Mahmoud Khalil Al-Hussary',
      folder: 'Husary_128kbps',
      description: 'قراءة مجودة كلاسيكية',
    ),
    Reciter(
      id: 'minshawy',
      nameAr: 'محمد صديق المنشاوي',
      nameEn: 'Mohamed Siddiq Al-Minshawi',
      folder: 'Minshawy_Murattal_128kbps',
      description: 'قراءة مرتلة عذبة',
    ),
    Reciter(
      id: 'sudais',
      nameAr: 'عبدالرحمن السديس',
      nameEn: 'Abdurrahman As-Sudais',
      folder: 'Abdurrahmaan_As-Sudais_192kbps',
      description: 'إمام الحرم المكي',
    ),
    Reciter(
      id: 'shuraim',
      nameAr: 'سعود الشريم',
      nameEn: 'Saood Ash-Shuraim',
      folder: 'Saood_ash-Shuraym_128kbps',
      description: 'إمام الحرم المكي',
    ),
    Reciter(
      id: 'ajmi',
      nameAr: 'أحمد بن علي العجمي',
      nameEn: 'Ahmad Al-Ajmi',
      folder: 'Ahmed_ibn_Ali_al-Ajamy_128kbps_ketaballah.net',
      description: 'قراءة مؤثرة',
    ),
    Reciter(
      id: 'ghamadi',
      nameAr: 'سعد الغامدي',
      nameEn: 'Saad Al-Ghamdi',
      folder: 'Ghamadi_40kbps',
      description: 'قراءة هادئة',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _initAudioSession();

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

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  /// Get current reciter
  Reciter get currentReciter {
    return availableReciters.firstWhere(
      (r) => r.id == currentReciterId.value,
      orElse: () => availableReciters[0],
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

      // Format: http://everyayah.com/data/{Reciter}/{Surah3Digits}{Ayah3Digits}.mp3
      final String surahStr = surah.toString().padLeft(3, '0');
      final String ayahStr = ayah.toString().padLeft(3, '0');
      final String url =
          'http://everyayah.com/data/${currentReciter.folder}/$surahStr$ayahStr.mp3';

      await _player.setUrl(url);
      await _player.setSpeed(playbackSpeed.value);
      await _player.play();
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

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}
