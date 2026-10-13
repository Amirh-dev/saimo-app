import 'dart:async';
import 'dart:ui';
import 'package:ferry/typed_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_screen.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

class TodayActivityWidget extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;
  final String date;
  final VoidCallback onAllTasksTap;
  final VoidCallback onAddTap; // Fix 3: Added callback for empty items

  const TodayActivityWidget({
    Key? key,
    required this.tasks,
    required this.date,
    required this.onAllTasksTap,
    required this.onAddTap,
  }) : super(key: key);

  @override
  State<TodayActivityWidget> createState() => _TodayActivityWidgetState();
}

class _TodayActivityWidgetState extends State<TodayActivityWidget>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  Timer? _tooltipTimer;

  /// Plays when the card first shows its tasks, and again when they change:
  /// the capsules rise in one after another, each fills up to its progress,
  /// and the day's bar and percentage follow.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  /// Every capsule's shape, whatever its state, so a filling one keeps the
  /// same round ends as the rest.
  static const BorderRadius _capsule = BorderRadius.all(Radius.circular(100));

  @override
  void initState() {
    super.initState();
    _intro.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) _intro.value = 1;
  }

  @override
  void didUpdateWidget(TodayActivityWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_signature(oldWidget.tasks) != _signature(widget.tasks) &&
        !reduceMotion(context)) {
      _intro.forward(from: 0);
    }
  }

  static String _signature(List<Map<String, dynamic>> tasks) => [
        for (final task in tasks) '${task['title']}:${task['percentage']}',
      ].join('|');

  /// Item [index]'s share of the intro: when it appears, then when it fills.
  Animation<double> _appear(int index) => CurvedAnimation(
        parent: _intro,
        curve: Interval(index * 0.06, index * 0.06 + 0.45,
            curve: Curves.easeOutCubic),
      );

  Animation<double> _fill(int index) => CurvedAnimation(
        parent: _intro,
        curve: Interval(0.2 + index * 0.06, 0.2 + index * 0.06 + 0.42,
            curve: Curves.easeInOutCubic),
      );

  late final Animation<double> _bar = CurvedAnimation(
    parent: _intro,
    curve: const Interval(0.35, 1, curve: Curves.easeOutCubic),
  );

  // Helper to convert digits to Persian
  String _toPersianNumber(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    String result = input;

    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], persian[i]);
    }

    return result;
  }

  // Fix 2 & 4: Smart Overlay Popup to prevent overflow
  void _showSmartPopup(
    BuildContext context,
    GlobalKey key,
    String title,
    int duration,
    Color color,
  ) {
    _removePopup();

    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine if the item is on the right or left half of the screen
    final isRightHalf = (offset.dx + (size.width / 2)) > (screenWidth / 2);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Invisible dismissible background
            Positioned.fill(
              child: GestureDetector(
                onTap: _removePopup,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.transparent),
              ),
            ),

            // The Tooltip Popup
            Positioned(
              top: offset.dy - 55,
              left: isRightHalf ? null : offset.dx,
              right:
                  isRightHalf ? (screenWidth - offset.dx - size.width) : null,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: isRightHalf
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ReText(
                            duration > 0
                                ? '$title ${_toPersianNumber(duration.toString())} دقیقه'
                                : '$title --',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 6),
                          SvgPicture.asset('assets/icons/timer.svg',
                              color: AppColors.white, width: 12)
                        ],
                      ),
                    ),

                    // Tooltip tail precisely pointing to the capsule
                    Container(
                      margin: EdgeInsets.only(
                        right: isRightHalf ? (size.width / 2) - 7 : 0,
                        left: !isRightHalf ? (size.width / 2) - 7 : 0,
                      ),
                      child: ClipPath(
                        clipper: TriangleClipper(),
                        child: Container(
                          color: color,
                          width: 14,
                          height: 7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    // Auto dismiss after 2.5 seconds
    _tooltipTimer = Timer(
      const Duration(milliseconds: 2500),
      _removePopup,
    );
  }

  void _removePopup() {
    _tooltipTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removePopup();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _HeaderOutlineButton(
                title: 'همه تسک ها',
                icon: Icons.arrow_back_ios_new,
                onTap: widget.onAllTasksTap,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const ReText(
                    'خلاصه فعالیت امروز',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF24242C),
                  ),
                  const SizedBox(height: 2),
                  ReText(
                    _toPersianNumber(widget.date),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Main Content Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xfffafafa),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                    left: 8, right: 8, top: 8, bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Tasks Row layout
                    SizedBox(
                      height: widget.tasks.isEmpty ? 135 : 172,
                      child: Stack(
                        children: [
                          // Fix 1: Mathematically centered Dashed Line
                          Positioned(
                            top: 115,
                            left: 0,
                            right: 0,
                            child: CustomPaint(
                              painter: DashedLinePainter(),
                              size: const Size(double.infinity, 2),
                            ),
                          ),

                          // Task Items
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(7, (index) {
                              final task = index < widget.tasks.length
                                  ? widget.tasks[index]
                                  : null;

                              final appear = _appear(index);
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3.0),
                                  child: AnimatedBuilder(
                                    animation: appear,
                                    builder: (context, child) => Opacity(
                                      opacity: appear.value,
                                      child: Transform.translate(
                                        offset:
                                            Offset(0, 14 * (1 - appear.value)),
                                        child: child,
                                      ),
                                    ),
                                    child: _buildTaskItem(task, _fill(index)),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                    ),
                    const SizedBox(height: 16),

                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(width: 8),
                        _buildStripedLegendItem('انجام نشده'),
                        const SizedBox(width: 16),
                        _buildLegendItem(
                          'انجام شده',
                          const Color(0xFF4263EB),
                        ),
                        const SizedBox(width: 16),
                        _buildLegendItem(
                          'درحال انجام',
                          const Color(0xFFF14922),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),

              // Progress Bar
              _buildProgressBar(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(Map<String, dynamic>? task, Animation<double> fill) {
    bool isEmpty = task == null || task.isEmpty;

    double percentage = isEmpty ? 0 : (task['percentage'] ?? 0).toDouble();

    bool isDone = percentage == 100;
    bool isDoing = percentage > 0 && percentage < 100;
    bool isNotStarted = percentage == 0 && !isEmpty;

    String title = task?['title'] ?? '';
    int duration = task?['maxDuration'] ?? 0;
    Color color = task?['percentage'] == 100
        ? const Color(0xFF4263EB)
        : const Color(0xFFF14922);

    // Unique key for tooltip anchor targeting
    final GlobalKey itemKey = GlobalKey();

    return GestureDetector(
      key: itemKey,
      onDoubleTap: isEmpty
          ? widget.onAddTap
          : () => Navigator.of(context).push(MaterialPageRoute(
              builder: (final _) => TaskTimerScreen(task: task, onPop: () {}))),
      onTap: isEmpty
          ? widget.onAddTap
          : () => _showSmartPopup(
                context,
                itemKey,
                title,
                duration,
                color,
              ),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 1. Top Capsule (Height: 100)
          Container(
            height: 93,
            decoration: BoxDecoration(
              borderRadius: _capsule,
              color: Colors.white,
              border: isEmpty ? Border.all(color: AppColors.gray2) : null,
            ),
            // The fill is a plain level clipped by the capsule, so the
            // bottom stays round however full it gets.
            child: ClipRRect(
              borderRadius: _capsule,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  if (isDoing)
                    Container(
                      color: const Color(0xFFF14922).withValues(alpha: 0.12),
                    ),
                  if (isDone || isDoing)
                    AnimatedBuilder(
                      animation: fill,
                      builder: (context, _) => FractionallySizedBox(
                        heightFactor:
                            (isDone ? 1.0 : percentage / 100) * fill.value,
                        widthFactor: 1,
                        child: ColoredBox(
                          color: isDone
                              ? const Color(0xFF426fEB)
                              : const Color(0xFFF14922),
                        ),
                      ),
                    ),
                  if (isNotStarted)
                    RotatedBox(
                      quarterTurns: 3,
                      child: CustomPaint(
                        painter: StripedPainter(
                          color: const Color(0xFFE5E7EB),
                        ),
                        size: const Size(
                          double.infinity,
                          double.infinity,
                        ),
                      ),
                    ),
                  if (isEmpty)
                    const Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.grey,
                        size: 20,
                      ),
                    )
                  else
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: isDoing
                                  ? const Color(0xfff26d4d)
                                  : isDone
                                      ? const Color(0xff607bf5)
                                      : AppColors.gray1,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 2),
                              child: ReText(
                                title,
                                fontSize: 10,
                                color: (isDone || isDoing)
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w400,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 2. Exact Spacing (Height: 16)
          const SizedBox(height: 8),

          // 3. Timer Circle aligned perfectly over Y=131 line
          DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isNotStarted
                    ? AppColors.gray2
                    : isEmpty
                        ? AppColors.white
                        : isDoing
                            ? const Color(0xfffbeae6)
                            : const Color(0xffe8ecfb),
                border: isEmpty
                    ? Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1.5,
                      )
                    : null,
                boxShadow: (isNotStarted || isEmpty)
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 6,
                        ),
                      ],
              ),
              child: isEmpty
                  ? const SizedBox.shrink()
                  : Center(
                      child: SvgPicture.asset(
                        'assets/icons/stop_watch.svg',
                        width: 11,
                        color: isDone
                            ? AppColors.secondary
                            : isDoing
                                ? AppColors.primary
                                : AppColors.black1,
                      ),
                    ),
            ),
          ),

          // 4. Texts Below
          if (!isEmpty) ...[
            const SizedBox(height: 8),
            ReText(
              task['durationText']?.toString() ??
                  _toPersianNumber(duration.toString()),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
            if ((task['durationText']?.toString() ?? '') != '--')
              ReText(
                'دقیقه',
                fontSize: 9,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ReText(
          title,
          fontSize: 11,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(width: 6),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildStripedLegendItem(String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: ClipOval(
            child: CustomPaint(
              painter: StripedPainter(
                color: Colors.grey.shade400,
                gap: 3,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        ReText(
          title,
          fontSize: 11,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    int totalMax = 0;
    int blueTotal = 0;
    int orangeTotal = 0;

    for (var task in widget.tasks) {
      if (task.isEmpty) continue;

      int maxDur = task['maxDuration'] ?? 0;
      double pct = (task['percentage'] ?? 0).toDouble();

      totalMax += maxDur;

      if (pct == 100) {
        blueTotal += maxDur;
      } else if (pct > 0) {
        orangeTotal += (maxDur * (pct / 100)).toInt();
      }
    }

    int totalDone = blueTotal + orangeTotal;

    int totalPercent =
        totalMax > 0 ? ((totalDone / totalMax) * 100).toInt() : 0;

    int grayTotal = totalMax - totalDone;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Counts up with the capsules.
          AnimatedBuilder(
            animation: _bar,
            builder: (context, _) => ReText(
              '${_toPersianNumber((totalPercent * _bar.value).round().toString())}٪',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                // Drawn in from the start as the capsules fill.
                child: AnimatedBuilder(
                  animation: _bar,
                  builder: (context, child) => Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: _bar.value,
                    child: child,
                  ),
                  child: Row(
                    children: [
                      if (blueTotal > 0)
                        Expanded(
                          flex: blueTotal,
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(50),
                              ),
                              color: Color(0xFF4263EB),
                            ),
                          ),
                        ),
                      if (orangeTotal > 0)
                        Expanded(
                          flex: orangeTotal,
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(50),
                              ),
                              color: Color(0xFFF14922),
                            ),
                          ),
                        ),
                      if (grayTotal > 0 || totalMax == 0)
                        Expanded(
                          flex: totalMax == 0 ? 1 : grayTotal,
                          child: Container(
                            height: 2,
                            color: const Color(0xFFE5E7EB),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ReText(
            'پیشرفت امروز',
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}

// ----------------- Helper Painters & Widgets ----------------- //

class StripedPainter extends CustomPainter {
  final Color color;
  final double gap;

  StripedPainter({
    required this.color,
    this.gap = 6.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..isAntiAlias = true;

    for (double i = -size.height; i < size.width; i += gap) {
      canvas.drawLine(
        Offset(i + size.height, size.height),
        Offset(i, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) =>
      false;
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 1;
    double dashSpace = 4;
    double startX = 0;

    final paint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );

      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _HeaderOutlineButton extends StatelessWidget {
  const _HeaderOutlineButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: const Color(0xFFF14922),
            ),
            const SizedBox(width: 7),
            ReText(
              title,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      ),
    );
  }
}
