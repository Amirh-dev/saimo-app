import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_header.dart';
import 'package:simo_learn/presentation/widgets/re_image.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late final Jalali _today;
  late Jalali _selectedDate;

  final List<String> _weekDays = [
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه شنبه',
    'چهارشنبه',
    'پنجشنبه',
    'جمعه',
  ];

  final List<String> _persianMonths = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  @override
  void initState() {
    super.initState();
    _today = Jalali.now();
    _selectedDate = _today;
  }

  List<Jalali> get _weekDaysList {
    return List.generate(7, (index) => _today.addDays(index - 3));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.gray1,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    reAppHeader(
                      'تسک ها',
                      suffixIcon: const Icon(
                        SolarIconsOutline.history,
                      ),
                      prefixIcon: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.gray2,
                        ),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            const Icon(
                              SolarIconsOutline.bell,
                              size: 20,
                            ).vMargin(10).hMargin(10),
                            Container(
                              margin: const EdgeInsets.only(top: 5, right: 5),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: AppColors.errorColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 78,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray2,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Icon(
                              SolarIconsOutline.calendar,
                              color: AppColors.black1,
                            ),
                          ),
                          const SizedBox(width: 0),
                          Expanded(
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _weekDaysList.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 0),
                              itemBuilder: (context, index) {
                                final date = _weekDaysList[index];
                                final isSelected = date == _selectedDate;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedDate = date),
                                  child: isSelected
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.black1,
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 12,
                                          ),
                                          child: Center(
                                            child: ReText(
                                              '${convertToPersianNumbers(date.day.toString())} ${_persianMonths[date.month - 1]} ${convertToPersianNumbers(date.year.toString())}',
                                              fontSize: 13,
                                              isBold: true,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 35,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 0,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(height: 6),
                                              ReText(
                                                convertToPersianNumbers(
                                                  date.day.toString(),
                                                ),
                                                fontSize: 16,
                                                isBold: true,
                                                color: AppColors.black1,
                                              ),
                                            ],
                                          ),
                                        ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.gray2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add,
                          size: 18,
                          color: AppColors.primary,
                        ).rMargin(6),
                        const ReText(
                          'افزودن تسک',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.black1,
                        ),
                      ],
                    ),
                  ),
                  const ReText(
                    'تسک های امروز',
                    fontSize: 16,
                    isBold: true,
                    color: AppColors.black1,
                  ),
                ],
              ).hMargin(32).tMargin(16),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.gray2,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  labelColor: AppColors.black1,
                  unselectedLabelColor: AppColors.black1.withOpacity(0.5),
                  labelStyle: const TextStyle(
                    fontFamily: 'Sanse',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Sanse',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'چک لیست'),
                    Tab(text: 'زمان دار'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const ReImage(
                          'assets/images/empty_list.png',
                          width: 180,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 20),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 30),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: AppColors.white),
                              child: const Icon(Icons.add,
                                  size: 20, color: AppColors.primary),
                            ),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ReText(
                                  'چک لیستی ندارید!',
                                  fontSize: 16,
                                  isBold: true,
                                ),
                                ReText(
                                  'برای امروز تسکی اضافه نکردید.',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black1,
                                )
                              ],
                            ),
                          ],
                        ).tMargin(22)
                      ],
                    ),
                    const Center(
                      child: Text('Screen 2'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
