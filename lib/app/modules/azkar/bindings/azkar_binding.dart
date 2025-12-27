import 'package:get/get.dart';
import '../controllers/azkar_controller.dart';

class AzkarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AzkarController>(() => AzkarController());
  }
}
