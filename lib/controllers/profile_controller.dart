import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  var userName = ''.obs;
  var description = ''.obs;
  var profileImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('userName') ?? 'Unknown';
    description.value = prefs.getString('description') ?? '';
    profileImagePath.value = prefs.getString('profileImagePath') ?? '';
  }

  Future<void> saveProfile(String name, String desc, String imagePath) async {
    userName.value = name;
    description.value = desc;
    profileImagePath.value = imagePath;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', userName.value);
    await prefs.setString('description', description.value);
    await prefs.setString('profileImagePath', profileImagePath.value);
  }
}
