import 'package:simo_learn/domain/models/sample_entity.dart';
import 'package:simo_learn/domain/repositories/endpoints.dart';
import 'repo_base.dart';

class SampleRepository extends BaseRepository {
  SampleRepository(super.client);

  Future<List<SampleEntity>> fetchSamples() async {
    final data = await readAll(Endpoints.samples);
    return data.map((json) => SampleEntity.fromJson(json)).toList();
  }

  Future<SampleEntity> fetchSample(int id) async {
    final data = await read(Endpoints.sampleById(id));
    return SampleEntity.fromJson(data);
  }

  Future<SampleEntity> createSample(String title) async {
    final data = await createByMap(
        {'title': title, 'body': '', 'userId': 1}, Endpoints.samples);
    return SampleEntity.fromJson(data);
  }
}
