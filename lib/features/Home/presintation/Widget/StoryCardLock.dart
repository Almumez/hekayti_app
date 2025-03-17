import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hikayati_app/core/AppTheme.dart';

import '../../../../core/util/ScreenUtil.dart';
import '../../../../gen/assets.gen.dart';

class StoryCardLock extends StatefulWidget {
  final name;
  String photo;
  final starts;
  StoryCardLock(
      {Key? key, required this.name, required this.photo, required this.starts})
      : super(key: key);

  @override
  State<StoryCardLock> createState() => _StoryCardLockState();
}

class _StoryCardLockState extends State<StoryCardLock> {
  ScreenUtil screenUtil = ScreenUtil();
  @override
  Widget build(BuildContext context) {
    screenUtil.init(context);

    return Opacity(
      opacity: .7,
      child: Container(
        width: screenUtil.screenWidth * .25,
        height: screenUtil.screenHeight * .6,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage(
            Assets.images.storyBG.path,
          ),
          fit: BoxFit.contain,
        )),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  bool isStar = index < widget.starts;
                  return Padding(
                    padding: EdgeInsets.only(bottom: index == 1 ? 30.0 : 0.0),
                    child: Image.asset(
                      isStar
                          ? Assets.images.start.path
                          : Assets.images.emptyStar.path,
                      width: 40,
                      height: 40,
                    ),
                  );
                }),
              ),
              Container(
                height: screenUtil.screenHeight * .3,
                width: screenUtil.screenWidth * .14,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(alignment: Alignment.center, children: [
                    Container(
                      height: screenUtil.screenHeight * .3,
                      width: screenUtil.screenWidth * .14,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File('${widget.photo}'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Center(
                        child: Icon(
                      Icons.lock,
                      color: Color(0xFF4B3A29),
                      size: 50,
                    )),
                  ]),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                widget.name,
                style: AppTheme.textTheme.headlineSmall,
              )
            ]),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
}
