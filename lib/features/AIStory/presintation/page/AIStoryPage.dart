import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_text_to_speech/cloud_text_to_speech.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_recorder3/flutter_audio_recorder3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_speech/config/recognition_config.dart';
import 'package:google_speech/config/recognition_config_v1.dart';
import 'package:google_speech/speech_client_authenticator.dart';
import 'package:google_speech/speech_to_text.dart';
import 'package:hikayati_app/core/AppTheme.dart';
import 'package:hikayati_app/core/util/ScreenUtil.dart';
import 'package:hikayati_app/dataProviders/network/data_source_url.dart';
import 'package:hikayati_app/features/AIStory/date/model/AIStoryModel.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../core/util/CharactersList.dart';
import '../../../../core/util/Common.dart';
import '../../../../core/widgets/CustomButton.dart';
import '../../../../core/widgets/CustomIconWidget.dart';
import '../../../../core/widgets/CustomPageRoute.dart';
import '../../../../core/widgets/TutorialWidget.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../injection_container.dart';
import '../../../../main.dart';
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
  bool isProcces = false;
  
  // Audio and Speech Recognition
  final player = AudioPlayer();
  String? filePath;
  FlutterAudioRecorder3? _recorder;
  Recording? _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  bool recognizing = false;
  bool recognizeFinished = false;
  String recognizedText = '';
  bool microphone = false;
  Timer timer = Timer(Duration(seconds: 0), () {});
  
  // Star rating
  int star = 0;
  final controller = ConfettiController();
  
  // Tutorial keys
  GlobalKey keyHome = GlobalKey();
  GlobalKey keyAudio = GlobalKey();
  GlobalKey keyMicrophone = GlobalKey();
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];
  bool tutorialShown = false;

  dynamic selectedVoice;

  @override
  void initState() {
    super.initState();
    initUser();
    initGoogle();
    // Add player completion listener
    player.onPlayerComplete.listen((event) {
      setState(() {
        isSpack = !isSpack;
      });
    });
    // Simulate loading time for demonstration
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  // @override
  // void didChangeDependencies() {
  //   player.onPlayerComplete.listen((event) {
  //     setState(() {
  //       isSpack = !isSpack;
  //     });
  //   });
  //   super.didChangeDependencies();
  // }

  initGoogle() async {
    try {
      // Initialize the TTS service
      TtsGoogle.init(
        params: InitParamsGoogle(apiKey: "AIzaSyA77K8DxXCKylWJStwPLdcW3NF_M6TQ6rk"),
        withLogs: true,
      );

      // Fetch available voices
      final voicesResponse = await TtsGoogle.getVoices();
      final voices = voicesResponse.voices;

      // Print available voices for debugging
      print("Available voices:$voices");
      voices.forEach((voice) {
        print("Voice: ${voice.name}, Locale: ${voice.locale.code}");
      });

      // Try to find a female Arabic voice
      selectedVoice = voices.firstWhere(
        (voice) => voice.name == 'Sophia' || voice.name == 'Amelia' || 
                   voice.name == 'Ava' || voice.name == 'Emily' ||
                   voice.name == 'Isabella' || voice.name == 'Gianna' ||
                   voice.name == 'Avery' || voice.name == 'Evelyn',
        orElse: () {
          print("لم يتم العثور على صوت أنثوي، سيتم استخدام الصوت الافتراضي");
          return voices.first;
        },
      );

      print("تم اختيار الصوت: ${selectedVoice.name}");

    } catch (e) {
      print("خطأ في initGoogle: $e");
    }
  }

  @override
  void dispose() {
    player.dispose();
    controller.dispose();
    super.dispose();
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
    
    if (hasShownTutorial || tutorialShown) return;
    tutorialShown = true;
    
    targets = [
      TargetFocus(identify: "target1", keyTarget: keyHome, contents: [
        TargetContent(
          align: ContentAlign.left,
          child: TutorialWidget(
            index: 1,
            onTap: () {
              tutorialCoachMark!.next();
            },
            text: "يمكنك الرجوع الى القائمة الرئسية من هنا",
            Characters: int.parse(userModel?.character?.toString() ?? "0"),
          )
        )
      ]),
      TargetFocus(identify: "target2", keyTarget: keyAudio, contents: [
        TargetContent(
          align: ContentAlign.left,
          child: TutorialWidget(
            index: 2,
            hight: screenUtil.screenHeight * .5,
            onTap: () {
              tutorialCoachMark!.next();
            },
            text: "اضغط على هذا الزر من أجل الاستماع للقصة",
            Characters: int.parse(userModel?.character?.toString() ?? "0"),
          )
        )
      ]),
      TargetFocus(identify: "target3", keyTarget: keyMicrophone, contents: [
        TargetContent(
          align: ContentAlign.top,
          child: TutorialWidget(
            index: 3,
            onTap: () {
              tutorialCoachMark!.finish();
            },
            hight: screenUtil.screenHeight * .5,
            text: "اثناء قراءتك للقصة قم بتسجيل صوتك من اجل التاكد من صحه القراءة",
            Characters: int.parse(userModel?.character?.toString() ?? "0"),
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

  // Audio playback for stories
  Future<void> playAudio({String? audioUrl, String? text}) async {
    if (text == null && audioUrl == null) {
      return;
    }
    
    final status = await Permission.storage.request();
    final status2 = await Permission.accessMediaLocation.request();
    if (status.isGranted || status2.isGranted) {
      setState(() {
        isSpack = false;  // Set to false when starting playback
      });

      try {
        final storyText = text ?? "لا يوجد نص للقراءة";
        print(storyText);
        TtsParamsGoogle ttsParams = TtsParamsGoogle(
          voice: selectedVoice!,
          audioFormat: AudioOutputFormatGoogle.mp3,
          text: storyText,
          rate: 'slow',
          pitch: 'default'

        );
        
        final ttsResponse = await TtsGoogle.convertTts(ttsParams);
        
        final audioBytes = ttsResponse.audio.buffer.asUint8List();
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/story_audio.mp3';
        final file = File(tempPath);
        await file.writeAsBytes(audioBytes);
        
        await player.play(DeviceFileSource(tempPath));
      } catch (e) {
        setState(() {
          isSpack = true;  // Reset to true if there's an error
        });
      }
    }
  }

  // Audio recording initialization
  Future<void> _init() async {
    try {
      bool hasPermission = await FlutterAudioRecorder3.hasPermissions ?? false;
      final status = await Permission.accessMediaLocation.request();

      if (hasPermission || status.isGranted) {
        String customPath = '/audio';
        Directory? appDocDirectory = await getExternalStorageDirectory();

        customPath = appDocDirectory!.path + customPath;
        await _ensureDirectoryExists(customPath + '.wav');

        _recorder = FlutterAudioRecorder3(
          customPath,
          audioFormat: AudioFormat.WAV,
        );

        await _recorder!.initialized;
        var current = await _recorder!.current(channel: 0);
        setState(() {
          _current = current;
          _currentStatus = current!.status!;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("يرجى منك السماح بتحميل الملفات"))
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> _ensureDirectoryExists(String path) async {
    if (await File(path).exists()) {
      await File(path).delete();
      return true;
    }
    return true;
  }

  // Start recording
  Future<void> _start() async {
    try {
      await _init();
      await _recorder!.start();
      var recording = await _recorder!.current(channel: 0);
      
      setState(() {
        microphone = true;
        _current = recording;
      });

      timer = Timer.periodic(Duration(seconds: 25), (Timer t) async {
        if (_currentStatus != RecordingStatus.Unset) {
          t.cancel();
          setState(() {
            isProcces = true;
          });
          _stop();
        } else if (_currentStatus == RecordingStatus.Unset) {
          t.cancel();
        }
      });
      
      var current = await _recorder!.current(channel: 0);
      setState(() {
        _current = current;
        _currentStatus = _current!.status!;
      });
    } catch (e) {
      print(e);
    }
  }

  // Stop recording and process
  Future<void> _stop() async {
    setState(() {
      microphone = false;
    });
    
    var result = await _recorder!.stop();
    filePath = result!.path;
    _current = result;
    _currentStatus = RecordingStatus.Unset;
    
    setState(() {
      isProcces = true;
    });
    
    // Recognize speech
    recognizeSpeech();
  }

  Future<void> recognizeSpeech() async {
    // For this implementation we'll just simulate speech recognition
    // In a real implementation, this would use Google Speech API like in StoryPage
    
    setState(() {
      recognizing = true;
    });
    
    // Simulate processing time
    await Future.delayed(Duration(seconds: 2));
    
    // Simulate a successful result
    setState(() {
      recognizedText = "هذا نص تم التعرف عليه من خلال المحاكاة";
      recognizing = false;
      recognizeFinished = true;
      isProcces = false;
      star = 3; // Simulate perfect match
    });
    
    // Show success animation
    showImagesDialogWithStar(
      context,
      '${charactersListObj.singListCharactersList[int.parse(userModel?.character?.toString() ?? "0")]['image']}',
      'احسنت', 
      () {
        Navigator.pop(context);
      }, 
      star
    );
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
                                  Column(
                                    children: [
                                      CustomIconWidget(
                                        key: keyAudio,
                                        onTap: () {
                                          // Get the current slide's text to convert to speech
                                              playAudio(text: slides[currentPage].text);
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
                                      ),
                                      
                                      SizedBox(height: screenUtil.screenHeight * .1),
                                      
                                      CustomIconWidget(
                                        key: keyMicrophone,
                                        onTap: () async {
                                          if (microphone) {
                                            _stop();
                                          } else {
                                            if (await networkInfo.isConnected) {
                                              _start();
                                            } else {
                                              noInternt(context, 'تاكد من وجود انترنت');
                                            }
                                          }
                                        },
                                        primaryColor: Colors.white,
                                        primaryIcon: Icon(
                                          Icons.mic,
                                          color: AppTheme.primaryColor,
                                        ),
                                        secondaryIcon: Icon(
                                          Icons.mic,
                                          color: Colors.white,
                                        ),
                                        secondaryColor: AppTheme.primaryColor,
                                        status: !microphone,
                                      ),
                                    ],
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
                              child: Stack(
                                children: [
                                  PageView.builder(
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
                                                              // For now, we'll just navigate
                                                              // In the full implementation, we'd check if recording is needed
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
                                  isProcces
                                    ? Dialog(
                                        surfaceTintColor: Colors.white,
                                        backgroundColor: Colors.white,
                                        shadowColor: Colors.white,
                                        insetAnimationDuration: Duration(seconds: 30),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        child: Container(
                                          height: 120,
                                          width: 70,
                                          margin: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppTheme.primaryColor, width: 4),
                                            borderRadius: BorderRadius.circular(20)
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(color: AppTheme.primaryColor),
                                              SizedBox(width: 10),
                                              Text(
                                                'جاري عمليه المطابقه ......',
                                                style: AppTheme.textTheme.displaySmall,
                                                overflow: TextOverflow.clip,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          )
                                        ),
                                      )
                                    : Container()
                                ],
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
                    .add(GetAIStory(storyId: widget.storyId));
              }
              return Container(); // Default empty container
            },
          ),
        ),
      ),
    );
  }
} 