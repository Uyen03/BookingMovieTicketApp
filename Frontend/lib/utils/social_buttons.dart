import 'package:bookingmovieticket/utils/mytheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialLoginButtons extends StatelessWidget {
  final Function() onGoogleClick;
  final Function() onFbClick;
  const SocialLoginButtons(
      {Key? key, required this.onFbClick, required this.onGoogleClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Material(
            color: MyTheme.redLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: const BorderSide(color: MyTheme.redBorder, width: 0.2),
            ),
            child: InkWell(
              onTap: this.onGoogleClick,
              borderRadius: BorderRadius.circular(5),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
                child: Row(
                  children: [
                    SvgPicture.asset("assets/icons/google.svg"),
                    SizedBox(
                      width: 8,
                    ),
                    const Text("Google", style: TextStyle(color: Color(0xff666666),
                    fontWeight: FontWeight.w600),),
                  ],
                ),
              ),
            ),
          ),
        ),
       const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Material(
            color: MyTheme.blueLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: const BorderSide(color: MyTheme.blueBorder, width: 0.2),
            ),
            child: InkWell(
              onTap: onFbClick,
              borderRadius: BorderRadius.circular(5),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
                child: Row(
                  children: [
                    SvgPicture.asset("assets/icons/facebook.svg"),
                    const SizedBox(
                      width: 8,
                    ),
                    const Text("Facebook", style: TextStyle(color: Color(0xff666666),
                    fontWeight: FontWeight.w600,
                    ),),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
