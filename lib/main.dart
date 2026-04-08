export 'package:simo_learn/app/app.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:simo_learn/app/app.dart';
import 'package:simo_learn/data/pr_sample/sample_cubit.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SampleCubit(http.Client())),
      ],
      child: const MyApp(),
    ),
  );
}
