import 'package:flutter/material.dart';
import 'package:simo_learn/features/feedback/feedback_repository.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/presentation/widgets/re_toast.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/fonts.dart';

/// Sends the text as a suggestion; admins see it with the other suggestions.
typedef SoundSuggestionSender = Future<void> Function(String body);

/// Added before the text so admins can tell sound requests apart.
const soundSuggestionPrefix = 'پیشنهاد صدا برای سالن مطالعه: ';

/// The default sender: the same `submitFeedback` the suggestions page uses.
SoundSuggestionSender feedbackSoundSender(FeedbackRepository repo) =>
    (body) => repo.submit(kind: FeedbackKind.suggestion, body: '$soundSuggestionPrefix$body');

Future<void> showSuggestSoundSheet(BuildContext context, SoundSuggestionSender send) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SuggestSoundSheet(send: send),
  );
}

class _SuggestSoundSheet extends StatefulWidget {
  const _SuggestSoundSheet({required this.send});

  final SoundSuggestionSender send;

  @override
  State<_SuggestSoundSheet> createState() => _SuggestSoundSheetState();
}

class _SuggestSoundSheetState extends State<_SuggestSoundSheet> {
  final _text = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _text.text.trim();
    if (text.characters.length < 3) {
      setState(() => _error = 'یه کم بیشتر بنویس.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.send(text);
      if (!mounted) return;
      Navigator.of(context).pop();
      showReToast(context, 'فرستاده شد. ممنون!', ReToastType.success);
    } catch (_) {
      if (mounted) {
        showReToast(context, 'فرستادن ناموفق بود. دوباره امتحان کن.', ReToastType.error);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.gray2,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      child: ReText(
                        'پیشنهاد صدا',
                        fontSize: 18,
                        fontWeight: 1000,
                        color: AppColors.black1,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    InkWell(
                      key: const ValueKey('suggest-sound-close'),
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.gray1,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 20, color: AppColors.black1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const ReText(
                  'چه صدایی دوست داری اینجا باشه؟ می‌خونیمش.',
                  fontSize: 12.5,
                  fontWeight: 700,
                  color: AppColors.gray,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.gray1,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    key: const ValueKey('suggest-sound-text'),
                    controller: _text,
                    autofocus: true,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 300,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.black1,
                      height: 1.7,
                      fontFamily: AppFonts.iranSansVar,
                      fontVariations: AppFonts.fontVariations(600),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      hintText: 'مثلاً صدای قطار شب، بازار، کلاس درس…',
                      hintStyle: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.gray,
                        fontFamily: AppFonts.iranSansVar,
                        fontVariations: AppFonts.fontVariations(600),
                      ),
                    ),
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 4),
                    child: ReText(
                      _error!,
                      fontSize: 12,
                      fontWeight: 800,
                      color: AppColors.errorColor,
                      textAlign: TextAlign.right,
                    ),
                  ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('suggest-sound-send'),
                        onPressed: _sending ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary.withAlpha(120),
                          minimumSize: const Size.fromHeight(52),
                          shape: const StadiumBorder(),
                        ),
                        child: _sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                              )
                            : const ReText('بفرست', fontSize: 15, fontWeight: 900, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.gray1,
                        minimumSize: const Size(96, 52),
                        shape: const StadiumBorder(),
                      ),
                      child: const ReText('لغو', fontSize: 15, fontWeight: 900, color: AppColors.black1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
