import 'package:ferry/typed_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_modal_bottom_sheet.dart';
import 'package:simo_learn/utils/colors.dart';

Future<void> openInfoModal(context) async {
  await showReModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 8, 0, 32),
                  width: 65,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: AppColors.primary,
                  ),
                ),
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ReText(
                            'سایمو آپدیت شد!',
                            textAlign: TextAlign.center,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                          SizedBox(height: 2),
                          ReText(
                            '۳ اسفند ۱۴۰۴',
                            textAlign: TextAlign.center,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.gray.withOpacity(0.18),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 17,
                          color: AppColors.gray.withOpacity(0.65),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Divider
                Container(
                  height: 1,
                  width: double.infinity,
                  color: AppColors.gray.withOpacity(0.12),
                ),

                const SizedBox(height: 24),

                // Intro
                Align(
                  alignment: Alignment.centerRight,
                  child: ReText(
                    'توی آپدیت جدید سایمو می تونی از قابلیت های جدیدی مثل:',
                    textAlign: TextAlign.right,
                    color: AppColors.black.withAlpha(140),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 16),

                // Features
                _buildInfoFeature(
                  'انتخاب تاریخ',
                ),
                _buildInfoFeature(
                  'تکرار هفتگی یا روزانه تسک ها',
                ),
                _buildInfoFeature(
                  'مدیریت تسک های انجام شده',
                ),
                _buildInfoFeature(
                  'بررسی وضعیت تسک های زمان دار و چک لیست',
                ),
                _buildInfoFeature(
                  'تاریخچه تسک ها',
                ),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerRight,
                  child: ReText(
                    'استفاده کنی!',
                    textAlign: TextAlign.right,
                    color: AppColors.black.withAlpha(140),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 42),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      side: BorderSide(
                        color: AppColors.gray.withOpacity(0.14),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(38),
                      ),
                      elevation: 0,
                    ),
                    child: const ReText(
                      'تایید',
                      fontSize: 20,
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildInfoFeature(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ReText(
            text,
            textAlign: TextAlign.right,
            fontSize: 13,
            color: AppColors.black.withAlpha(140),
          ),
        ),
        const SizedBox(width: 10),
        ReText(
          '•',
          fontSize: 13,
          color: AppColors.black.withAlpha(140),
        ),
      ],
    ),
  );
}

void showFreePremiumMessage(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const Icon(
                IconsaxPlusBold.star,
                size: 48,
                color: AppColors.primary,
              ),

              const SizedBox(height: 16),

              const ReText(
                'اشتراک ویژه رایگان شد!',
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),

              const SizedBox(height: 10),

              const ReText(
                'تا اطلاع ثانوی اشتراک ویژه برای همه کاربران به شکل رایگان فعال است.',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                fontSize: 15,
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    backgroundColor: AppColors.gray
                  ),
                  child: const ReText(
                    'متوجه شدم',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}