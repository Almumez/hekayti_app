import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hikayati_app/core/AppTheme.dart';
import 'package:hikayati_app/core/util/ScreenUtil.dart';
import 'package:hikayati_app/dataProviders/network/data_source_url.dart';
import 'package:hikayati_app/features/AIStory/date/model/AIStoryModel.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../core/util/CharactersList.dart';
import '../../../../core/util/Common.dart';
import '../../../../core/widgets/CustomButton.dart';
import '../../../../core/widgets/CustomPageRoute.dart';
import '../../../../injection_container.dart';
import '../../../Home/presintation/page/HomePage.dart';
import '../../../Regestrion/date/model/userMode.dart';
import '../manager/AIStory_bloc.dart';

class AIStoryPage extends StatefulWidget {
  final String storyId;

  const AIStoryPage({Key? key, required this.storyId}) : super(key: key);

  @override
  State<AIStoryPage> createState() => _AIStoryPageState();
}

class _AIStoryPageState extends State<AIStoryPage> {
  ScreenUtil screenUtil = ScreenUtil();
  PageController pageController = PageController();
  int currentPage = 0;
  bool isSpack = true;
  UserModel? userModel;
  CharactersList charactersListObj = CharactersList();
  bool isLoading = true;
  
  // Tutorial keys
  GlobalKey keyHome = GlobalKey();
  GlobalKey keyAudio = GlobalKey();
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];

  @override
  void initState() {
    super.initState();
    initUser();
    
    // Simulate loading time for demonstration
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  initUser() async {
    userModel = await getCachedData(
      key: 'UserInformation',
      retrievedDataType: UserModel.init(),
      returnType: UserModel,
    );
    if (mounted) {
      setState(() {});
    }
  }

  void showTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasShownTutorial = prefs.getBool("ai_story_detail_tutorial") ?? false;
    
    if (hasShownTutorial) return;
    
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
          )
        )
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
          )
        )
      ]),
    ];

    tutorialCoachMark = TutorialCoachMark(
      hideSkip: true,
      targets: targets,
      onFinish: () async {
        prefs.setBool("ai_story_detail_tutorial", true);
      }
    );
    
    tutorialCoachMark!.show(context: context);
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
        body: BlocProvider(
          create: (context) => sl<AIStoryBloc>(),
          child: BlocConsumer<AIStoryBloc, AIStoryState>(
            listener: (context, state) {
              if (state is AIStoryLoaded) {
                // Show tutorial after content is loaded
                Future.delayed(Duration(milliseconds: 500), () {
                  showTutorial();
                });
              }
            },
            builder: (context, state) {
              if (state is AIStoryLoading || isLoading) {
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
              
              if (state is AIStoryError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'حدث خطأ في تحميل القصة',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 20,
                          fontFamily: AppTheme.fontFamily
                        ),
                      ),
                      SizedBox(height: 20),
                      CustomButton(
                        ontap: () {
                          Navigator.pop(context);
                        },
                        text: 'العودة',
                      )
                    ],
                  ),
                );
              }
              
              if (state is AIStoryLoaded) {
                final story = state.storyModel;
                final slides = story.slides ?? [];
                
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Container(
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
                                itemCount: slides.length,
                                controller: pageController,
                                reverse: true,
                                onPageChanged: (index) {
                                  setState(() {
                                    currentPage = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final slide = slides[index] as AIStorySlide;
                                  bool isCoverPage = slide.page_no == 0;
                                  
                                  return Container(
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
                                            child: Image.network(
                                              DataSourceURL.aiImages + (slide.image ?? ''),
                                              fit: BoxFit.cover,
                                              height: screenUtil.screenHeight * .9,
                                              width: screenUtil.screenWidth * .9,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.image,
                                                      color: AppTheme.primaryColor,
                                                      size: 80,
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
                                            child: isCoverPage 
                                              ? CustomButton(
                                                  ontap: () {
                                                    pageController.nextPage(
                                                      duration: Duration(milliseconds: 500),
                                                      curve: Curves.fastOutSlowIn
                                                    );
                                                  },
                                                  text: 'ابدأ',
                                                )
                                              : Container(
                                                  width: screenUtil.screenWidth * .9,
                                                  height: screenUtil.screenHeight * 1,
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                    children: [
                                                      // Next button
                                                      index + 1 < slides.length ?
                                                      InkWell(
                                                        onTap: () {
                                                          pageController.nextPage(
                                                            duration: Duration(seconds: 1),
                                                            curve: Curves.fastOutSlowIn
                                                          );
                                                        },
                                                        child: Container(
                                                          child: Icon(
                                                            Icons.arrow_forward_ios,
                                                            color: AppTheme.primaryColor,
                                                            size: 30,
                                                          ),
                                                        ),
                                                      ) : Container(width: 30),
                                                      
                                                      // Text content
                                                      Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          SizedBox(height: 5),
                                                          Text(
                                                            slide.text ?? '',
                                                            style: AppTheme.textTheme.displayLarge,
                                                            textAlign: TextAlign.center,
                                                          ),
                                                          SizedBox(height: 5),
                                                          Text(
                                                            '${slides.length - 1}/${slide.page_no}',
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
                                                        child: Container(
                                                          child: Icon(
                                                            Icons.arrow_back_ios,
                                                            color: AppTheme.primaryColor,
                                                            size: 30,
                                                          ),
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
                  ),
                );
              }

              if (state is AIStoryInitial) {
                BlocProvider.of<AIStoryBloc>(context)
                    .add(GetAIStory(storyId: '1'));
              }
              return Container(); // Default empty container
            },
          ),
        ),
      ),
    );
  }
}

// Custom Icon Widget (since it's referenced but not provided in the files)
class CustomIconWidget extends StatelessWidget {
  final bool status;
  final Color primaryColor;
  final Color secondaryColor;
  final Widget primaryIcon;
  final Widget secondaryIcon;
  final Function onTap;

  const CustomIconWidget({
    Key? key,
    required this.status,
    required this.primaryColor,
    required this.secondaryColor,
    required this.primaryIcon,
    required this.secondaryIcon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: status ? primaryColor : secondaryColor,
        ),
        child: status ? primaryIcon : secondaryIcon,
      ),
    );
  }
} 