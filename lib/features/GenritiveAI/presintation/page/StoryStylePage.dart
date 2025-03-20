import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hikayati_app/core/util/ScreenUtil.dart';
import 'package:hikayati_app/features/Regestrion/date/model/userMode.dart';

import '../../../../core/AppTheme.dart';
import '../../../../core/util/CharactersList.dart';
import '../../../../core/util/Common.dart';
import '../../../../core/widgets/CustomCharacters.dart';

import '../Widget/StoryThemeWidget.dart';
import '../manager/StoryGenSettingsController.dart';

class StoryStylePage extends StatefulWidget {
  const StoryStylePage({Key? key}) : super(key: key);

  @override
  State<StoryStylePage> createState() => _StoryStylePageState();
}

class _StoryStylePageState extends State<StoryStylePage> {
  ScreenUtil screenUtil = ScreenUtil();
  final List<Map<String, String>> storyStyleList = [
    {
      'name': 'ثلاثي الأبعاد',
      'image': 'assets/images/style6.png', // صورة الأطفال في الحقل
    },
    {
      'name': 'ثلاثي الأبعاد',
      'image': 'assets/images/style5.png', // صورة الأطفال يلعبون بالصاروخ
    },
    {
      'name': 'خيالي',
      'image': 'assets/images/style3.png', // صورة الساحر
    },
    {
      'name': 'بكسل آرت',
      'image': 'assets/images/style2.png', // صورة الرسام البكسل
    },
    {
      'name': 'واقعي',
      'image': 'assets/images/style1.png', // صورة الطائر مع الزهور
    },
  ];

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
            SizedBox(height: 15,),
            Text('اختر أسلوب الرسم لقصتك:', style: AppTheme.textTheme.displayLarge),
            SizedBox(height: 15,),

            Container(
              height: screenUtil.screenHeight * .6,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: storyStyleList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StoryThemeWidget(
                      name: storyStyleList[index]['name'].toString(),
                      image: storyStyleList[index]['image'].toString(),
                      onTap: () async {
                        controller.storyStyleIndex = index;
                        controller.storyStyle = storyStyleList[index]['name'].toString();
                        controller.update();
                        print(controller.storyStyle);
                        print(controller.storyStyleIndex);
                      },
                      isSelected:
                          controller.storyStyleIndex == index ? true : false,
                    ),
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
} 