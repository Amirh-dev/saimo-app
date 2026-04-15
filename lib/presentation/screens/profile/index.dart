import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/screens/app_navigation_tabs.dart';
import 'package:simo_learn/presentation/screens/tasks/index.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_image.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray1,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(42),
                        bottomRight: Radius.circular(42))),
                child: Column(
                  children: [
                    header().tMargin(20).hMargin(36),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16)
                          .copyWith(top: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: const Color(0xFFF5F5F9),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const ReText(
                                    'علیرضا یوسفی',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Row(
                                        children: [
                                          ReText(
                                            'تا پایان اشتراک ویژه',
                                            color: AppColors.black1,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 13,
                                          ),
                                          ReText(
                                            '24 روز',
                                            color: AppColors.black1,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 13,
                                          ),
                                        ],
                                      ).rMargin(4),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: AppColors.simoCoin,
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                        child: const Row(
                                          children: [
                                            ReText(
                                              'کاربر ویژه',
                                              fontSize: 14,
                                              color: AppColors.white,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            Icon(
                                              SolarIconsOutline.magicStick,
                                              size: 15,
                                              color: AppColors.white,
                                            ),
                                          ],
                                        ).hMargin(8).vMargin(2),
                                      ),
                                    ],
                                  ).tMargin(5)
                                ],
                              ).rMargin(16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: const ReImage(
                                    width: 50,
                                    height: 50,
                                    'assets/images/sample_profile.png'),
                              ).rMargin(16).vMargin(16),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: AppColors.white),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(color: AppColors.gray2),
                                  ),
                                  child: const Icon(
                                    SolarIconsOutline.infoCircle,
                                    size: 20,
                                  ).vMargin(4).hMargin(4),
                                ),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Row(
                                          children: [
                                            ReText(
                                              '36',
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              isBold: true,
                                            ),
                                            ReText(
                                              '79.',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                            )
                                          ],
                                        ).rMargin(8),
                                        const ReText(
                                          'سایموکوین',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.black1,
                                        )
                                      ],
                                    ).rMargin(4),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                                color: AppColors.simoCoin
                                                    .withOpacity(0.3),
                                                blurRadius: 10,
                                                spreadRadius: 1,
                                                offset: const Offset(0, 5))
                                          ],
                                          color: AppColors.simoCoin,
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                    )
                                  ],
                                ).hMargin(16).vMargin(10),
                              ],
                            ),
                          )
                        ],
                      ).bMargin(12).hMargin(10),
                    ),
                  ],
                ).bMargin(12),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: AppColors.gray2),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.replay_rounded,
                              size: 15,
                            ),
                            ReText('بروزرسانی'),
                          ],
                        ),
                      ),
                      const ReText(
                        'حساب کاربری',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ).hMargin(16).tMargin(20).bMargin(10),
                  profileItem('اشتراک ویژه', SolarIconsOutline.user,
                      AppColors.secondary, () {}),
                  profileItem('مشخصات حساب', SolarIconsOutline.user,
                          AppColors.secondary, () {})
                      .vMargin(12),
                  profileItem('تنظیمات', SolarIconsOutline.settings,
                      AppColors.secondary, () {}),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: profileItem(
                            'پشتیبانی',
                            SolarIconsOutline.headphonesRound,
                            AppColors.black1,
                            () {}),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Flexible(
                        flex: 0,
                        child: profileItem('خروج', SolarIconsOutline.logout,
                            AppColors.errorColor, () {
                          context.to(const TasksScreen());
                        }, showSuffixIcon: false),
                      ),
                    ],
                  ).vMargin(12)
                ],
              ).hMargin(36),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 4,
        onTap: (index) => _onBottomNavigationTap(context, index),
      ),
    );
  }

  void _onBottomNavigationTap(BuildContext context, int index) {
    if (index == 4) return;
    switch (index) {
      case 0:
        context.toOff(const HomeScreen());
        break;
      case 1:
        context.toOff(const TrophiesScreen());
        break;
      case 2:
        context.toOff(const TasksScreen());
        break;
      case 3:
        context.toOff(const TimerScreen());
        break;
    }
  }

  GestureDetector profileItem(
      String title, IconData icon, Color itemColor, Function onTap,
      {bool? showSuffixIcon}) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 26),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: AppColors.white,
        ),
        child: Row(
          mainAxisAlignment: !(showSuffixIcon == false)
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.end,
          children: [
            if (!(showSuffixIcon == false))
              Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: itemColor,
              ),
            Row(
              children: [
                ReText(
                  title,
                  color: AppColors.black1,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ).rMargin(10),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: itemColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: itemColor,
                    size: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Row header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: AppColors.gray2),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              const Icon(
                SolarIconsOutline.bell,
                size: 20,
              ).vMargin(10).hMargin(10),
              Container(
                margin: const EdgeInsets.only(top: 5, right: 5),
                alignment: Alignment.topRight,
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: AppColors.errorColor),
              )
            ],
          ),
        ),
        const ReText(
          'پروفایل',
          fontSize: 16,
          isBold: true,
        ),
      ],
    );
  }
}
