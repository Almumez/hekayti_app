part of 'GenritiveAI_bloc.dart';

abstract class GenritiveAIEvent extends Equatable {
  const GenritiveAIEvent();
}

class GenritiveAI extends GenritiveAIEvent {
  GenritiveAI();

  @override
  List<Object> get props => [];
}

class GenritiveAIStory extends GenritiveAIEvent {
  String hero_name, painting_style,story_topic;

  GenritiveAIStory({required this.hero_name, required this.painting_style,  required this.story_topic});

  @override
  List<Object> get props => [];
}
