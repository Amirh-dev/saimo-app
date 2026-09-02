import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:simo_learn/features/dashboard/cubit/dashboard_state.dart';
import 'package:simo_learn/graphql/mutations/__generated__/create_task.ast.gql.dart';
import 'package:simo_learn/presentation/screens/chat/index.dart';
import 'package:simo_learn/presentation/screens/dashboard/activity_widget.dart';
import 'package:simo_learn/presentation/screens/tasks/add_task/index.dart';
import 'package:simo_learn/presentation/widgets/app_bottom_navigation_bar.dart';
import 'package:simo_learn/presentation/widgets/app_exit_guard.dart';
import 'package:simo_learn/presentation/widgets/modal.dart';
import 'package:simo_learn/presentation/widgets/re_header.dart';
import 'package:simo_learn/presentation/widgets/re_image.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/assets.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/helpers.dart';
import 'package:solar_icons/solar_icons.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardCubit>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) => AppExitGuard(
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: AppColors.gray1,
              bottomNavigationBar: AppBottomNavigationBar(
                currentIndex: 0,
                onTap: (index) => navigateToIndex(context, index, 0),
              ),
              body: state.isLoading || state.status == DashboardStatus.initial
                  ? const _DashboardSkeleton()
                  : _DashboardContent(
                      state: state,
                    ),
            );
          },
        ),
      );
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.state,
  });

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final now = Jalali.now();

    final tasks = state.tasks
        .map(
          (task) => task.toMap(),
        )
        .toList(growable: false);

    return Column(
      children: [
        Container(
          color: AppColors.white,
          child: SafeArea(
            child: Column(
              children: [
                reAppHeader(
                  'خوش آمدید',
                  firstIcon: GestureDetector(
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(SolarIconsOutline.bell, size: 24),
                    ),
                  ),
                  secondIcon: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (final _) => ChatScreen())),
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(SolarIconsOutline.chatRoundLine, size: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _dashboardUserInfo(state, context),
                const SizedBox(height: 24),
                _goals(state, context),
                const SizedBox(height: 24),
                TodayActivityWidget(
                  date: '${now.year}/${now.month}/${now.day}',
                  onAllTasksTap: () {
                    navigateToIndex(
                      context,
                      1,
                      0,
                    );
                  },
                  onAddTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (final _) => const AddTimedTaskScreen()),
                    );
                  },
                  tasks: tasks,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _goals(DashboardState state, context) {
    final goals = state.goals.map((goal) {
      final target = goal.targetDate?.toLocal();

      final today = DateTime.now();

      final todayDate = DateTime(
        today.year,
        today.month,
        today.day,
      );

      final targetDate = target == null
          ? null
          : DateTime(
              target.year,
              target.month,
              target.day,
            );

      final days = targetDate == null ? 0 : targetDate.difference(todayDate).inDays.clamp(0, 999999);

      return {
        'title': goal.title,
        'timeRemains': days,
      };
    }).toList(growable: false);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _OutlineButton(
                title: 'همه اهداف',
                icon: Icons.arrow_back_ios_new,
                onTap: () {
                  navigateToIndex(context, 2, 0);
                },
              ),
              const ReText(
                'اهداف',
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        goals.isEmpty
            ? const _EmptyGoals()
            : GoalsCarouselWidget(
                goals: goals,
              ),
      ],
    );
  }

  Widget _dashboardUserInfo(
    DashboardState state,
    BuildContext context,
  ) {
    final profile = state.profile;

    final isPremium = profile?.isPremium ?? false;

    final simoCoins = profile?.simoCoins ?? 0;

    final score = profile?.score ?? 0;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xffFCFCFC),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(48),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gray1,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: ReImage(
                        profile?.avatarURL ?? Assets.profilePlaceholder,
                        fit: BoxFit.cover,
                        width: 56,
                        height: 56,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ReText(
                            profile?.displayName ?? 'کاربر سایمو',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(height: 7),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.simoCoin,
                                  borderRadius: BorderRadius.circular(
                                    100,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ReText(
                                      isPremium ? 'کاربر ویژه' : 'کاربر عادی',
                                      fontSize: 11.5,
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    const Icon(
                                      SolarIconsOutline.stars,
                                      size: 14,
                                      color: AppColors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        navigateToIndex(
                          context,
                          4,
                          0,
                        );
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                        ),
                        child: const Icon(
                          IconsaxPlusLinear.setting_2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        value: '$score×',
                        label: 'ضریب امتیاز',
                        color: const Color(
                          0xFFFF3040,
                        ),
                        icon: SvgPicture.asset(
                          'assets/icons/flame.svg',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MetricCard(
                        value: '$simoCoins',
                        label: 'سایموکوین',
                        color: const Color(
                          0xFFFFC94C,
                        ),
                        icon: SvgPicture.asset(
                          'assets/icons/simo_coin.svg',
                          color: const Color(
                            0xffe56929,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _EmptyGoals extends StatelessWidget {
  const _EmptyGoals();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      alignment: Alignment.center,
      child: const ReText(
        'هنوز هدف فعالی ندارید',
        color: AppColors.gray,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFE4E5E8),
            Color(0xFFF7F7F8),
            Color(0xFFE4E5E8),
          ],
          stops: [
            0.25,
            0.5,
            0.75,
          ],
        ).createShader(bounds);
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            const _SkeletonUserInfo(),
            const SizedBox(height: 24),
            const _SkeletonGoals(),
            const SizedBox(height: 24),
            const _SkeletonActivity(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SkeletonUserInfo extends StatelessWidget {
  const _SkeletonUserInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const _SkeletonBox(
                width: 56,
                height: 56,
                radius: 100,
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _SkeletonBox(
                      width: 110,
                      height: 15,
                      radius: 8,
                    ),
                    SizedBox(height: 10),
                    _SkeletonBox(
                      width: 80,
                      height: 25,
                      radius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              const _SkeletonBox(
                width: 56,
                height: 56,
                radius: 100,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _SkeletonBox(
                  height: 62,
                  radius: 30,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _SkeletonBox(
                  height: 62,
                  radius: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonGoals extends StatelessWidget {
  const _SkeletonGoals();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _SkeletonBox(
                width: 90,
                height: 36,
                radius: 100,
              ),
              _SkeletonBox(
                width: 45,
                height: 18,
                radius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _SkeletonBox(
          width: double.infinity,
          height: 75,
          radius: 100,
          margin: EdgeInsets.symmetric(
            horizontal: 32,
          ),
        ),
      ],
    );
  }
}

class _SkeletonActivity extends StatelessWidget {
  const _SkeletonActivity();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _SkeletonBox(
                width: 90,
                height: 36,
                radius: 100,
              ),
              _SkeletonBox(
                width: 120,
                height: 18,
                radius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  7,
                  (index) {
                    return const _SkeletonBox(
                      width: 38,
                      height: 100,
                      radius: 100,
                    );
                  },
                ),
              ),
              const SizedBox(height: 45),
              const _SkeletonBox(
                width: double.infinity,
                height: 6,
                radius: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    this.width = double.infinity,
    required this.height,
    required this.radius,
    this.margin,
  });

  final double width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => openInfoModal(context),
            child: Container(
              width: 27,
              height: 27,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.gray2,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                SolarIconsOutline.infoCircle,
                size: 15,
                color: AppColors.black1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ReText(
                  value,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  maxLines: 1,
                ),
                ReText(
                  label,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(
                    0.28,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: icon,
          ),
        ],
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    super.key,
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
            color: AppColors.gray2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: AppColors.errorColor,
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

class GoalsCarouselWidget extends StatefulWidget {
  final List<Map<String, dynamic>> goals;

  const GoalsCarouselWidget({
    Key? key,
    required this.goals,
  }) : super(key: key);

  @override
  State<GoalsCarouselWidget> createState() => _GoalsCarouselWidgetState();
}

class _GoalsCarouselWidgetState extends State<GoalsCarouselWidget> {
  late PageController _pageController;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: 0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < widget.goals.length - 1) {
      _pageController.nextPage(
        duration: const Duration(
          milliseconds: 300,
        ),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(
          milliseconds: 300,
        ),
        curve: Curves.easeInOut,
      );
    }
  }

  String _toPersianNumber(
    String input,
  ) {
    const english = [
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
    ];

    const persian = [
      '۰',
      '۱',
      '۲',
      '۳',
      '۴',
      '۵',
      '۶',
      '۷',
      '۸',
      '۹',
    ];

    String result = input;

    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(
        english[i],
        persian[i],
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 75,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: -35,
                left: 45,
                right: 45,
                child: Container(
                  margin: const EdgeInsetsDirectional.symmetric(
                    horizontal: 32,
                  ),
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6E7EB),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(
                        50,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsetsDirectional.symmetric(
                  vertical: 4,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    100,
                  ),
                  color: const Color(
                    0xffFCFCFC,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        0.06,
                      ),
                      blurRadius: 15,
                      offset: const Offset(
                        0,
                        8,
                      ),
                    ),
                  ],
                ),
              ),
              PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: widget.goals.length,
                itemBuilder: (context, index) {
                  final goal = widget.goals[index];

                  final timeRemains = _toPersianNumber(
                    goal['timeRemains'].toString(),
                  );

                  return _buildGoalCard(
                    title: goal['title'],
                    timeRemains: timeRemains,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNavButton(
              icon: Icons.keyboard_arrow_left_rounded,
              onTap: _goToNextPage,
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 20,
              child: CustomPaint(
                painter: DashedLinePainter(),
              ),
            ),
            const SizedBox(width: 4),
            _buildCenterIndicator(),
            const SizedBox(width: 4),
            SizedBox(
              width: 20,
              child: CustomPaint(
                painter: DashedLinePainter(),
              ),
            ),
            const SizedBox(width: 4),
            _buildNavButton(
              icon: Icons.keyboard_arrow_right_rounded,
              onTap: _goToPreviousPage,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalCard({
    required String title,
    required String timeRemains,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 32.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.02,
            ),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 26,
        ),
        child: Row(
          children: [
            Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.grey.shade400,
              size: 16,
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ReText(
                  title,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const ReText(
                      'روز باقی مانده',
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    ReText(
                      timeRemains,
                      fontWeight: FontWeight.w600,
                      color: const Color(
                        0xFFF14922,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.black1,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildCenterIndicator() {
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(
            0xFFF14922,
          ).withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/goal.svg',
            width: 18,
          ),
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    double dashWidth = 4;
    double dashSpace = 3;
    double startX = 0;

    final paint = Paint()
      ..color = const Color(0xFFC4C5C9)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(
          startX,
          size.height / 2,
        ),
        Offset(
          startX + dashWidth,
          size.height / 2,
        ),
        paint,
      );

      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(
    CustomPainter oldDelegate,
  ) =>
      false;
}
