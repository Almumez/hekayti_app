import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:hikayati_app/dataProviders/error/failures.dart';
import 'package:equatable/equatable.dart';

import '../../date/model/AIStoryModel.dart';
import '../../date/repository/AIStoryRepository.dart';

part 'AIStory_event.dart';
part 'AIStory_state.dart';

class AIStoryBloc extends Bloc<AIStoryEvent, AIStoryState> {
  final AIStoryRepository repository;
  AIStoryBloc({required this.repository}) : super(AIStoryInitial());
  
  @override
  Stream<AIStoryState> mapEventToState(AIStoryEvent event) async* {
    if (event is GetAIStory) {
      yield AIStoryLoading();
      final failureOrData = await repository.getAIStory(event.storyId);
      yield* failureOrData.fold(
        (failure) async* {
          log('yield is error');
          yield AIStoryError(errorMessage: mapFailureToMessage(failure));
        },
        (data) async* {
          log('yield is loaded');
          yield AIStoryLoaded(storyModel: data);
        },
      );
    }
  }
} 