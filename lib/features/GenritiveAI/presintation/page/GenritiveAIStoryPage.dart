import 'dart:async';
import 'dart:io' as io;
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../core/AppTheme.dart';
import '../../../../core/util/CharactersList.dart';
import '../../../../core/util/Common.dart';
import '../../../../core/util/ScreenUtil.dart';
import '../../../../core/widgets/CustomButton.dart';
import '../../../../core/widgets/CustomIconWidget.dart';
import '../../../../core/widgets/CustomPageRoute.dart';
import '../../../../gen/assets.gen.dart';
import '../../../Home/presintation/page/HomePage.dart';
import '../../../Regestrion/date/model/userMode.dart';

class GenritiveAIStoryPage extends StatefulWidget {
  final String storyTitle;
  final String storyImage;
  final List<Map<String, dynamic>>? storyPages;

  const GenritiveAIStoryPage({
    Key? key,
    required this.storyTitle,
    required this.storyImage,
    this.storyPages,
  }) : super(key: key);

  @override
  State<GenritiveAIStoryPage> createState() => _GenritiveAIStoryPageState();
}

class _GenritiveAIStoryPageState extends State<GenritiveAIStoryPage> {
  ScreenUtil screenUtil = ScreenUtil();
  UserModel? userModel;
  bool isSpack = true;
  final player = AudioPlayer();
  PageController pageController = PageController();
  int currentPage = 0;
  bool isLoading = true;
  CharactersList charactersListObj = CharactersList();
  Widget storyWidget = Center();
  
