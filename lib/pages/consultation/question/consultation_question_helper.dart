import 'package:agora/common/strings/consultation_strings.dart';
import 'package:agora/design/style/agora_colors.dart';
import 'package:agora/design/style/agora_spacings.dart';
import 'package:agora/design/style/agora_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConsultationQuestionHelper {
  static List<Widget> buildBackButton({required int order, required VoidCallback onBackTap}) {
    if (order != 1) {
      return [
        SizedBox(height: AgoraSpacings.x1_5),
        InkWell(
          onTap: () => onBackTap(),
          child: SizedBox(
            width: 200,
            child: Column(
              children: [
                Row(
                  children: [
                    SvgPicture.asset("assets/ic_backward.svg"),
                    SizedBox(width: AgoraSpacings.base),
                    Expanded(
                      child: Text(
                        ConsultationStrings.previousQuestion,
                        style: AgoraTextStyles.light16.copyWith(color: AgoraColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
                Divider(height: 10, color: AgoraColors.primaryBlue, thickness: 1),
              ],
            ),
          ),
        ),
      ];
    } else {
      return [];
    }
  }

  static String buildNextButtonLabel({required int order, required totalQuestions}) {
    return order == totalQuestions ? ConsultationStrings.validate : ConsultationStrings.nextQuestion;
  }
}
