import 'package:agora/common/client/agora_http_client.dart';
import 'package:agora/common/extension/date_extension.dart';
import 'package:agora/common/extension/thematique_extension.dart';
import 'package:agora/common/helper/crashlytics_helper.dart';
import 'package:agora/domain/consultation/consultation.dart';
import 'package:agora/domain/consultation/consultations_error_type.dart';
import 'package:agora/domain/consultation/details/consultation_details.dart';
import 'package:agora/domain/consultation/questions/consultation_question.dart';
import 'package:agora/domain/consultation/questions/responses/consultation_question_response.dart';
import 'package:agora/domain/consultation/summary/consultation_summary.dart';
import 'package:agora/domain/consultation/summary/consultation_summary_et_ensuite.dart';
import 'package:agora/infrastructure/consultation/repository/builder/consultation_questions_builder.dart';
import 'package:agora/infrastructure/consultation/repository/builder/consultation_responses_builder.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

abstract class ConsultationRepository {
  Future<GetConsultationsRepositoryResponse> fetchConsultations();

  Future<GetConsultationDetailsRepositoryResponse> fetchConsultationDetails({
    required String consultationId,
  });

  Future<GetConsultationQuestionsRepositoryResponse> fetchConsultationQuestions({
    required String consultationId,
  });

  Future<SendConsultationResponsesRepositoryResponse> sendConsultationResponses({
    required String consultationId,
    required List<ConsultationQuestionResponses> questionsResponses,
  });

  Future<GetConsultationSummaryRepositoryResponse> fetchConsultationSummary({
    required String consultationId,
  });
}

class ConsultationDioRepository extends ConsultationRepository {
  final AgoraDioHttpClient httpClient;
  final CrashlyticsHelper crashlyticsHelper;

  ConsultationDioRepository({required this.httpClient, required this.crashlyticsHelper});

  @override
  Future<GetConsultationsRepositoryResponse> fetchConsultations() async {
    try {
      final response = await httpClient.get(
        "/consultations",
      );
      final ongoingConsultations = response.data["ongoing"] as List;
      final finishedConsultations = response.data["finished"] as List;
      final answeredConsultations = response.data["answered"] as List;
      return GetConsultationsSucceedResponse(
        ongoingConsultations: ongoingConsultations.map((ongoingConsultation) {
          return ConsultationOngoing(
            id: ongoingConsultation["id"] as String,
            title: ongoingConsultation["title"] as String,
            coverUrl: ongoingConsultation["coverUrl"] as String,
            thematique: (ongoingConsultation["thematique"] as Map).toThematique(),
            endDate: (ongoingConsultation["endDate"] as String).parseToDateTime(),
            hasAnswered: ongoingConsultation["hasAnswered"] as bool,
          );
        }).toList(),
        finishedConsultations: finishedConsultations.map((finishedConsultation) {
          return ConsultationFinished(
            id: finishedConsultation["id"] as String,
            title: finishedConsultation["title"] as String,
            coverUrl: finishedConsultation["coverUrl"] as String,
            thematique: (finishedConsultation["thematique"] as Map).toThematique(),
            step: finishedConsultation["step"] as int,
          );
        }).toList(),
        answeredConsultations: answeredConsultations.map((answeredConsultation) {
          return ConsultationAnswered(
            id: answeredConsultation["id"] as String,
            title: answeredConsultation["title"] as String,
            coverUrl: answeredConsultation["coverUrl"] as String,
            thematique: (answeredConsultation["thematique"] as Map).toThematique(),
            step: answeredConsultation["step"] as int,
          );
        }).toList(),
      );
    } catch (e, s) {
      if (e is DioError) {
        if (e.type == DioErrorType.connectionTimeout || e.type == DioErrorType.receiveTimeout) {
          crashlyticsHelper.recordError(e, s, reason: "fetchConsultations failed : timeout error");
          return GetConsultationsFailedResponse(errorType: ConsultationsErrorType.timeout);
        }
      }
      crashlyticsHelper.recordError(e, s, reason: "fetchConsultations failed");
      return GetConsultationsFailedResponse();
    }
  }

  @override
  Future<GetConsultationDetailsRepositoryResponse> fetchConsultationDetails({
    required String consultationId,
  }) async {
    try {
      final response = await httpClient.get(
        "/consultations/$consultationId",
      );
      return GetConsultationDetailsSucceedResponse(
        consultationDetails: ConsultationDetails(
          id: response.data["id"] as String,
          title: response.data["title"] as String,
          coverUrl: response.data["coverUrl"] as String,
          thematique: (response.data["thematique"] as Map).toThematique(),
          endDate: (response.data["endDate"] as String).parseToDateTime(),
          questionCount: response.data["questionCount"] as String,
          estimatedTime: response.data["estimatedTime"] as String,
          participantCount: response.data["participantCount"] as int,
          participantCountGoal: response.data["participantCountGoal"] as int,
          description: response.data["description"] as String,
          tipsDescription: response.data["tipsDescription"] as String,
          hasAnswered: response.data["hasAnswered"] as bool,
        ),
      );
    } catch (e, s) {
      crashlyticsHelper.recordError(e, s, reason: "fetchConsultationDetails failed");
      return GetConsultationDetailsFailedResponse();
    }
  }

