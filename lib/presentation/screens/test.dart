import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/features/profile/profile_cubit.dart';

class FerryTestView extends StatelessWidget {
  const FerryTestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            context.read<ProfileCubit>().getMe();
          },
          child: const Text('Test GetMe'),
        ),

        const SizedBox(height: 16),

        BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return switch (state) {
              ProfileInitial() => const Text('Press Test GetMe'),
              ProfileLoading() => const CircularProgressIndicator(),
              ProfileSuccess(:final userId) => Text('User ID: $userId'),
              ProfileFailure(:final message) => Text('Error: $message'),
            };
          },
        ),
      ],
    );
  }
}