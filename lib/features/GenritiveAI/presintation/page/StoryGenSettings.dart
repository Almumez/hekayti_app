import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:hikayati_app/features/Home/presintation/page/HomePage.dart';
import 'package:hikayati_app/features/GenritiveAI/presintation/manager/StoryGenSettingsController.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/AppTheme.dart';
import '../../../../core/util/CharactersList.dart';
import '../../../../core/util/ScreenUtil.dart';
import '../../../../core/util/Common.dart';
import '../../../../core/widgets/CustomPageRoute.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../injection_container.dart';
import '../../../../main.dart';
import '../../../AIStory/presintation/page/AIStoryPage.dart';
import '../../../Regestrion/date/model/userMode.dart';
import '../manager/GenritiveAI_bloc.dart';
import 'PageSix.dart';
import 'PageOne.dart';
import 'PageFour.dart';
import 'StoryStylePage.dart';

class StoryGenSettings extends StatefulWidget {
  int index;

  StoryGenSettings({Key? key, required this.index}) : super(key: key);
  @override
  State<StoryGenSettings> createState() => _StoryGenSettingsState();
}

class _StoryGenSettingsState extends State<StoryGenSettings> {
  List<Widget> onboardingList = [
    PageOne(),
    PageSix(),
    StoryStylePage(),
    PageFour(),

  ];
  ScreenUtil _screenUtil = ScreenUtil();
  CharactersList CharactersListobj = CharactersList();

  int progress = 0;
  bool isLoading = false;
  SharedPreferences? prefs;
  final _formKey = GlobalKey<FormState>();
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    _screenUtil.init(context);
    return Scaffold(
      body: BlocProvider(
        create: (context) => sl<GenritiveAIBloc>(),
        child: BlocConsumer<GenritiveAIBloc, GenritiveAIState>(
          listener: (_context, state) async {


            if (state is GenritiveAIStoryError) {

            }

          },
          builder: (_context, state) {
            if (state is GenritiveAIStoryLoaded) {
              Future.delayed(Duration(milliseconds: 300), () {
                Navigator.push(
                  context,
                  CustomPageRoute(
                    child: AIStoryPage(storyId:state.storyModel.id.toString()),
                  ),
                );
              });


            }
            if (state is GenritiveAIStoryLoading) {
              return Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/backgraond.png'),
                    fit: BoxFit.fill
                  ),
                ),
                child: Center(
                  child: Container(
                    width: _screenUtil.screenWidth * 0.85,
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        width: 4,
                        color: AppTheme.primarySwatch.shade500
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        )
                      ]
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(
                          "assets/json/animation_slied.json",
                          width: 200,
                          height: 200,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'جاري إنشاء وتجهيز القصة',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'يرجى الانتظار قليلاً',
                          style: TextStyle(
                            color: AppTheme.primarySwatch.shade700,
                            fontSize: 16,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: _screenUtil.screenWidth * 0.6,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primarySwatch.shade400),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return GetBuilder<StoryGenSettingsController>(
              init: StoryGenSettingsController(),
              builder: (controller) {
                return Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                              'assets/images/backgraond.png',
                            ),
                            fit: BoxFit.fill),
                      ),
                      height: _screenUtil.screenHeight * 1,
                      width: _screenUtil.screenWidth * 1,
                      child: PageView.builder(
                        controller: pageController,
                        allowImplicitScrolling: false,
                        //  physics: NeverScrollableScrollPhysics(),
                        itemCount: onboardingList.length,
                        itemBuilder: (context, index) {
                          if (widget.index != 0) {
                            pageController.animateToPage(
                              widget.index,
                              duration: Duration(
                                seconds: 1,
                              ),
                              curve: Curves.bounceInOut,
                            );
                            widget.index = 0;
                            print(index);
                          }

                          return Stack(
                            children: [
                              isLoading
                                  ? Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: loadingApp('جاري تحميل القصص  '))
                                  : Center(
                                child: Column(children: [
                                  Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Container(
                                            height: _screenUtil.screenHeight * .95,
                                            width: _screenUtil.screenWidth * .85,
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(15.0),
                                              ),
                                              child: Container(
                                                margin: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                        width: 4,
                                                        color: AppTheme
                                                            .primarySwatch
                                                            .shade500),
                                                    borderRadius: BorderRadius.all(
                                                        Radius.circular(15))),
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                        flex: 10,
                                                        child:
                                                        onboardingList[index]),
                                                    Directionality(
                                                      textDirection:
                                                      TextDirection.ltr,
                                                      child: Expanded(
                                                        flex: 2,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                //
                                                                controller.index=index-1;
                                                                controller.update();
                                                                print("controller.index");
                                                                print(controller.index);
                                                                pageController.previousPage(
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                        1000),
                                                                    curve: Curves
                                                                        .fastOutSlowIn);
                                                              },
                                                              child: index != 0
                                                                  ? Image.asset(
                                                                color: AppTheme
                                                                    .primarySwatch
                                                                    .shade400,
                                                                Assets
                                                                    .images
                                                                    .leftArrow
                                                                    .path,
                                                                width: 30,
                                                                height: 30,
                                                                fit: BoxFit
                                                                    .fill,
                                                              )
                                                                  : SizedBox
                                                                  .shrink(),
                                                            ),
                                                            DotsIndicator(
                                                              dotsCount:
                                                              onboardingList
                                                                  .length,
                                                              position:
                                                              index.toDouble(),
                                                              decorator:
                                                              DotsDecorator(
                                                                size: const Size
                                                                    .square(9.0),
                                                                color: AppTheme
                                                                    .primaryColor,
                                                                activeColor: AppTheme
                                                                    .primaryColor,
                                                                activeSize:
                                                                const Size(
                                                                    30.0, 9.0),
                                                                activeShape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                        5.0)),
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap: () async {
                                                                if (_formKey
                                                                    .currentState!
                                                                    .validate()) {
                                                                  if (index == 3) {
                                                                    if (await networkInfo
                                                                        .isConnected) {
                                                                      print(controller.StoryTopic);
                                                                      print(controller.StoryName);
                                                                      print(controller.StoryTheme);
                                                                      print(controller.index);
                                                                      BlocProvider.of<GenritiveAIBloc>(
                                                                          _context)
                                                                          .add(
                                                                          GenritiveAIStory(hero_name: controller.StoryName!, painting_style: controller.storyStyle,story_topic: controller.StoryTheme!));
                                                                    } else {
                                                                      showImagesDialog(
                                                                          context,
                                                                          '${CharactersListobj.showCharactersList[int.parse("0")]['image'].toString()}',
                                                                          'تاكد من وجود انترنت اول مره من اجل تحميل القصص',
                                                                              () {
                                                                            Navigator.pop(
                                                                                context);
                                                                          });
                                                                    }
                                                                  } else {
                                                                    controller.index=index+1;
                                                                    controller.update();
                                                                    print("controller.index");
                                                                    print(controller.index);
                                                                    pageController
                                                                        .nextPage(
                                                                        duration:
                                                                        Duration(
                                                                          seconds:
                                                                          1,
                                                                        ),
                                                                        curve: Curves
                                                                            .fastOutSlowIn);
                                                                  }
                                                                }

                                                                // you'd often call a server or save the information in a database.
                                                              },
                                                              child: Image.asset(
                                                                color: AppTheme
                                                                    .primarySwatch
                                                                    .shade800,
                                                                Assets
                                                                    .images
                                                                    .rightArrow
                                                                    .path,
                                                                width: 30,
                                                                height: 30,
                                                                fit: BoxFit.fill,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )),
                                  ),
                                ]),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }



}
