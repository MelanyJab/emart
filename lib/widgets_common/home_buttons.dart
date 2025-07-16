import 'package:flutter/material.dart';
import 'package:emart_app/consts/consts.dart';

Widget homeButtons({
  required double height,
  required double width,
  required Icon icon,
  required String title,
  Function()? onTap,
  int count = 0,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          10.heightBox,
          Text(
            title,
            style: const TextStyle(
              fontFamily: semibold,
              color: darkFontGrey,
            ),
          ),
          if (count > 0)
            Text(
              "$count items",
              style: const TextStyle(
                fontSize: 10,
                color: darkFontGrey,
              ),
            ),
        ],
      ),
    ),
  );
}