  @override
  Future<GetConsultationQuestionsRepositoryResponse> fetchConsultationQuestions({
    required String consultationId,
  }) async {
    try {
      final response = await httpClient.get(
        "/consultations/$consultationId/questions",
      );
      return GetConsultationQuestionsSucceedResponse(
        consultationQuestions: ConsultationQuestionsBuilder.buildQuestions(
          uniqueChoiceQuestions: response.data["questionsUniqueChoice"] as List,
          openedQuestions: response.data["questionsOpened"] as List,
          multipleChoicesQuestions: response.data["questionsMultipleChoices"] as List,
          chapters: response.data["chapters"] as List,
        ),
      );
    } catch (e, s) {
      crashlyticsHelper.recordError(e, s, reason: "fetchConsultationQuestions failed");
      return GetConsultationQuestionsFailedResponse();
    }
  }

  @override
  Future<SendConsultationResponsesRepositoryResponse> sendConsultationResponses({
    required String consultationId,
    required List<ConsultationQuestionResponses> questionsResponses,
  }) async {
    try {
      final response = await httpClient.post(
        "/consultations/$consultationId/responses",
        data: {
          "consultationId": consultationId,
          "responses": questionsResponses
              .map(
                (questionResponse) => {
                  "questionId": questionResponse.questionId,
                  "choiceIds": questionResponse.responseIds,
                  "responseText": questionResponse.responseText,
                },
              )
              .toList(),
        },
      );
      return SendConsultationResponsesSucceedResponse(
        shouldDisplayDemographicInformation: response.data["askDemographicInfo"] as bool,
      );
    } catch (e, s) {
      crashlyticsHelper.recordError(e, s, reason: "sendConsultationResponses failed");
      return SendConsultationResponsesFailureResponse();
    }
  }

  @override
  Future<GetConsultationSummaryRepositoryResponse> fetchConsultationSummary({
    required String consultationId,
  }) async {
    try {
      final response = await httpClient.get(
        "/consultations/$consultationId/responses",
      );
      final summary = ConsultationSummary(
        title: response.data["title"] as String,
        participantCount: response.data["participantCount"] as int,
        results: ConsultationResponsesBuilder.buildResults(
          uniqueChoiceResults: response.data["resultsUniqueChoice"] as List,
          multipleChoicesResults: response.data["resultsMultipleChoice"] as List,
        ),
        etEnsuite: ConsultationSummaryEtEnsuite(
          step: response.data["etEnsuite"]["step"] as int,
          description: response.data["etEnsuite"]["description"] as String,
        ),
      );
      return GetConsultationSummarySucceedResponse(consultationSummary: summary);
    } catch (e, s) {
      crashlyticsHelper.recordError(e, s, reason: "fetchConsultationSummary failed");
      return GetConsultationSummaryFailedResponse();
    }
  }
}

abstract class GetConsultationsRepositoryResponse extends Equatable {
  @override
  List<Object> get props => [];
}

class GetConsultationsSucceedResponse extends GetConsultationsRepositoryResponse {
  final List<ConsultationOngoing> ongoingConsultations;
  final List<ConsultationFinished> finishedConsultations;
  final List<ConsultationAnswered> answeredConsultations;

  GetConsultationsSucceedResponse({
    required this.ongoingConsultations,
    required this.finishedConsultations,
    required this.answeredConsultations,
  });

  @override
  List<Object> get props => [
        ongoingConsultations,
        finishedConsultations,
        answeredConsultations,
      ];
}

class GetConsultationsFailedResponse extends GetConsultationsRepositoryResponse {
  final ConsultationsErrorType errorType;

  GetConsultationsFailedResponse({this.errorType = ConsultationsErrorType.generic});

  @override
  List<Object> get props => [errorType];
}

abstract class GetConsultationDetailsRepositoryResponse extends Equatable {
  @override
  List<Object> get props => [];
}

class GetConsultationDetailsSucceedResponse extends GetConsultationDetailsRepositoryResponse {
  final ConsultationDetails consultationDetails;

  GetConsultationDetailsSucceedResponse({required this.consultationDetails});

  @override
  List<Object> get props => [consultationDetails];
}

class GetConsultationDetailsFailedResponse extends GetConsultationDetailsRepositoryResponse {}

abstract class GetConsultationQuestionsRepositoryResponse extends Equatable {
  @override
  List<Object> get props => [];
}

class GetConsultationQuestionsSucceedResponse extends GetConsultationQuestionsRepositoryResponse {
  final List<ConsultationQuestion> consultationQuestions;

  GetConsultationQuestionsSucceedResponse({required this.consultationQuestions});

  @override
  List<Object> get props => [consultationQuestions];
}

class GetConsultationQuestionsFailedResponse extends GetConsultationQuestionsRepositoryResponse {}

abstract class SendConsultationResponsesRepositoryResponse extends Equatable {
  @override
  List<Object> get props => [];
}

class SendConsultationResponsesSucceedResponse extends SendConsultationResponsesRepositoryResponse {
  final bool shouldDisplayDemographicInformation;

  SendConsultationResponsesSucceedResponse({required this.shouldDisplayDemographicInformation});

  @override
  List<Object> get props => [shouldDisplayDemographicInformation];
}

class SendConsultationResponsesFailureResponse extends SendConsultationResponsesRepositoryResponse {}

abstract class GetConsultationSummaryRepositoryResponse extends Equatable {
  @override
  List<Object> get props => [];
}

class GetConsultationSummarySucceedResponse extends GetConsultationSummaryRepositoryResponse {
  final ConsultationSummary consultationSummary;

  GetConsultationSummarySucceedResponse({required this.consultationSummary});

  @override
  List<Object> get props => [consultationSummary];
}

class GetConsultationSummaryFailedResponse extends GetConsultationSummaryRepositoryResponse {}
