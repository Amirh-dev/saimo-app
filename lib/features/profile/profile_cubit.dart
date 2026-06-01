import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/graphql/queries/__generated__/get_me.req.gql.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._graphql) : super(ProfileInitial());

  final GraphQLRepository _graphql;

  Future<void> getMe() async {
    emit(ProfileLoading());

    try {
      final response = await _graphql.requestOnce(
        GGetMeReq(),
      );

      if (response.hasErrors) {
        emit(ProfileFailure(graphQLResponseErrorMessage(response)));
        return;
      }

      final user = response.data?.getMe;

      if (user == null) {
        emit(
          const ProfileFailure(
            'User not found',
          ),
        );
        return;
      }

      emit(
        ProfileSuccess(
          user.id,
        ),
      );
    } catch (e) {
      emit(
        ProfileFailure(
          e.toString(),
        ),
      );
    }
  }
}
