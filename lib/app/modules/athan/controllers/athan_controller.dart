import 'package:get/get.dart';
import '../../../data/models/athan_model.dart';
import '../../../data/services/audio_service.dart';
import '../../../data/services/al_furqan_service.dart';

class AthanController extends GetxController {
  final RxList<Athan> athans = <Athan>[].obs;
  final RxBool isLoading = true.obs;
  final RxString selectedMuezzin = ''.obs;
  final RxString currentAthanId = ''.obs;
  final RxBool isPlaying = false.obs;

  // Computed list based on filters if needed (e.g. by Muezzin)
  // For now, just show all.

  @override
  void onInit() {
    super.onInit();
    loadAthans();
  }

  Future<void> loadAthans() async {
    try {
      isLoading.value = true;
      // Ensure AlFurqanService is available
      if (!Get.isRegistered<AlFurqanService>()) {
        Get.put(AlFurqanService());
      }
      athans.value = await AlFurqanService.to.getAthans();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load athans: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> playAthan(Athan athan) async {
    try {
      currentAthanId.value = athan.id;
      isPlaying.value = true;
      await AudioService.to.playUrl(athan.audioUrl);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل تشغيل الأذان: $e');
      currentAthanId.value = '';
      isPlaying.value = false;
    }
  }

  Future<void> pauseAthan() async {
    isPlaying.value = false;
    await AudioService.to.pause();
  }

  Future<void> stopAthan() async {
    currentAthanId.value = '';
    isPlaying.value = false;
    await AudioService.to.stop();
  }
}
