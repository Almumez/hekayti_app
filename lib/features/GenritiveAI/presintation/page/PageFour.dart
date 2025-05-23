import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:hikayati_app/core/util/ScreenUtil.dart';
import 'package:hikayati_app/features/Regestrion/date/model/userMode.dart';

import '../../../../core/AppTheme.dart';
import '../../../../core/util/CharactersList.dart';
import '../../../../core/util/Common.dart';
import '../../../../core/widgets/CustomField.dart';
import '../../../../gen/assets.gen.dart';

import '../manager/StoryGenSettingsController.dart';

class PageFour extends StatefulWidget {
  const PageFour({Key? key}) : super(key: key);

  @override
  State<PageFour> createState() => _PageFourState();
}

class _PageFourState extends State<PageFour> {
  ScreenUtil screenUtil = ScreenUtil();
  String? selectedImagePath;
  CharactersList CharactersListobj = CharactersList();
  UserModel? userModel;

  @override
  Widget build(BuildContext context) {
    screenUtil.init(context);
    return GetBuilder<StoryGenSettingsController>(
      init: StoryGenSettingsController(),
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // CircleAvatar(
            //   maxRadius: 30,
            //   backgroundColor: Colors.white,
            //   child: Image.asset(Assets.images.logo.path),
            // ),
            // Text('حكايتي', style: AppTheme.textTheme.displaySmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: screenUtil.screenHeight * .4,
                  width: screenUtil.screenWidth * .2,
                  child:
                      Image.asset(CharactersListobj.happyListCharactersList[int.parse(userModel!.character.toString())]["image"]),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 50,),
                    Text('قم إدخال اسم بطل قصتك:',
                        style: AppTheme.textTheme.displaySmall),
                    SizedBox(
                      height: screenUtil.screenHeight * .05,
                    ),
                    CustomField(
                      size: 200,
                      onChanged: (value) {
                        controller.StoryName = value.toString();
                        controller.update();
                        print(controller.StoryName);
                      },
                      valdution: (value) {
                        if (value.toString().isEmpty) {
                          return 'يرجى منك ادخال اسم الطفل ';
                        } else if (!RegExp(
                                r"^([\u0600-\u065F\u066A-\u06EF\u06FA-\u06FFa-zA-Z]+)$")
                            .hasMatch(value)) {
                          return "لا يمكن ان يحتوي اسم الطفل على ارقام او رموز";
                        }
                        return null;
                      },
                      controler:
                          controller.StoryNameController, // Use a TextEditingController here
                      text: 'مثال  :  محمد',
                      type: TextInputType.text,
                    ),
                    
                    // SizedBox(
                    //   height: screenUtil.screenHeight * .05,
                    // ),
                    // Text('قم بإدخال عنوان القصة:',
                    //     style: AppTheme.textTheme.displaySmall),
                    // SizedBox(
                    //   height: screenUtil.screenHeight * .05,
                    // ),
                    // CustomField(
                    //   size: 200,
                    //   onChanged: (value) {
                    //     controller.StoryTopic = value.toString();
                    //     controller.update();
                    //   },
                    //   valdution: (value) {
                    //     if (value.toString().isEmpty) {
                    //       return 'يرجى منك ادخال عنوان القصة ';
                    //     }
                    //     return null;
                    //   },
                    //   controler: controller.StoryTopicController,
                    //   text: 'مثال  :  مغامرة في الغابة',
                    //   type: TextInputType.text,
                    // ),
                    
                    //
                    // Text('قم برفع صورة بطل قصتك:',
                    //     style: AppTheme.textTheme.displaySmall),
                    // SizedBox(
                    //   height: screenUtil.screenHeight * .05,
                    // ),
                    // Container(
                    //   width: 200,
                    //   child: InkWell(
                    //     onTap: () async {
                    //       final ImagePicker _picker = ImagePicker();
                    //       final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    //
                    //       if (image != null) {
                    //         setState(() {
                    //           selectedImagePath = image.path;
                    //         });
                    //         showImagesDialog(
                    //           context,
                    //           Assets.images.Characters.hasham.happy.path,
                    //           'تم اختيار الصورة بنجاح',
                    //           () {
                    //             Navigator.pop(context);
                    //           },
                    //         );
                    //       }
                    //     },
                    //     child: selectedImagePath != null
                    //         ? Container(
                    //             height: 100,
                    //             width: 100,
                    //             decoration: BoxDecoration(
                    //               shape: BoxShape.circle,
                    //               border: Border.all(
                    //                 color: AppTheme.primaryColor,
                    //                 width: 3,
                    //               ),
                    //             ),
                    //             child:CircleAvatar(
                    //               backgroundImage: FileImage(
                    //                 File(selectedImagePath!),
                    //
                    //               ),
                    //             ),
                    //           )
                    //         : Container(
                    //             height: 100,
                    //             width: 100,
                    //             decoration: BoxDecoration(
                    //               color: Colors.white,
                    //               shape: BoxShape.circle,
                    //               border: Border.all(
                    //                 width: 3,
                    //                 color: AppTheme.primarySwatch.shade200,
                    //               ),
                    //             ),
                    //             child: Column(
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 Icon(
                    //                   Icons.add_photo_alternate,
                    //                   color: AppTheme.primaryColor,
                    //                   size: 30,
                    //                 ),
                    //                 SizedBox(height: 5),
                    //                 Text(
                    //                   'اختر صورة',
                    //                   style: TextStyle(
                    //                     fontFamily: AppTheme.fontFamily,
                    //                     color: AppTheme.primaryColor,
                    //                     fontSize: 10,
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initUser();
  }
  initUser() async {
    userModel = await getCachedData(
      key: 'UserInformation',
      retrievedDataType: UserModel.init(),
      returnType: UserModel,
    );
    setState(() {});
    print("userModel.level");
    print(userModel!.level);
  }
}
