import 'package:flutter/material.dart';

import '../../../../core/AppTheme.dart';



class GenritiveAIWidget extends StatelessWidget {
  Function onTap;
  bool status;
  GenritiveAIWidget({super.key, required this.onTap, required this.status});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        onTap();
      },
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.primaryColor, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(15))),
        child: Center(
          child: Image.asset("assets/images/GenritiveAI.png", height: 30, width: 30,),
        ),
      ),
    );
  }
}
