import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:simo_learn/domain/repositories/repo_sample.dart';
import 'sample_state.dart';

class SampleCubit extends Cubit<SampleState> {
  final SampleRepository repository;

  SampleCubit(http.Client client)
      : repository = SampleRepository(client),
        super(const SampleInitial());

  Future<void> loadSamples() async {
    emit(const SampleLoading());
    try {
      final items = await repository.fetchSamples();
      emit(SampleSuccess(items));
    } catch (e) {
      emit(SampleError(e.toString()));
    }
  }

  Future<void> createQuickSample() async {
    emit(const SampleLoading());
    try {
      await repository
          .createSample('New Sample ${DateTime.now().millisecondsSinceEpoch}');
      final items = await repository.fetchSamples();
      emit(SampleSuccess(items));
    } catch (e) {
      emit(SampleError(e.toString()));
    }
  }
}
