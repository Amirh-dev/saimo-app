import 'package:ferry/typed_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_modal_bottom_sheet.dart';
import 'package:simo_learn/utils/colors.dart';

/// One question/answer block inside an [openInfoModal].
class InfoSection {
  const InfoSection(this.heading, this.body);

  final String heading;
  final String body;
}

/// A themed info bottom sheet: a title with a colored icon badge, a divider,
/// then either a single [description] paragraph or a list of [sections]
/// (bold heading + paragraph), and a confirm button.
Future<void> openInfoModal(
  context, {
  required String title,
  String? iconAsset,
  Color iconColor = AppColors.done,
  String? description,
  List<InfoSection> sections = const [],
}) async {
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle. Wrapped in Center because the column is stretched,
                // which would otherwise force the handle to full width.
                Center(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 8, 0, 32),
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: AppColors.primary,
                    ),
                  ),
                ),

                // Header: title + colored icon badge
                Row(
                  children: [
                    Expanded(
                      child: ReText(
                        title,
                        textAlign: TextAlign.right,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                      ),
                    ),
                    if (iconAsset != null) ...[
                      const SizedBox(width: 16),
                      Container(
                        width: 58,
                        height: 58,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: iconColor,
                          boxShadow: [
                            BoxShadow(
                              color: iconColor.withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: SvgPicture.asset(
                          iconAsset,
                          width: 26,
                          height: 26,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
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

                // The column is stretched, so these ReTexts get the full width
                // and wrap over as many lines as needed (no ellipsis).
                if (description != null)
                  ReText(
                    description,
                    textAlign: TextAlign.right,
                    color: AppColors.black.withAlpha(140),
                    fontSize: 14,
                    lineHeight: 1.9,
                    maxLines: null,
                    overflow: TextOverflow.visible,
                  ),

                for (var i = 0; i < sections.length; i++) ...[
                  if (i > 0) const SizedBox(height: 28),
                  ReText(
                    sections[i].heading,
                    textAlign: TextAlign.right,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    maxLines: null,
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 10),
                  ReText(
                    sections[i].body,
                    textAlign: TextAlign.right,
                    color: AppColors.black.withAlpha(140),
                    fontSize: 14,
                    lineHeight: 1.9,
                    maxLines: null,
                    overflow: TextOverflow.visible,
                  ),
                ],

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