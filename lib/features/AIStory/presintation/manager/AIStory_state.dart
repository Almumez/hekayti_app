part of 'AIStory_bloc.dart';

abstract class AIStoryState extends Equatable {
  const AIStoryState();
}

class AIStoryInitial extends AIStoryState {
  @override
  List<Object> get props => [];
}

class AIStoryLoading extends AIStoryState {
  @override
  List<Object> get props => [];
}

class AIStoryLoaded extends AIStoryState {
  final AIStoryModel storyModel;
  
  AIStoryLoaded({required this.storyModel});

  @override
  List<Object> get props => [storyModel];
}

class AIStoryError extends AIStoryState {
  final String errorMessage;

  AIStoryError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
} 