part of 'GenritiveAI_bloc.dart';

abstract class GenritiveAIEvent extends Equatable {
  const GenritiveAIEvent();
}

class GenritiveAI extends GenritiveAIEvent {
  GenritiveAI();

  @override
  List<Object> get props => [];
}

// class Login extends GenritiveAIEvent {
//   String email, password;
//
//   Login({required this.email, required this.password});
//
//   @override
//   List<Object> get props => [];
// }
