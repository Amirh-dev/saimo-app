import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/data/pr_sample/sample_cubit.dart';
import 'package:simo_learn/data/pr_sample/sample_state.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';

class SampleMainScreen extends StatelessWidget {
  const SampleMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const ReText(AppStrings.appName, size: 20, weight: FontWeight.bold),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ReButton(
                    text: 'Load Samples',
                    onPressed: () => context.read<SampleCubit>().loadSamples(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ReButton(
                    text: 'Create Sample',
                    onPressed: () =>
                        context.read<SampleCubit>().createQuickSample(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<SampleCubit, SampleState>(
                builder: (context, state) {
                  if (state is SampleInitial) {
                    return const Center(
                        child: ReText('Press a button to start'));
                  } else if (state is SampleLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SampleSuccess) {
                    return ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return ListTile(
                          title: ReText(item.title),
                          subtitle: ReText('ID: ${item.id}'),
                        );
                      },
                    );
                  } else if (state is SampleError) {
                    return Center(child: ReText('Error: ${state.message}'));
                  }
                  return const Center(child: ReText('Unknown State'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
