import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/features/auth/cubit/auth_cubit.dart';
import 'package:simo_learn/presentation/screens/authentication/login/index.dart';
import 'package:simo_learn/presentation/screens/goals/index.dart';
import 'package:simo_learn/utils/_utils.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: AppFonts.iranSansVar,
        useMaterial3: true,
      ),
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return const GoalScreen();
          }

          if (state is AuthInitial) {
            return const Scaffold(
              backgroundColor: AppColors.gray1,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
