import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hikayati_app/core/AppTheme.dart';
import 'package:hikayati_app/core/util/ScreenUtil.dart';
import 'package:hikayati_app/dataProviders/network/data_source_url.dart';
import 'package:hikayati_app/gen/assets.gen.dart';
import 'package:hikayati_app/core/widgets/CustomPageRoute.dart';
import 'package:hikayati_app/features/GenritiveAI/presintation/page/GenritiveAIStoryPage.dart';
import 'package:hikayati_app/features/GenritiveAI/presintation/page/StoryGenSettings.dart';
import 'package:lottie/lottie.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hikayati_app/core/widgets/TutorialWidget.dart';
import 'package:hikayati_app/core/util/CharactersList.dart';
import 'package:hikayati_app/core/util/Common.dart';
import 'package:hikayati_app/features/Regestrion/date/model/userMode.dart';

import '../../../../injection_container.dart';
import '../manager/GenritiveAI_bloc.dart';

class GenritiveAIPage extends StatefulWidget {
  const GenritiveAIPage({Key? key}) : super(key: key);

  @override
  State<GenritiveAIPage> createState() => _GenritiveAIPageState();
}

class _GenritiveAIPageState extends State<GenritiveAIPage> {
  ScreenUtil screenUtil = ScreenUtil();

  // Demo data for story cards
  final List<Map<String, String>> demoStories = [
    {'name': 'مغامرات في الغابة', 'image': 'assets/images/demo/forest.png'},
    {'name': 'رحلة إلى الفضاء', 'image': 'assets/images/demo/space.png'},
    {'name': 'أصدقاء البحر', 'image': 'assets/images/demo/sea.png'},
    {'name': 'حكايات الديناصورات', 'image': 'assets/images/demo/dino.png'},
    {'name': 'مملكة الألوان', 'image': 'assets/images/demo/colors.png'},
    {'name': 'أبطال المدينة', 'image': 'assets/images/demo/heroes.png'},
  ];

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
      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 30.0, bottom: 20.0),
          child: Container(
            key: keyCreateStory,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () {
                Navigator.push(
                  context,
                  CustomPageRoute(
                    child: StoryGenSettings(index: 0),
                  ),
                );
              },
              isExtended: true,
              label: Text(
                "أنشئ قصة",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              icon: Container(
                width: 60,
                height: 60,
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF7BCA), // Pink
                      Color(0xFF9C27B0), // Purple
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Lottie.asset(
                  "assets/json/create_ai.json",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
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
              if (state is GenritiveAILoading) {
                loadingApp("جاري تسجيل الحساب...");
              }

              if (state is GenritiveAIError) {

              }

            },
            builder: (_context, state) {
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

  const StoryAICard({
    Key? key,
    required this.name,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenUtil = ScreenUtil()..init(context);
   print( DataSourceURL.aiImages +image);
    return InkWell(
      onTap: () {
        // Navigate to the GenritiveAIStoryPage with this story
        Navigator.push(
          context,
          CustomPageRoute(
            child: GenritiveAIStoryPage(
              storyTitle: name,
              storyImage: image,
            ),
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
            Text(
              name,
              style: AppTheme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
