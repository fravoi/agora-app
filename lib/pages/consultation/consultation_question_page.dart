import 'package:agora/bloc/consultation/question/consultation_questions_bloc.dart';
import 'package:agora/bloc/consultation/question/consultation_questions_event.dart';
import 'package:agora/bloc/consultation/question/consultation_questions_state.dart';
import 'package:agora/bloc/consultation/question/response/stock/consultation_questions_responses_stock_bloc.dart';
import 'package:agora/bloc/consultation/question/response/stock/consultation_questions_responses_stock_event.dart';
import 'package:agora/bloc/consultation/question/response/stock/consultation_questions_responses_stock_state.dart';
import 'package:agora/common/client/repository_manager.dart';
import 'package:agora/design/custom_view/agora_error_view.dart';
import 'package:agora/design/custom_view/agora_questions_view.dart';
import 'package:agora/design/custom_view/agora_scaffold.dart';
import 'package:agora/domain/consultation/questions/consultation_question_type.dart';
import 'package:agora/domain/consultation/questions/responses/consultation_question_response.dart';
import 'package:agora/pages/consultation/consultation_question_confirmation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConsultationQuestionPage extends StatelessWidget {
  static const routeName = "/consultationQuestionPage";

  @override
  Widget build(BuildContext context) {
    final consultationId = ModalRoute.of(context)!.settings.arguments as String;
    return MultiBlocProvider(
      providers: [
        BlocProvider<ConsultationQuestionsBloc>(
          create: (BuildContext context) => ConsultationQuestionsBloc(
            consultationRepository: RepositoryManager.getConsultationRepository(),
          )..add(FetchConsultationQuestionsEvent(consultationId: consultationId)),
        ),
        BlocProvider<ConsultationQuestionsResponsesStockBloc>(
          create: (BuildContext context) => ConsultationQuestionsResponsesStockBloc(),
        ),
      ],
      child: AgoraScaffold(
        shouldPop: false,
        child: BlocBuilder<ConsultationQuestionsResponsesStockBloc, ConsultationQuestionsResponsesStockState>(
          builder: (context, responsesStockState) {
            return BlocConsumer<ConsultationQuestionsBloc, ConsultationQuestionsState>(
              listener: (context, state) {
                if (state is ConsultationQuestionsFinishState) {
                  Navigator.pushNamed(
                    context,
                    ConsultationQuestionConfirmationPage.routeName,
                    arguments: ConsultationQuestionConfirmationArguments(
                      consultationId: consultationId,
                      consultationQuestionsResponsesBloc: context.read<ConsultationQuestionsResponsesStockBloc>(),
                    ),
                  );
                }
              },
              builder: (context, questionsState) {
                if (questionsState is ConsultationQuestionsFetchedState) {
                  final currentQuestion = questionsState.viewModels[questionsState.currentQuestionIndex];
                  return AgoraQuestionsView(
                    questionId: currentQuestion.id,
                    questionText: currentQuestion.label,
                    currentQuestionOrder: currentQuestion.order,
                    currentQuestionType: currentQuestion.type,
                    totalQuestions: questionsState.viewModels.length,
                    maxChoices: _buildMaxChoices(currentQuestion.type, currentQuestion.maxChoices),
                    responses: currentQuestion.responseChoicesViewModels,
                    previousSelectedResponses: _getPreviousResponses(
                      questionId: currentQuestion.id,
                      inStockResponses: responsesStockState.questionsResponses,
                    ),
                    onUniqueResponseTap: (questionId, responseId) {
                      _saveAndNextQuestion(
                        context: context,
                        questionId: questionId,
                        responsesIds: [responseId],
                        openedResponse: "",
                      );
                    },
                    onOpenedResponseInput: (questionId, responseText) {
                      _saveAndNextQuestion(
                        context: context,
                        questionId: questionId,
                        responsesIds: [],
                        openedResponse: responseText,
                      );
                    },
                    onMultipleResponseTap: (questionId, responseIds) {
                      _saveAndNextQuestion(
                        context: context,
                        questionId: questionId,
                        responsesIds: responseIds,
                        openedResponse: "",
                      );
                    },
                    onBackTap: () {
                      context.read<ConsultationQuestionsBloc>().add(ConsultationPreviousQuestionEvent());
                    },
                  );
                } else if (questionsState is ConsultationQuestionsInitialLoadingState) {
                  return Center(child: CircularProgressIndicator());
                } else if (questionsState is ConsultationQuestionsErrorState) {
                  return Center(child: AgoraErrorView());
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          },
        ),
      ),
    );
  }

  void _saveAndNextQuestion({
    required BuildContext context,
    required String questionId,
    required List<String> responsesIds,
    required String openedResponse,
  }) {
    context.read<ConsultationQuestionsResponsesStockBloc>().add(
          AddConsultationQuestionsResponseStockEvent(
            questionResponse: ConsultationQuestionResponses(
              questionId: questionId,
              responseIds: responsesIds,
              responseText: openedResponse,
            ),
          ),
        );
    context.read<ConsultationQuestionsBloc>().add(ConsultationNextQuestionEvent());
  }

  int _buildMaxChoices(ConsultationQuestionType type, int? maxChoices) {
    if (type == ConsultationQuestionType.multiple) {
      return maxChoices ?? (throw Exception("max choices for multiple choices question not define"));
    } else {
      return -1; // value not important
    }
  }

  ConsultationQuestionResponses? _getPreviousResponses({
    required String questionId,
    required List<ConsultationQuestionResponses> inStockResponses,
  }) {
    try {
      return inStockResponses.firstWhere((inStockResponse) => inStockResponse.questionId == questionId);
    } catch (e) {
      return null;
    }
  }
}
