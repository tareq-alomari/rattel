import 'package:get/get.dart';
import '../controllers/allah_names_controller.dart';

class AllahNamesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllahNamesController>(() => AllahNamesController());
  }
}
