import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hikayati_app/core/AppTheme.dart';
import 'package:hikayati_app/core/util/ScreenUtil.dart';
import 'package:hikayati_app/dataProviders/network/data_source_url.dart';
import 'package:hikayati_app/gen/assets.gen.dart';
import 'package:hikayati_app/core/widgets/CustomPageRoute.dart';
import 'package:hikayati_app/features/GenritiveAI/presintation/page/StoryGenSettings.dart';
import 'package:lottie/lottie.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hikayati_app/core/widgets/TutorialWidget.dart';
import 'package:hikayati_app/core/util/CharactersList.dart';
import 'package:hikayati_app/core/util/Common.dart';
import 'package:hikayati_app/features/Regestrion/date/model/userMode.dart';

import '../../../../injection_container.dart';
import '../../../AIStory/presintation/page/AIStoryPage.dart';
import '../manager/GenritiveAI_bloc.dart';


class GenritiveAIPage extends StatefulWidget {
  const GenritiveAIPage({Key? key}) : super(key: key);

  @override
  State<GenritiveAIPage> createState() => _GenritiveAIPageState();
}

class _GenritiveAIPageState extends State<GenritiveAIPage> with SingleTickerProviderStateMixin {
  ScreenUtil screenUtil = ScreenUtil();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  // For Tutorial
  GlobalKey keyCreateStory = GlobalKey();
  List<TargetFocus> targets = [];
  TutorialCoachMark? tutorialCoachMark;
  bool tautorial = false;
  SharedPreferences? prefs;
  UserModel? userModel;
  CharactersList charactersListObj = CharactersList();

  @override
  void initState() {
    super.initState();
    initUser();
    initTutorial();
    
    // تهيئة الأنيميشن للزر العائم
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );
    
    // إنشاء تأثير التكبير والتصغير
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 40,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // إضافة حركة دوران خفيفة
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.05),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: -0.05),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.05, end: 0),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.repeat();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  initUser() async {
    userModel = await getCachedData(
      key: 'UserInformation',
      retrievedDataType: UserModel.init(),
      returnType: UserModel,
    );
    setState(() {});
  }

  initTutorial() async {
    prefs = await SharedPreferences.getInstance();
    tautorial = await prefs?.getBool("aiTutorial") ?? false;

    if (!tautorial && userModel != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showTutorial();
      });
    }
  }

  showTutorial() async {
    targets = [
      TargetFocus(
        identify: "createStoryButton",
        keyTarget: keyCreateStory,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: TutorialWidget(
              index: 1,
              onTap: () {
                tutorialCoachMark!.finish();
              },
              text: "هنا يمكنك إنشاء قصتك الخاصة باستخدام الذكاء الاصطناعي! اضغط على هذا الزر وأطلق العنان لخيالك",
              Characters: int.parse(userModel!.character.toString()) ?? 0,
            )
          )
        ]
      ),
    ];

    tutorialCoachMark = TutorialCoachMark(
      hideSkip: true,
      targets: targets,
      onFinish: () async {
        prefs = await SharedPreferences.getInstance();
        prefs!.setBool("aiTutorial", true);
        setState(() {
          tautorial = true;
        });
      }
    );

    tutorialCoachMark!.show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    screenUtil.init(context);
    return Scaffold(
      floatingActionButton: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 12,
                      spreadRadius: _scaleAnimation.value * 2,
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  backgroundColor: AppTheme.primaryColor,
                  key: keyCreateStory,
                  onPressed: () {
                    Navigator.push(
                      context,
                      CustomPageRoute(
                        child: StoryGenSettings(index: 0),
                      ),
                    );
                  },
                  child: Image.asset(
                    "assets/images/GenritiveAI.png",
                    height: 50,
                    width: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: Container(
        height: screenUtil.screenHeight * 1,
        width: screenUtil.screenWidth * 1,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/backgraond.png'),
                fit: BoxFit.fill
            )
        ),
        child: BlocProvider(
          create: (context) => sl<GenritiveAIBloc>(),
          child: BlocConsumer<GenritiveAIBloc, GenritiveAIState>(
            listener: (_context, state) async {


              if (state is GenritiveAIError) {

              }

            },
            builder: (_context, state) {
              if (state is GenritiveAILoading) {
                return Center(child: loadingApp('جاري تجهيز القصص .....  '));
              }
              if (state is GenritiveAIInitial) {
                BlocProvider.of<GenritiveAIBloc>(_context)
                    .add(GenritiveAI());
              }
              if (state is GenritiveAILoaded) {

                return  Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenUtil.screenHeight * .02),
                      Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenUtil.screenWidth * .01,
                            vertical: screenUtil.screenHeight * .01,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 15 / 14,
                            crossAxisSpacing: screenUtil.screenWidth * .015,
                            mainAxisSpacing: screenUtil.screenHeight * .05,
                          ),
                          itemCount: state.storyModel.length,
                          itemBuilder: (context, index) {
                            return StoryAICard(
                              name: state.storyModel[index].name,
                              image:  state.storyModel[index].cover_photo,
                              storyId: state.storyModel[index].id.toString(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Container();
            },
          ),
        )
      ),
    );
  }
}

class StoryAICard extends StatelessWidget {
  final String name;
  final String image;
  final String storyId;

  const StoryAICard({
    Key? key,
    required this.name,
    required this.image,
   required this.storyId
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenUtil = ScreenUtil()..init(context);
    return InkWell(
      onTap: () {
        // Navigate to the AIStoryPage with this story ID
        Navigator.push(
          context,
          CustomPageRoute(
            child: AIStoryPage(storyId: storyId),
          ),
        );
      },
      child: Container(
        width: screenUtil.screenWidth * .25,
        height: screenUtil.screenHeight * .6,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/storyBG.png'),
            fit: BoxFit.contain,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // We don't include stars here as requested
            SizedBox(height: 40), // Space where stars would be
            Container(
              height: screenUtil.screenHeight * .3,
              width: screenUtil.screenWidth * .14,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                 DataSourceURL.aiImages +image,
                  fit: BoxFit.cover,
                  // Using a fallback image in case the specified asset doesn't exist
                  errorBuilder: (context, error, stackTrace) {

                   print(error);
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.image, color: AppTheme.primaryColor, size: 40),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 150,
              child: Text(
                name,
                style: AppTheme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
