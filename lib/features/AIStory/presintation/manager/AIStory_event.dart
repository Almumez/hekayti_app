part of 'AIStory_bloc.dart';

abstract class AIStoryEvent extends Equatable {
  const AIStoryEvent();
}

class GetAIStory extends AIStoryEvent {
  final String storyId;
  
  GetAIStory({required this.storyId});

  @override
  List<Object> get props => [storyId];
} 