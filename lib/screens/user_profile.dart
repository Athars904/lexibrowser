import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lexibrowser/controllers/profile_controller.dart';
import 'dart:io';
import 'package:lexibrowser/screens/browser_screen.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ProfileController profileController = Get.find();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          color: Colors.white54,
          child: Column(
            children: [
              const SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Obx(() {
                      return CircleAvatar(
                        maxRadius: 65,
                        backgroundImage: profileController.profileImagePath.value.isNotEmpty
                            ? FileImage(File(profileController.profileImagePath.value))
                            : AssetImage("assets/images/vpn2.png") as ImageProvider,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Obx(() {
                return profileController.userName.value.isEmpty
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "Enter your name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onSubmitted: (value) {
                      profileController.saveProfile(value, profileController.description.value, profileController.profileImagePath.value);
                    },
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      profileController.userName.value,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Obx(() {
                  return TextField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: profileController.description.value.isEmpty
                          ? "Enter your description"
                          : profileController.description.value,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (value) {
                      profileController.description.value = value;
                    },
                    onSubmitted: (value) {
                      profileController.saveProfile(
                        profileController.userName.value,
                        value,
                        profileController.profileImagePath.value,
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView(
                  children: [
                    Card(
                      margin: const EdgeInsets.only(left: 35, right: 35, bottom: 10),
                      color: Colors.white70,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      child: const ListTile(
                        leading: Icon(Icons.privacy_tip_sharp, color: Colors.black54),
                        title: Text('Privacy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        trailing: Icon(Icons.arrow_forward_ios_outlined, color: Colors.black54),
                      ),
                    ),

                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        Get.to(() => BrowserPage());
                      },
                      child: Card(
                        color: Colors.white70,
                        margin: const EdgeInsets.only(left: 35, right: 35, bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        child: const ListTile(
                          leading: Icon(Icons.home, color: Colors.black54),
                          title: Text('Home Page', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          trailing: Icon(Icons.arrow_forward_ios_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileController.saveProfile(
        profileController.userName.value,
        profileController.description.value,
        pickedFile.path,
      );
    }
  }
}
