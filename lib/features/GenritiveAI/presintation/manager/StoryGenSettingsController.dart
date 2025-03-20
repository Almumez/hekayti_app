import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hikayati_app/features/Regestrion/date/model/userMode.dart';
import '../../../../core/util/Common.dart';

class StoryGenSettingsController extends GetxController {
 String? StoryTheme;
 String? StoryName;
 String? StoryTopic;
int  StoryThemeIndex=0;

TextEditingController   StoryNameController=TextEditingController();
TextEditingController   StoryTopicController=TextEditingController();

int index=0;
int storyStyleIndex = 0;
String storyStyle = '';

  @override
  void onInit() {
    super.onInit();
  }


}
