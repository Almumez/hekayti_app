part of 'GenritiveAI_bloc.dart';

abstract class GenritiveAIState extends Equatable {
  const GenritiveAIState();
}

class GenritiveAIInitial extends GenritiveAIState {
  @override
  List<Object> get props => [];
}

class GenritiveAILoading extends GenritiveAIState {
  @override
  List<Object> get props => [];
}

class GenritiveAILoaded extends GenritiveAIState {
  List<GenritiveAIMode> storyModel;
  GenritiveAILoaded({required this.storyModel});

  @override
  List<Object> get props => [storyModel];
}

class GenritiveAIError extends GenritiveAIState {
  String errorMessage;

  GenritiveAIError({required this.errorMessage});

  @override
  List<Object> get props => [];
}


class GenritiveAIStoryInitial extends GenritiveAIState {
  @override
  List<Object> get props => [];
}

class GenritiveAIStoryLoading extends GenritiveAIState {
  @override
  List<Object> get props => [];
}

class GenritiveAIStoryLoaded extends GenritiveAIState {
  GenritiveAIMode storyModel;
  GenritiveAIStoryLoaded({required this.storyModel});

  @override
  List<Object> get props => [storyModel];
}

class GenritiveAIStoryError extends GenritiveAIState {
  String errorMessage;

  GenritiveAIStoryError({required this.errorMessage});

  @override
  List<Object> get props => [];
}