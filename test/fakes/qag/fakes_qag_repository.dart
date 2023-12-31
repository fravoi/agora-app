import 'package:agora/domain/qag/details/qag_details.dart';
import 'package:agora/domain/qag/moderation/qag_moderation_list.dart';
import 'package:agora/domain/qag/qag.dart';
import 'package:agora/domain/qag/qag_paginated.dart';
import 'package:agora/domain/qag/qag_paginated_filter.dart';
import 'package:agora/domain/qag/qag_response.dart';
import 'package:agora/domain/qag/qag_response_incoming.dart';
import 'package:agora/domain/qag/qag_response_paginated.dart';
import 'package:agora/domain/qag/qag_similar.dart';
import 'package:agora/domain/qag/qags_error_type.dart';
import 'package:agora/domain/thematique/thematique.dart';
import 'package:agora/infrastructure/qag/qag_repository.dart';

class FakeQagSuccessRepository extends QagRepository {
  @override
  Future<CreateQagRepositoryResponse> createQag({
    required String title,
    required String description,
    required String author,
    required String thematiqueId,
  }) async {
    return CreateQagSucceedResponse(qagId: "qagId");
  }

  @override
  Future<GetQagsRepositoryResponse> fetchQags({
    required String? thematiqueId,
  }) async {
    return GetQagsSucceedResponse(
      qagResponsesIncoming: [
        QagResponseIncoming(
          qagId: "qagId2",
          thematique: Thematique(picto: "🚊", label: "Transports"),
          title: "Pour la ...",
          supportCount: 200,
          isSupported: true,
        ),
      ],
      qagResponses: [
        QagResponse(
          qagId: "qagId",
          thematique: Thematique(picto: "🚊", label: "Transports"),
          title: "Pour la retraite : comment est-ce qu'on aboutit au chiffre de 65 ans ?",
          author: "author",
          authorPortraitUrl: "authorPortraitUrl",
          responseDate: DateTime(2024, 1, 23),
        ),
      ],
      qagPopular: [
        Qag(
          id: "id1",
          thematique: Thematique(picto: "🚊", label: "Transports"),
          title: "title1",
          username: "username1",
          date: DateTime(2024, 1, 23),
          supportCount: 7,
          isSupported: true,
        ),
      ],
      qagLatest: [
        Qag(
          id: "id2",
          thematique: Thematique(picto: "🚊", label: "Transports"),
          title: "title2",
          username: "username2",
          date: DateTime(2024, 2, 23),
          supportCount: 8,
          isSupported: false,
        ),
      ],
      qagSupporting: [
        Qag(
          id: "id3",
          thematique: Thematique(picto: "🚊", label: "Transports"),
          title: "title3",
          username: "username3",
          date: DateTime(2024, 3, 23),
          supportCount: 9,
          isSupported: true,
        ),
      ],
      errorCase: null,
    );
  }

  @override
  Future<GetQagsPaginatedRepositoryResponse> fetchQagsPaginated({
    required int pageNumber,
    required String? thematiqueId,
    required QagPaginatedFilter filter,
  }) async {
    switch (pageNumber) {
      case 1:
        return GetQagsPaginatedSucceedResponse(
          maxPage: 3,
          paginatedQags: [
            QagPaginated(
              id: "id1",
              thematique: Thematique(picto: "🚊", label: "Transports"),
              title: "title1",
              username: "username1",
              date: DateTime(2024, 2, 23),
              supportCount: 8,
              isSupported: false,
            ),
          ],
        );
      case 2:
        return GetQagsPaginatedSucceedResponse(
          maxPage: 3,
          paginatedQags: [
            QagPaginated(
              id: "id2",
              thematique: Thematique(picto: "🚊", label: "Transports"),
              title: "title2",
              username: "username2",
              date: DateTime(2024, 3, 23),
              supportCount: 9,
              isSupported: true,
            ),
          ],
        );
      default:
        return GetQagsPaginatedSucceedResponse(
          maxPage: 3,
          paginatedQags: [
            QagPaginated(
              id: "id3",
              thematique: Thematique(picto: "🚊", label: "Transports"),
              title: "title3",
              username: "username3",
              date: DateTime(2024, 4, 23),
              supportCount: 9,
              isSupported: true,
            ),
          ],
        );
    }
  }

