import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  final String selectedIcon;
  final String unSelectedIcon;
  final String title;
  final Function? onTap;
  final bool isSelected;
  const BottomNavItemWidget({super.key, this.onTap, this.isSelected = false, required this.title, required this.selectedIcon, required this.unSelectedIcon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap as void Function()?,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

          Image.asset(
            isSelected ? selectedIcon : unSelectedIcon, height: 25, width: 25,
            // CHANGE 1: Use disabledColor instead of textTheme color
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
          ),

          SizedBox(height: isSelected ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall),

          Text(
            title,
            // CHANGE 2: Use disabledColor here too for text
            style: robotoRegular.copyWith(
              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, 
              fontSize: 12
            ),
          ),

        ]),
      ),
    );
  }
}