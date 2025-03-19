import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:hikayati_app/dataProviders/error/failures.dart';

import 'package:equatable/equatable.dart';

import '../../date/model/GenritiveAIMode.dart';
import '../../date/repository/GenritiveAIRepository.dart';

part 'GenritiveAI_event.dart';
part 'GenritiveAI_state.dart';

class GenritiveAIBloc extends Bloc<GenritiveAIEvent, GenritiveAIState> {
  final GenritiveAIRepository repository;
  GenritiveAIBloc({required this.repository}) : super(GenritiveAIInitial());
  @override
  Stream<GenritiveAIState> mapEventToState(GenritiveAIEvent event) async* {
    if (event is GenritiveAI) {
      yield GenritiveAILoading();
      final failureOrData =
          await repository.GenritiveAI();
      yield* failureOrData.fold(
        (failure) async* {
          log('yield is error');
          yield GenritiveAIError(errorMessage: mapFailureToMessage(failure));
        },
        (data) async* {
          log('yield is loaded');
          yield GenritiveAILoaded(
            storyModel: data
          );
        },
      );
    }


    if (event is GenritiveAIStory) {
      yield GenritiveAIStoryLoading();
      final failureOrData =
          await repository.GenritiveAIStory(  story_topic: event.story_topic, hero_name: event.hero_name, painting_style: event.painting_style);
      yield* failureOrData.fold(
        (failure) async* {
          log('yield is error');
          yield GenritiveAIStoryError(errorMessage: mapFailureToMessage(failure));
        },
        (data) async* {
          log('yield is loaded');
          yield GenritiveAIStoryLoaded(storyModel: data);
        },
      );
    }
  }
}
