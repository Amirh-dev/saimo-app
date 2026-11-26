import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/feedback/feedback_repository.dart';
import 'package:simo_learn/features/study_hall/hall_sounds.dart';
import 'package:simo_learn/presentation/screens/study_hall/sound_panel.dart';
import 'package:simo_learn/presentation/screens/study_hall/suggest_sound_sheet.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';

/// Stand-alone page for the sound panel until the «میز کار من» screen exists;
/// there the panel becomes the «صدا» tab under the window.
class HallSoundsScreen extends StatefulWidget {
  const HallSoundsScreen({super.key, this.mixer, this.suggest});

  /// Tests pass a mixer with a fake player.
  final HallSoundMixer? mixer;

  /// Sends a sound suggestion; defaults to the suggestions API.
  final SoundSuggestionSender? suggest;

  @override
  State<HallSoundsScreen> createState() => _HallSoundsScreenState();
}

class _HallSoundsScreenState extends State<HallSoundsScreen> {
  late final HallSoundMixer _mixer = widget.mixer ?? HallSoundMixer();

  @override
  void initState() {
    super.initState();
    _mixer.restore(play: true);
  }

  @override
  void dispose() {
    if (widget.mixer == null) _mixer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  children: [
                    const Expanded(
                      child: ReText(
                        'صدای پنجره',
                        fontSize: 20,
                        fontWeight: 1000,
                        color: AppColors.black1,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    ListenableBuilder(
                      listenable: _mixer,
                      builder: (context, _) => ReText(
                        _mixer.onCount == 0 ? 'همه خاموش' : '${_mixer.onCount} صدا روشن',
                        fontSize: 12,
                        fontWeight: 800,
                        color: AppColors.gray,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: HallSoundPanel(
                  mixer: _mixer,
                  onSuggest: () => showSuggestSoundSheet(
                    context,
                    widget.suggest ??
                        feedbackSoundSender(FeedbackRepository(context.read<GraphQLRepository>())),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
