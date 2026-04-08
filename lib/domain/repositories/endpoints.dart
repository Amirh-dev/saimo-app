class Endpoints {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String samples = '$baseUrl/posts';
  static String sampleById(int id) => '$baseUrl/posts/$id';
}
