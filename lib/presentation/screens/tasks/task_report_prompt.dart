import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/task_report_popup.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';
import 'package:simo_learn/presentation/screens/tasks/tasks_api.dart';
import 'package:simo_learn/presentation/widgets/re_toast.dart';

/// Asks for a report whenever a timed task runs out, on whatever screen the
/// user is. Lives beside the timer banner, above every route; draws nothing.
class TaskReportPrompt extends StatefulWidget {
  const TaskReportPrompt({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<TaskReportPrompt> createState() => _TaskReportPromptState();
}

class _TaskReportPromptState extends State<TaskReportPrompt> {
  StreamSubscription<Map<String, dynamic>>? _subscription;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _subscription = TaskTimerService.instance.completions.listen(_ask);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _ask(Map<String, dynamic> task) async {
    // A report already on screen wins; never stack two.
    if (_open) return;
    final overlayContext = widget.navigatorKey.currentState?.overlay?.context;
    if (overlayContext == null || task['id'] == null) return;

    final api = GraphQLTasksApi(context.read<GraphQLRepository>());
    _open = true;
    try {
      final saved = await showTaskReportPopup(
        overlayContext,
        initial: task['report'] as TaskReport?,
        onSubmit: (report) => api.saveReport(task, report),
      );
      if (saved == null || !overlayContext.mounted) return;
      task['report'] = saved;
      showReToast(overlayContext, 'گزارش تسک ثبت شد', ReToastType.success);
    } finally {
      _open = false;
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