  @override
  Future<GetQagsResponsePaginatedRepositoryResponse> fetchQagsResponsePaginated({
    required int pageNumber,
  }) async {
    return GetQagsResponsePaginatedSucceedResponse(
      maxPage: 3,
      paginatedQagsResponse: [
        QagResponsePaginated(
          qagId: "qagId",
          thematique: Thematique(picto: "🚊", label: "Transports"),
          title: "Pour la ... ?",
          author: "author",
          authorPortraitUrl: "authorPortraitUrl",
          responseDate: DateTime(2024, 1, 23),
        ),
      ],
    );
  }

  @override
  Future<GetQagDetailsRepositoryResponse> fetchQagDetails({
    required String qagId,
  }) async {
    return GetQagDetailsSucceedResponse(
      qagDetails: QagDetails(
        id: qagId,
        thematique: Thematique(picto: "🚊", label: "Transports"),
        title: "Pour la retraite : comment est-ce qu'on aboutit au chiffre de 65 ans ?",
        description: "Le conseil d'orientation des retraites indique que les comptes sont à l'équilibre.",
        date: DateTime(2024, 1, 23),
        username: "CollectifSauvonsLaRetraite",
        canShare: false,
        canSupport: false,
        support: QagDetailsSupport(count: 112, isSupported: true),
        response: null,
      ),
    );
  }

  @override
  Future<SupportQagRepositoryResponse> supportQag({required String qagId}) async {
    return SupportQagSucceedResponse();
  }

  @override
  Future<DeleteSupportQagRepositoryResponse> deleteSupportQag({required String qagId}) async {
    return DeleteSupportQagSucceedResponse();
  }

  @override
  Future<QagFeedbackRepositoryResponse> giveQagResponseFeedback({
    required String qagId,
    required bool isHelpful,
  }) async {
    return QagFeedbackSuccessResponse();
  }

  @override
  Future<QagModerationListRepositoryResponse> fetchQagModerationList() async {
    return QagModerationListSuccessResponse(
      qagModerationList: QagModerationList(
        totalNumber: 120,
        qagsToModeration: [
          QagModeration(
            id: "id",
            thematique: Thematique(picto: "🚊", label: "Transports"),
            title: "title",
            description: "description",
            username: "username",
            date: DateTime(2024, 4, 23),
            supportCount: 9,
            isSupported: true,
          ),
        ],
      ),
    );
  }

  @override
  Future<ModerateQagRepositoryResponse> moderateQag({
    required String qagId,
    required bool isAccepted,
  }) async {
    return ModerateQagSuccessResponse();
  }

  @override
  Future<QagHasSimilarRepositoryResponse> hasSimilarQag({
    required String title,
  }) async {
    return QagHasSimilarSuccessResponse(hasSimilar: true);
  }

  @override
  Future<QagSimilarRepositoryResponse> getSimilarQags({
    required String title,
  }) async {
    return QagSimilarSuccessResponse(
      similarQags: [
        QagSimilar(
          id: "id",
          thematique: Thematique(picto: "🚊", label: "Transports"),
          title: "title",
          description: "description",
          username: "username",
          date: DateTime(2024, 4, 23),
          supportCount: 9,
          isSupported: true,
        ),
      ],
    );
  }
}

class FakeQagSuccessWithSupportNullAndResponseNotNullRepository extends FakeQagSuccessRepository {
  @override
  Future<GetQagDetailsRepositoryResponse> fetchQagDetails({
    required String qagId,
  }) async {
    return GetQagDetailsSucceedResponse(
      qagDetails: QagDetails(
        id: qagId,
        thematique: Thematique(picto: "🚊", label: "Transports"),
        title: "Pour la retraite : comment est-ce qu'on aboutit au chiffre de 65 ans ?",
        description: "Le conseil d'orientation des retraites indique que les comptes sont à l'équilibre.",
        date: DateTime(2024, 1, 23),
        username: "CollectifSauvonsLaRetraite",
        canShare: true,
        canSupport: true,
        support: QagDetailsSupport(count: 112, isSupported: true),
        response: QagDetailsResponse(
          author: "Olivier Véran",
          authorDescription: "Ministre délégué auprès de...",
          responseDate: DateTime(2024, 2, 20),
          videoUrl: "https://betagouv.github.io/agora-content/QaG-Stormtrooper-Response.mp4",
          videoWidth: 1080,
          videoHeight: 1920,
          transcription: "Blablabla",
          feedbackStatus: true,
        ),
      ),
    );
  }
}

