import 'package:get/get.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class PrayerController extends GetxController {
  final Rx<PrayerTimes?> prayerTimes = Rx<PrayerTimes?>(null);
  final Rx<Qibla?> qiblaDirection = Rx<Qibla?>(null);
  final Rx<Coordinates?> coordinates = Rx<Coordinates?>(null);
  final RxString locationName = 'loading'.tr.obs;
  final RxBool isLoading = true.obs;
  final RxString nextPrayerName = ''.obs;
  final Rx<Duration> timeToNextPrayer = Duration.zero.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _initLocationAndPrayers();
    _startTimer();
  }

  void retry() {
    _initLocationAndPrayers();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (prayerTimes.value != null) {
        _updateNextPrayer();
      }
    });
  }

  Future<void> _initLocationAndPrayers() async {
    try {
      isLoading.value = true;

      // Check permissions
      LocationPermission permission;
      try {
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            debugPrint('Location permission denied');
            _setDefaultLocation();
            return;
          }
        }

        if (permission == LocationPermission.deniedForever) {
          debugPrint('Location permission denied forever');
          _setDefaultLocation();
          return;
        }

        // Get Position with timeout
        // Add artificial delay to show loading state purely for UX if needed, but removed for speed.
        final position =
            await Geolocator.getCurrentPosition(
              timeLimit: const Duration(seconds: 4),
            ).onError((error, stackTrace) {
              debugPrint('Geolocator error or timeout: $error');
              throw Exception('Location timeout');
            });

        coordinates.value = Coordinates(position.latitude, position.longitude);
        locationName.value = 'current_location'.tr;
      } catch (e) {
        debugPrint('General location error: $e');
        // Fallback is CRITICAL
        _setDefaultLocation();
        return; // setDefault calls calculatePrayerTimes
      }

      calculatePrayerTimes();
    } catch (e) {
      debugPrint('Error getting location (Outer): $e');
      _setDefaultLocation();
    } finally {
      isLoading.value = false;
    }
  }

  void _setDefaultLocation() {
    // Default to Mecca
    coordinates.value = Coordinates(21.4225, 39.8262);
    locationName.value =
        'المنطقة الافتراضية (مكة المكرمة)'; // Or generic "Mecca" key
    calculatePrayerTimes();
    isLoading.value = false;
  }

  final RxString errorMessage = ''.obs;

  void calculatePrayerTimes() {
    errorMessage.value = '';
    if (coordinates.value == null) {
      errorMessage.value = 'Coordinates key is null';
      debugPrint('Error: Coordinates are null');
      return;
    }

    try {
      final date = DateComponents.from(DateTime.now());
      final params = CalculationMethod.egyptian.getParameters();
      params.madhab = Madhab.shafi;

      prayerTimes.value = PrayerTimes(coordinates.value!, date, params);
      qiblaDirection.value = Qibla(coordinates.value!);

      _updateNextPrayer();
    } catch (e) {
      errorMessage.value = 'Failed to calculate: $e';
      debugPrint('Error calculating prayer times: $e');
    }
  }

  void _updateNextPrayer() {
    if (prayerTimes.value == null) return;

    final next = prayerTimes.value!.nextPrayer();
    final now = DateTime.now();
    DateTime? nextTime;

    if (next == Prayer.none) {
      // Next is Fajr tomorrow
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final date = DateComponents.from(tomorrow);
      final params = CalculationMethod.egyptian.getParameters();
      final nextDayPrayers = PrayerTimes(coordinates.value!, date, params);
      nextTime = nextDayPrayers.fajr;
      nextPrayerName.value = 'fajr';
    } else {
      nextTime = prayerTimes.value!.timeForPrayer(next);
      nextPrayerName.value = next.name; // Will need translation mapping
    }

    if (nextTime != null) {
      final diff = nextTime.difference(now);
      timeToNextPrayer.value = diff.isNegative ? Duration.zero : diff;
    }
  }

  String get formattedNextPrayerTime {
    final duration = timeToNextPrayer.value;
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
