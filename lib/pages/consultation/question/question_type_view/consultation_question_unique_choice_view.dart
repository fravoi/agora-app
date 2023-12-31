import 'package:agora/bloc/consultation/question/consultation_questions_view_model.dart';
import 'package:agora/common/extension/string_extension.dart';
import 'package:agora/common/uuid/uuid_utils.dart';
import 'package:agora/design/custom_view/agora_question_response_choice_view.dart';
import 'package:agora/design/custom_view/button/agora_button.dart';
import 'package:agora/design/style/agora_button_style.dart';
import 'package:agora/design/style/agora_spacings.dart';
import 'package:agora/domain/consultation/questions/responses/consultation_question_response.dart';
import 'package:agora/pages/consultation/question/consultation_question_helper.dart';
import 'package:agora/pages/consultation/question/question_type_view/consultation_question_view.dart';
import 'package:flutter/material.dart';

class ConsultationQuestionUniqueChoiceView extends StatefulWidget {
  final ConsultationQuestionUniqueViewModel uniqueChoiceQuestion;
  final ConsultationQuestionResponses? previousSelectedResponses;
  final int totalQuestions;
  final Function(String questionId, String responseId, String otherResponse) onUniqueResponseTap;
  final VoidCallback onBackTap;

  ConsultationQuestionUniqueChoiceView({
    Key? key,
    required this.uniqueChoiceQuestion,
    required this.previousSelectedResponses,
    required this.totalQuestions,
    required this.onUniqueResponseTap,
    required this.onBackTap,
  }) : super(key: key);

  @override
  State<ConsultationQuestionUniqueChoiceView> createState() => _ConsultationQuestionUniqueChoiceViewState();
}

class _ConsultationQuestionUniqueChoiceViewState extends State<ConsultationQuestionUniqueChoiceView> {
  String currentQuestionId = "";
  String currentResponseId = "";
  String otherResponseText = "";
  bool showNextButton = false;
  bool shouldResetPreviousResponses = true;

  @override
  Widget build(BuildContext context) {
    _resetPreviousResponses();
    return ConsultationQuestionView(
      order: widget.uniqueChoiceQuestion.order,
      totalQuestions: widget.totalQuestions,
      questionProgress: widget.uniqueChoiceQuestion.questionProgress,
      title: widget.uniqueChoiceQuestion.title,
      popupDescription: widget.uniqueChoiceQuestion.popupDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildUniqueChoiceResponse(),
          if (showNextButton)
            AgoraButton(
              label: ConsultationQuestionHelper.buildNextButtonLabel(
                order: widget.uniqueChoiceQuestion.order,
                totalQuestions: widget.totalQuestions,
              ),
              style: AgoraButtonStyle.primaryButtonStyle,
              onPressed: currentResponseId.isNotBlank() && otherResponseText.isNotBlank()
                  ? () => widget.onUniqueResponseTap(
                        widget.uniqueChoiceQuestion.id,
                        currentResponseId,
                        otherResponseText,
                      )
                  : null,
            ),
          ...ConsultationQuestionHelper.buildBackButton(
            order: widget.uniqueChoiceQuestion.order,
            onBackTap: widget.onBackTap,
          ),
          ...ConsultationQuestionHelper.buildIgnoreButton(
            onPressed: () => widget.onUniqueResponseTap(widget.uniqueChoiceQuestion.id, UuidUtils.uuidZero, ""),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildUniqueChoiceResponse() {
    final List<Widget> responseWidgets = [];
    for (final response in widget.uniqueChoiceQuestion.responseChoicesViewModels) {
      responseWidgets.add(
        AgoraQuestionResponseChoiceView(
          responseId: response.id,
          responseLabel: response.label,
          hasOpenTextField: response.hasOpenTextField,
          isSelected: _isResponseAlreadySelected(response.id),
          previousOtherResponse: otherResponseText,
          onTap: (responseId) {
            currentResponseId = responseId;
            if (response.hasOpenTextField) {
              setState(() => showNextButton = true);
            } else {
              widget.onUniqueResponseTap(widget.uniqueChoiceQuestion.id, responseId, "");
            }
          },
          onOtherResponseChanged: (responseId, otherResponse) {
            if (currentResponseId == responseId) {
              setState(() => otherResponseText = otherResponse);
            } else {
              setState(() => otherResponseText = "");
            }
          },
        ),
      );
      responseWidgets.add(SizedBox(height: AgoraSpacings.base));
    }
    return responseWidgets;
  }

  void _resetPreviousResponses() {
    if (currentQuestionId != widget.uniqueChoiceQuestion.id) {
      currentQuestionId = widget.uniqueChoiceQuestion.id;
      shouldResetPreviousResponses = true;
    }
    if (shouldResetPreviousResponses) {
      currentResponseId = "";
      otherResponseText = "";
      final previousSelectedResponses = widget.previousSelectedResponses;
      if (previousSelectedResponses != null) {
        final previousResponseIds = previousSelectedResponses.responseIds;
        if (!previousResponseIds.contains(UuidUtils.uuidZero) && previousResponseIds.isNotEmpty) {
          currentResponseId = previousResponseIds[0];
          otherResponseText = previousSelectedResponses.responseText;
          if (otherResponseText.isNotBlank()) {
            showNextButton = true;
          }
        }
      }
      shouldResetPreviousResponses = false;
    }
  }

  bool _isResponseAlreadySelected(String responseId) {
    return currentResponseId == responseId;
  }
}
