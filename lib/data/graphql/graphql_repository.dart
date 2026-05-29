import 'package:ferry/ferry.dart';
 
class GraphQLRepository {
  GraphQLRepository(this._client);

  final Client _client;

  Stream<OperationResponse<TData, TVars>> request<TData, TVars>(
    OperationRequest<TData, TVars> request,
  ) {
    return _client.request(request);
  }

  Future<OperationResponse<TData, TVars>> requestOnce<TData, TVars>(
    OperationRequest<TData, TVars> request,
  ) async {
    return _client.request(request).first;
  }
}