  // Tutorial keys
  GlobalKey keyHome = GlobalKey();
  GlobalKey keyAudio = GlobalKey();
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];
  
  // Demo story pages for testing (will be replaced by actual AI-generated content)
  List<Map<String, dynamic>> demoStoryPages = [
    {
      'id': '1',
      'page_no': 0,
      'text': 'اضغط زر البدء للانتقال الى القصة',
      'text_no_desc': 'اضغط زر البدء للانتقال الى القصة',
      'image': 'assets/images/demo/cover.png',
      'audio': ''
    },
    {
      'id': '2',
      'page_no': 1,
      'text': 'كان يا مكان في قديم الزمان، قطة صغيرة تعيش في قرية هادئة',
      'text_no_desc': 'كان يا مكان في قديم الزمان، قطة صغيرة تعيش في قرية هادئة',
      'image': 'assets/images/demo/page1.png',
      'audio': ''
    },
    {
      'id': '3',
      'page_no': 2,
      'text': 'وفي يوم من الأيام، قررت القطة أن تذهب في مغامرة للبحث عن الكنز المفقود',
      'text_no_desc': 'وفي يوم من الأيام، قررت القطة أن تذهب في مغامرة للبحث عن الكنز المفقود',
      'image': 'assets/images/demo/page2.png',
      'audio': ''
    },
    {
      'id': '4',
      'page_no': 3,
      'text': 'وبعد رحلة طويلة وشاقة، وجدت القطة الكنز وعادت به إلى القرية',
      'text_no_desc': 'وبعد رحلة طويلة وشاقة، وجدت القطة الكنز وعادت به إلى القرية',
      'image': 'assets/images/demo/page3.png',
      'audio': ''
    }
  ];

  @override
  void initState() {
    super.initState();
    initData();
    
    // Simulate loading time
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> initData() async {
    userModel = await getCachedData(
      key: 'UserInformation',
      retrievedDataType: UserModel.init(),
      returnType: UserModel.init(),
    );
    setState(() {});
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void showTutorial() {
    targets = [
      TargetFocus(identify: "target1", keyTarget: keyHome, contents: [
        TargetContent(
            align: ContentAlign.left,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "يمكنك الرجوع الى القائمة الرئسية من هنا",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "انقر في أي مكان للمتابعة",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ))
      ]),
      TargetFocus(identify: "target2", keyTarget: keyAudio, contents: [
        TargetContent(
            align: ContentAlign.left,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "اضغط على هذا الزر من أجل الاستماع للقصة",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "انقر في أي مكان للمتابعة",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ))
      ]),
    ];

    tutorialCoachMark = TutorialCoachMark(
      hideSkip: true,
      targets: targets,
      onFinish: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("ai_story_tutorial", true);
      }
    );
    
    tutorialCoachMark!.show(context: context);
  }

  Future<void> startAudio({required String pathAudio}) async {
    if (pathAudio.isEmpty) return;
    
    final status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        await player.play(AssetSource(pathAudio));
        setState(() {
          isSpack = !isSpack;
        });
      } catch (e) {
        print("Error playing audio: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    screenUtil.init(context);
    return WillPopScope(
      onWillPop: () async {
        final value = await showImagesDialogWithCancleButten(
            context,
            '${charactersListObj.confusedListCharactersList[int.parse(userModel?.character?.toString() ?? "0")]['image']}',
            'هل حقا تريد المغادره ؟', 
            () {
              Navigator.pop(context);
            }, 
            () {
              Navigator.push(context, CustomPageRoute(child: HomePage()));
            }
        );

        if (value != null) {
          return Future.value(value);
        } else {
          return Future.value(false);
        }
      },
      child: Scaffold(
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Builder(
            builder: (context) {
              if (isLoading) {
                return Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Lottie.asset(
                          "assets/json/animation_slied.json",
                          width: 300,
                        ),
                      ),
                      Text(
                        'جاري تحضير القصة',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 20,
                          fontFamily: AppTheme.fontFamily
                        ),
                      )
                    ],
                  ),
                );
              }

              // Use widget.storyPages if provided, otherwise use demo pages
              final storyPages = widget.storyPages ?? demoStoryPages;
              
              return Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/backgraond.png'),
                    fit: BoxFit.fill
                  ),
                ),
                height: screenUtil.screenHeight * 1,
                width: screenUtil.screenWidth * 1,
                child: Center(
                  child: Row(
                    children: [
                      SafeArea(
                        child: Container(
                          width: screenUtil.screenWidth * .1,
                          height: screenUtil.screenHeight * 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomIconWidget(
                                key: keyHome,
                                status: true,
                                secondaryColor: AppTheme.primaryColor,
                                primaryColor: Colors.white,
                                primaryIcon: Icon(Icons.home, color: AppTheme.primaryColor),
                                secondaryIcon: Icon(Icons.home, color: AppTheme.primaryColor),
                                onTap: () {
                                  showImagesDialogWithCancleButten(
                                    context,
                                    '${charactersListObj.confusedListCharactersList[int.parse(userModel?.character?.toString() ?? "0")]['image']}',
                                    'هل حقا تريد المغادره ؟',
                                    () {
                                      Navigator.pop(context);
                                    },
                                    () {
                                      Navigator.push(context, CustomPageRoute(child: HomePage()));
                                    }
                                  );
                                }
                              ),
                              
                              currentPage > 0 ? 
                              CustomIconWidget(
                                key: keyAudio,
                                onTap: () {
                                  // Audio functionality would go here if implemented
                                  // startAudio(pathAudio: storyPages[currentPage]['audio']);
                                },
                                primaryColor: Colors.white,
                                primaryIcon: Icon(
                                  Icons.volume_up,
                                  color: AppTheme.primaryColor,
                                ),
                                secondaryIcon: Icon(
                                  Icons.volume_up,
                                  color: Colors.white,
                                ),
                                secondaryColor: AppTheme.primaryColor,
                                status: isSpack,
                              ) : Container(),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: screenUtil.screenHeight * 1,
                        width: screenUtil.screenWidth * .8,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: PageView.builder(
                            itemCount: storyPages.length,
                            controller: pageController,
                            reverse: true,
                            onPageChanged: (index) {
                              setState(() {
                                currentPage = index;
                              });
                              if (index == 1) {
                                // Show tutorial on first content page
                                Future.delayed(Duration(milliseconds: 500), () {
                                  showTutorial();
                                });
                              }
                            },
                            itemBuilder: (context, index) {
                              final page = storyPages[index];
                              
                              return page['page_no'] == 0
                                // Cover page
                                ? Container(
                                    margin: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(15))
                                    ),
                                    child: Stack(
                                      alignment: AlignmentDirectional.topCenter,
                                      children: [
                                        Container(
                                          width: screenUtil.screenWidth * 1,
                                          height: screenUtil.screenHeight * .80,
                                          padding: EdgeInsets.only(
                                            right: 10,
                                            left: 10,
                                            top: 10
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(5),
                                            child: Image.asset(
                                              page['image'],
                                              fit: BoxFit.cover,
                                              height: screenUtil.screenHeight * .9,
                                              width: screenUtil.screenWidth * .9,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: Center(
                                                    child: Text(
                                                      widget.storyTitle,
                                                      style: AppTheme.textTheme.displayLarge,
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        ),
                                        Positioned(
                                          height: screenUtil.screenHeight * 1.75,
                                          width: screenUtil.screenWidth * .8,
                                          child: Center(
                                            child: CustomButton(
                                              ontap: () {
                                                pageController.nextPage(
                                                  duration: Duration(milliseconds: 500),
                                                  curve: Curves.fastOutSlowIn
                                                );
                                              },
                                              text: 'ابدأ',
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                // Content pages
                                : Container(
                                    margin: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(15))
                                    ),
                                    child: Stack(
                                      alignment: AlignmentDirectional.topCenter,
                                      children: [
                                        Container(
                                          width: screenUtil.screenWidth * 1,
                                          height: screenUtil.screenHeight * .80,
                                          padding: EdgeInsets.only(
                                            right: 10,
                                            left: 10,
                                            top: 10
                                          ),
                                          child: Image.asset(
                                            page['image'],
                                            fit: BoxFit.cover,
                                            height: screenUtil.screenHeight * .9,
                                            width: screenUtil.screenWidth * .9,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.image,
                                                  color: AppTheme.primaryColor,
                                                  size: 80,
                                                ),
                                              );
                                            },
                                          )
                                        ),
                                        Positioned(
                                          height: screenUtil.screenHeight * 1.75,
                                          width: screenUtil.screenWidth * .8,
                                          child: Center(
                                            child: Container(
                                              width: screenUtil.screenWidth * .9,
                                              height: screenUtil.screenHeight * 1,
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  // Next button
                                                  index + 1 < storyPages.length ?
                                                  InkWell(
                                                    onTap: () {
                                                      pageController.nextPage(
                                                        duration: Duration(seconds: 1),
                                                        curve: Curves.fastOutSlowIn
                                                      );
                                                    },
                                                    child: Image.asset(
                                                      color: AppTheme.primarySwatch.shade800,
                                                      width: 30,
                                                      height: 30,
                                                      fit: BoxFit.fill,
                                                      Assets.images.rightArrow.path,
                                                    ),
                                                  ) : Container(),
                                                  
                                                  // Text content
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      SizedBox(height: 5),
                                                      Text(
                                                        page['text'],
                                                        style: AppTheme.textTheme.displayLarge,
                                                      ),
                                                      SizedBox(height: 5),
                                                      Text(
                                                        '${storyPages.length - 1}/${page['page_no']}',
                                                        style: TextStyle(
                                                          color: AppTheme.primaryColor,
                                                          fontSize: 12
                                                        )
                                                      )
                                                    ],
                                                  ),
                                                  
                                                  // Previous button
                                                  InkWell(
                                                    onTap: () {
                                                      pageController.previousPage(
                                                        duration: Duration(seconds: 1),
                                                        curve: Curves.fastOutSlowIn
                                                      );
                                                    },
                                                    child: Image.asset(
                                                      color: AppTheme.primarySwatch.shade400,
                                                      Assets.images.leftArrow.path,
                                                      width: 30,
                                                      height: 30,
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 