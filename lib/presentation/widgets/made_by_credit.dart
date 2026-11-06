import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// «ساخته‌شده توسط [logo] تیم راوی», shown under the app version. Tapping it
/// opens the studio's website.
class MadeByCredit extends StatelessWidget {
  const MadeByCredit({super.key});

  static final site = Uri.parse('https://ravisite.com');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey('made-by-ravi'),
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        try {
          await launchUrl(site, mode: LaunchMode.externalApplication);
        } catch (_) {
          // A credit link failing to open is not worth an error message.
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.rtl,
          children: [
            const ReText(
              'ساخته‌شده توسط',
              color: AppColors.gray,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(width: 6),
            // Ravi's mark, taken from ravisite.com.
            SvgPicture.asset(
              'assets/icons/ravi_logo.svg',
              key: const ValueKey('ravi-logo'),
              height: 13,
              semanticsLabel: 'لوگوی راوی',
            ),
            const SizedBox(width: 5),
            const ReText(
              'تیم راوی',
              color: AppColors.black,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ],
        ),
      ),
    );
  }
}