class FakeQagSuccessWithAskQuestionErrorMessageRepository extends FakeQagSuccessRepository {
  @override
  Future<GetQagsRepositoryResponse> fetchQags({
    required String? thematiqueId,
  }) async {
    return GetQagsSucceedResponse(
      qagResponsesIncoming: [
        QagResponseIncoming(
          qagId: "qagId2",
          thematique: Thematique(picto: "🚊", label: "Transports"),
          title: "Pour la ...",
          supportCount: 200,
          isSupported: true,
        ),
      ],
      qagResponses: [
        QagResponse(
          qagId: "qagId",
          thematique: Thematique(picto: "🚊", label: "Transports"),
          title: "Pour la retraite : comment est-ce qu'on aboutit au chiffre de 65 ans ?",
          author: "author",
          authorPortraitUrl: "authorPortraitUrl",
          responseDate: DateTime(2024, 1, 23),
        ),
      ],
      qagPopular: [
        Qag(
          id: "id1",
          thematique: Thematique(picto: "🚊", label: "Transports"),
          title: "title1",
          username: "username1",
          date: DateTime(2024, 1, 23),
          supportCount: 7,
          isSupported: true,
        ),
      ],
      qagLatest: [
        Qag(
          id: "id2",
          thematique: Thematique(picto: "🚊", label: "Transports"),
          title: "title2",
          username: "username2",
          date: DateTime(2024, 2, 23),
          supportCount: 8,
          isSupported: false,
        ),
      ],
      qagSupporting: [
        Qag(
          id: "id3",
          thematique: Thematique(picto: "🚊", label: "Transports"),
          title: "title3",
          username: "username3",
          date: DateTime(2024, 3, 23),
          supportCount: 9,
          isSupported: true,
        ),
      ],
      errorCase: "Une erreur est survenue",
    );
  }
}

class FakeQagFailureRepository extends QagRepository {
  @override
  Future<CreateQagRepositoryResponse> createQag({
    required String title,
    required String description,
    required String author,
    required String thematiqueId,
  }) async {
    return CreateQagFailedResponse();
  }

  @override
  Future<GetQagsRepositoryResponse> fetchQags({
    required String? thematiqueId,
  }) async {
    return GetQagsFailedResponse();
  }

  @override
  Future<GetQagsPaginatedRepositoryResponse> fetchQagsPaginated({
    required int pageNumber,
    required String? thematiqueId,
    required QagPaginatedFilter filter,
  }) async {
    return GetQagsPaginatedFailedResponse();
  }

  @override
  Future<GetQagsResponsePaginatedRepositoryResponse> fetchQagsResponsePaginated({
    required int pageNumber,
  }) async {
    return GetQagsResponsePaginatedFailedResponse();
  }

  @override
  Future<GetQagDetailsRepositoryResponse> fetchQagDetails({
    required String qagId,
  }) async {
    return GetQagDetailsFailedResponse();
  }

  @override
  Future<SupportQagRepositoryResponse> supportQag({required String qagId}) async {
    return SupportQagFailedResponse();
  }

  @override
  Future<DeleteSupportQagRepositoryResponse> deleteSupportQag({required String qagId}) async {
    return DeleteSupportQagFailedResponse();
  }

  @override
  Future<QagFeedbackRepositoryResponse> giveQagResponseFeedback({
    required String qagId,
    required bool isHelpful,
  }) async {
    return QagFeedbackFailedResponse();
  }

  @override
  Future<QagModerationListRepositoryResponse> fetchQagModerationList() async {
    return QagModerationListFailedResponse();
  }

  @override
  Future<ModerateQagRepositoryResponse> moderateQag({
    required String qagId,
    required bool isAccepted,
  }) async {
    return ModerateQagFailedResponse();
  }

  @override
  Future<QagHasSimilarRepositoryResponse> hasSimilarQag({
    required String title,
  }) async {
    return QagHasSimilarFailedResponse();
  }

  @override
  Future<QagSimilarRepositoryResponse> getSimilarQags({
    required String title,
  }) async {
    return QagSimilarFailedResponse();
  }
}

class FakeQagTimeoutFailureRepository extends FakeQagFailureRepository {
  @override
  Future<GetQagsRepositoryResponse> fetchQags({
    required String? thematiqueId,
  }) async {
    return GetQagsFailedResponse(errorType: QagsErrorType.timeout);
  }
}

class FakeQagDetailsModerateFailureRepository extends FakeQagFailureRepository {
  @override
  Future<GetQagDetailsRepositoryResponse> fetchQagDetails({
    required String qagId,
  }) async {
    return GetQagDetailsModerateFailedResponse();
  }
}
