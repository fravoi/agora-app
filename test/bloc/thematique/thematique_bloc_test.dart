import 'package:agora/bloc/thematique/thematique_bloc.dart';
import 'package:agora/bloc/thematique/thematique_event.dart';
import 'package:agora/bloc/thematique/thematique_state.dart';
import 'package:agora/bloc/thematique/thematique_with_id_view_model.dart';
import 'package:bloc_test/bloc_test.dart';

import '../../fakes/thematique/fakes_thematique_repository.dart';

void main() {
  blocTest(
    "fetchThematiqueEvent - when repository succeed - should emit success state",
    build: () => ThematiqueBloc(repository: FakeThematiqueSuccessRepository()),
    act: (bloc) => bloc.add(FetchThematiqueEvent()),
    expect: () => [
      ThematiqueSuccessState(
        [
          ThematiqueWithIdViewModel(id: "1", picto: "\ud83d\udcbc", label: "Travail & emploi", color: 0xFFCFDEFC),
          ThematiqueWithIdViewModel(id: "2", picto: "\ud83c\udf31", label: "Transition écologique", color: 0xFFCFFCD9),
          ThematiqueWithIdViewModel(id: "3", picto: "\ud83e\ude7a", label: "Santé", color: 0xFFFCCFDD),
          ThematiqueWithIdViewModel(id: "4", picto: "\ud83d\udcc8", label: "Economie", color: 0xFFCFF6FC),
          ThematiqueWithIdViewModel(id: "5", picto: "\ud83c\udf93", label: "Education", color: 0xFFFCE7CF),
          ThematiqueWithIdViewModel(id: "6", picto: "\ud83c\udf0f", label: "International", color: 0xFFE8CFFC),
          ThematiqueWithIdViewModel(id: "7", picto: "\ud83d\ude8a", label: "Transports", color: 0xFFFCF7CF),
          ThematiqueWithIdViewModel(id: "8", picto: "\ud83d\ude94", label: "Sécurité", color: 0xFFE1E7F3),
        ],
      )
    ],
    wait: const Duration(milliseconds: 5),
  );

  blocTest(
    "fetchThematiqueEvent - when repository failed - should emit failure state",
    build: () => ThematiqueBloc(repository: FakeThematiqueFailureRepository()),
    act: (bloc) => bloc.add(FetchThematiqueEvent()),
    expect: () => [ThematiqueErrorState()],
    wait: const Duration(milliseconds: 5),
  );
}
