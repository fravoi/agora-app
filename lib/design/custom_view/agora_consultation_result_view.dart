import 'package:agora/bloc/consultation/summary/consultation_summary_view_model.dart';
import 'package:agora/common/strings/consultation_strings.dart';
import 'package:agora/design/custom_view/agora_consultation_result_bar.dart';
import 'package:agora/design/style/agora_spacings.dart';
import 'package:agora/design/style/agora_text_styles.dart';
import 'package:flutter/material.dart';

class AgoraConsultationResultView extends StatelessWidget {
  final String questionTitle;
  final List<ConsultationSummaryResponseViewModel> responses;
  final bool isMultipleChoice;

  AgoraConsultationResultView({
    Key? key,
    required this.questionTitle,
    required this.responses,
    required this.isMultipleChoice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AgoraSpacings.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
              Text(questionTitle, style: AgoraTextStyles.medium17),
              SizedBox(height: AgoraSpacings.x1_5),
            ] +
            _buildResponses(),
      ),
    );
  }

  List<Widget> _buildResponses() {
    final List<Widget> responseWidgets = [];
    if (isMultipleChoice) {
      responseWidgets.add(Text(ConsultationStrings.severalResponsePossible, style: AgoraTextStyles.medium14));
      responseWidgets.add(SizedBox(height: AgoraSpacings.x0_75));
    }
    for (var response in responses) {
      responseWidgets.add(
        AgoraConsultationResultBar(
          ratio: response.ratio,
          response: response.label,
          minusPadding: AgoraSpacings.horizontalPadding * 2,
        ),
      );
      responseWidgets.add(SizedBox(height: AgoraSpacings.x0_75));
    }
    return responseWidgets;
  }
}
