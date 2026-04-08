import 'package:equatable/equatable.dart';
import 'package:simo_learn/domain/models/sample_entity.dart';

abstract class SampleState extends Equatable {
  const SampleState();

  @override
  List<Object?> get props => [];
}

class SampleInitial extends SampleState {
  const SampleInitial();
}

class SampleLoading extends SampleState {
  const SampleLoading();
}

class SampleSuccess extends SampleState {
  final List<SampleEntity> items;

  const SampleSuccess(this.items);

  @override
  List<Object?> get props => [items];
}

class SampleError extends SampleState {
  final String message;

  const SampleError(this.message);

  @override
  List<Object?> get props => [message];
}
