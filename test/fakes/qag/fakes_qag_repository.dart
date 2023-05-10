import 'package:agora/domain/qag/details/qag_details.dart';
import 'package:agora/domain/qag/qag.dart';
import 'package:agora/domain/qag/qag_response.dart';
import 'package:agora/domain/thematique/thematique.dart';
import 'package:agora/infrastructure/qag/qag_repository.dart';

class FakeQagSuccessRepository extends QagRepository {
  @override
  Future<GetQagsRepositoryResponse> fetchQags({
    required String deviceId,
    required String? thematiqueId,
  }) async {
    return GetQagsSucceedResponse(
      qagResponses: [
        QagResponse(
          qagId: "qagId",
          thematique: Thematique(picto: "🚊", label: "Transports", color: "#FFFCF7CF"),
          title: "Pour la retraite : comment est-ce qu’on aboutit au chiffre de 65 ans ?",
          author: "author",
          authorPortraitUrl: "authorPortraitUrl",
          responseDate: DateTime(2024, 1, 23),
        ),
      ],
      qagPopular: [
        Qag(
          id: "id1",
          thematique: Thematique(picto: "🚊", label: "Transports", color: "#FFFCF7CF"),
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
          thematique: Thematique(picto: "🚊", label: "Transports", color: "#FFFCF7CF"),
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
          thematique: Thematique(picto: "🚊", label: "Transports", color: "#FFFCF7CF"),
          title: "title3",
          username: "username3",
          date: DateTime(2024, 3, 23),
          supportCount: 9,
          isSupported: true,
        ),
      ],
    );
  }

  @override
  Future<GetQagDetailsRepositoryResponse> fetchQagDetails({
    required String qagId,
    required String deviceId,
  }) async {
    return GetQagDetailsSucceedResponse(
      qagDetails: QagDetails(
        id: qagId,
        thematique: Thematique(picto: "🚊", label: "Transports", color: "#FFFCF7CF"),
        title: "Pour la retraite : comment est-ce qu’on aboutit au chiffre de 65 ans ?",
        description: "Le conseil d’orientation des retraites indique que les comptes sont à l’équilibre.",
        date: DateTime(2024, 1, 23),
        username: "CollectifSauvonsLaRetraite",
        support: QagDetailsSupport(count: 112, isSupported: true),
        response: null,
      ),
    );
  }

  @override
  Future<SupportQagRepositoryResponse> supportQag({required String qagId, required String deviceId}) async {
    return SupportQagSucceedResponse();
  }

  @override
  Future<DeleteSupportQagRepositoryResponse> deleteSupportQag({required String qagId, required String deviceId}) async {
    return DeleteSupportQagSucceedResponse();
  }

  @override
  Future<QagFeedbackRepositoryResponse> giveQagResponseFeedback({
    required String qagId,
    required String deviceId,
    required bool isHelpful,
  }) async {
    return QagFeedbackSuccessResponse();
  }
}

class FakeQagSuccessWithSupportNullAndResponseNotNullRepository extends FakeQagSuccessRepository {
  @override
  Future<GetQagDetailsRepositoryResponse> fetchQagDetails({
    required String qagId,
    required String deviceId,
  }) async {
    return GetQagDetailsSucceedResponse(
      qagDetails: QagDetails(
        id: qagId,
        thematique: Thematique(picto: "🚊", label: "Transports", color: "#FFFCF7CF"),
        title: "Pour la retraite : comment est-ce qu’on aboutit au chiffre de 65 ans ?",
        description: "Le conseil d’orientation des retraites indique que les comptes sont à l’équilibre.",
        date: DateTime(2024, 1, 23),
        username: "CollectifSauvonsLaRetraite",
        support: null,
        response: QagDetailsResponse(
          author: "Olivier Véran",
          authorDescription: "Ministre délégué auprès de...",
          responseDate: DateTime(2024, 2, 20),
          videoUrl: "https://betagouv.github.io/agora-content/QaG-Stormtrooper-Response.mp4",
          transcription: "Blablabla",
          feedbackStatus: true,
        ),
      ),
    );
  }

  @override
  Future<SupportQagRepositoryResponse> supportQag({required String qagId, required String deviceId}) async {
    return SupportQagSucceedResponse();
  }

  @override
  Future<DeleteSupportQagRepositoryResponse> deleteSupportQag({required String qagId, required String deviceId}) async {
    return DeleteSupportQagSucceedResponse();
  }
}

class FakeQagFailureRepository extends QagRepository {
  @override
  Future<GetQagsRepositoryResponse> fetchQags({
    required String deviceId,
    required String? thematiqueId,
  }) async {
    return GetQagsFailedResponse();
  }

  @override
  Future<GetQagDetailsRepositoryResponse> fetchQagDetails({
    required String qagId,
    required String deviceId,
  }) async {
    return GetQagDetailsFailedResponse();
  }

  @override
  Future<SupportQagRepositoryResponse> supportQag({required String qagId, required String deviceId}) async {
    return SupportQagFailedResponse();
  }

  @override
  Future<DeleteSupportQagRepositoryResponse> deleteSupportQag({required String qagId, required String deviceId}) async {
    return DeleteSupportQagFailedResponse();
  }

  @override
  Future<QagFeedbackRepositoryResponse> giveQagResponseFeedback({
    required String qagId,
    required String deviceId,
    required bool isHelpful,
  }) async {
    return QagFeedbackFailedResponse();
  }
}
