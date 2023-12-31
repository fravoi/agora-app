import 'package:agora/bloc/qag/qag_view_model.dart';
import 'package:agora/common/analytics/analytics_event_names.dart';
import 'package:agora/common/analytics/analytics_screen_names.dart';
import 'package:agora/common/helper/tracker_helper.dart';
import 'package:agora/common/strings/generic_strings.dart';
import 'package:agora/common/strings/qag_strings.dart';
import 'package:agora/design/custom_view/agora_alert_dialog.dart';
import 'package:agora/design/custom_view/agora_more_information.dart';
import 'package:agora/design/custom_view/agora_qag_incoming_response_card.dart';
import 'package:agora/design/custom_view/agora_qag_response_card.dart';
import 'package:agora/design/custom_view/agora_rich_text.dart';
import 'package:agora/design/custom_view/button/agora_button.dart';
import 'package:agora/design/custom_view/button/agora_rounded_button.dart';
import 'package:agora/design/style/agora_button_style.dart';
import 'package:agora/design/style/agora_spacings.dart';
import 'package:agora/design/style/agora_text_styles.dart';
import 'package:agora/pages/qag/details/qag_details_page.dart';
import 'package:agora/pages/qag/response_paginated/qags_response_paginated_page.dart';
import 'package:flutter/material.dart';

class QagsResponseSection extends StatelessWidget {
  final List<QagResponseTypeViewModel> qagResponseViewModels;

  const QagsResponseSection({super.key, required this.qagResponseViewModels});

  @override
  Widget build(BuildContext context) {
    if (qagResponseViewModels.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.only(
          left: AgoraSpacings.horizontalPadding,
          top: AgoraSpacings.base,
          right: AgoraSpacings.horizontalPadding,
          bottom: AgoraSpacings.x2,
        ),
        child: Column(
          children: [
            _buildQagResponseHeader(context),
            SizedBox(height: AgoraSpacings.x0_75),
            LayoutBuilder(
              builder: (context, constraint) {
                return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraint.maxWidth),
                    child: IntrinsicHeight(
                      // IntrinsicHeight : make all card same height
                      child: Row(children: _buildQagResponseCard(context, qagResponseViewModels)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildQagResponseHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AgoraRichText(
            items: [
              AgoraRichTextTextItem(text: "${QagStrings.qagResponsePart1}\n", style: AgoraRichTextItemStyle.bold),
              AgoraRichTextTextItem(text: QagStrings.qagResponsePart2, style: AgoraRichTextItemStyle.regular),
            ],
          ),
        ),
        SizedBox(width: AgoraSpacings.x0_75),
        AgoraMoreInformation(
          onClick: () {
            showAgoraDialog(
              context: context,
              columnChildren: [
                Text(QagStrings.qagResponseInfoBubble, style: AgoraTextStyles.light16),
                SizedBox(height: AgoraSpacings.x0_75),
                AgoraButton(
                  label: GenericStrings.close,
                  style: AgoraButtonStyle.primaryButtonStyle,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        ),
        SizedBox(width: AgoraSpacings.x0_75),
        AgoraRoundedButton(
          label: GenericStrings.all,
          style: AgoraRoundedButtonStyle.greyBorderButtonStyle,
          onPressed: () => Navigator.pushNamed(context, QagResponsePaginatedPage.routeName),
        ),
      ],
    );
  }

  List<Widget> _buildQagResponseCard(BuildContext context, List<QagResponseTypeViewModel> qagResponses) {
    final List<Widget> qagWidget = List.empty(growable: true);
    for (final qagResponse in qagResponses) {
      if (qagResponse is QagResponseViewModel) {
        qagWidget.add(
          AgoraQagResponseCard(
            title: qagResponse.title,
            thematique: qagResponse.thematique,
            authorImageUrl: qagResponse.authorPortraitUrl,
            author: qagResponse.author,
            date: qagResponse.responseDate,
            style: AgoraQagResponseStyle.small,
            onClick: () {
              TrackerHelper.trackClick(
                clickName: "${AnalyticsEventNames.answeredQag} ${qagResponse.qagId}",
                widgetName: AnalyticsScreenNames.qagsPage,
              );
              Navigator.pushNamed(
                context,
                QagDetailsPage.routeName,
                arguments: QagDetailsArguments(qagId: qagResponse.qagId),
              );
            },
          ),
        );
      } else if (qagResponse is QagResponseIncomingViewModel) {
        qagWidget.add(
          AgoraQagIncomingResponseCard(
            title: qagResponse.title,
            thematique: qagResponse.thematique,
            supportCount: qagResponse.supportCount,
            isSupported: qagResponse.isSupported,
            onClick: () {
              TrackerHelper.trackClick(
                clickName: "${AnalyticsEventNames.incomingAnsweredQag} ${qagResponse.qagId}",
                widgetName: AnalyticsScreenNames.qagsPage,
              );
              Navigator.pushNamed(
                context,
                QagDetailsPage.routeName,
                arguments: QagDetailsArguments(qagId: qagResponse.qagId),
              );
            },
          ),
        );
      }
      qagWidget.add(SizedBox(width: AgoraSpacings.x0_5));
    }
    return qagWidget;
  }
}
