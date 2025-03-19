import 'package:flutter/material.dart';
import 'package:hikayati_app/core/util/ScreenUtil.dart';

import '../../../../core/AppTheme.dart';

class StoryThemeWidget extends StatelessWidget {
  String image;
  Function onTap;
  bool isSelected;
  String name;
  StoryThemeWidget({
    required this.image,
    required this.onTap,
    required this.isSelected,
    required this.name
  });
  ScreenUtil screenUtil = ScreenUtil();
  @override
  Widget build(BuildContext context) {
    screenUtil.init(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: !isSelected
                      ? Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 2,
                        )
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Opacity(
                    opacity: isSelected ? 1.0 : 0.4,
                    child: Image.asset(
                      image,
                      width: 180,
                      height:isSelected ?170:160,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            isSelected?      Text(
              name,
              style: AppTheme.textTheme.displaySmall?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primaryColor : Colors.brown,
              ),
              textAlign: TextAlign.center,
            ):SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
