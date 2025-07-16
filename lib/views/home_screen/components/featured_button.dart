import 'package:emart_app/consts/consts.dart';
import 'package:flutter/material.dart';

Widget featuredButton({String? title, Widget? icon}) {
  return Row(
    children: [
      icon ?? const Icon(Icons.category, size: 60, color: Colors.grey),
      10.widthBox,
      title!.text.fontFamily(semibold).color(darkFontGrey).make(),
    ],
  )
      .box
      .white
      .width(200)
      .margin(const EdgeInsets.symmetric(horizontal: 4))
      .padding(const EdgeInsets.all(4))
      .roundedSM
      .outerShadowSm
      .make();
}

