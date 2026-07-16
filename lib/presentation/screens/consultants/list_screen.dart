// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_models.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/details_sheet.dart';
import 'package:simo_learn/presentation/screens/consultants/invoice_sheet.dart';
import 'package:simo_learn/presentation/screens/consultants/plans_sheet.dart';
import 'package:simo_learn/presentation/screens/consultants/success_sheet.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_header.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

/// Screen 2 of the consultants flow: the consultants list with expandable
/// (accordion) cards. Loads counselors from the API, falls back to sample data
/// when the request fails (e.g. offline or not signed in).
class ConsultantListScreen extends StatefulWidget {
  const ConsultantListScreen({super.key, this.onSelect});

  /// Fires when the user taps "انتخاب مشاور" on an expanded card. When null,
  /// the screen drives the full request flow itself.
  final ValueChanged<Consultant>? onSelect;

  @override
  State<ConsultantListScreen> createState() => _ConsultantListScreenState();
}

class _ConsultantListScreenState extends State<ConsultantListScreen> {
  ConsultantRepository? _repository;
  List<Consultant> _consultants = kSampleConsultants;
  bool _loading = true;
  bool _fromApi = false;

  // Second card expanded by default, matching the design.
  int _expandedIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadConsultants();
  }

  Future<void> _loadConsultants() async {
    ConsultantRepository? repo;
    try {
      repo = ConsultantRepository(context.read<GraphQLRepository>());
    } catch (_) {
      // No repository available (e.g. widget used outside the app shell).
      repo = null;
    }
    _repository = repo;

    if (repo == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      final counselors = await repo.fetchCounselors();
      if (!mounted) return;
      setState(() {
        if (counselors.isNotEmpty) {
          _consultants = counselors;
          _fromApi = true;
        }
        _loading = false;
      });
    } catch (_) {
      // Keep sample data as a graceful fallback.
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggle(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? -1 : index;
    });
  }

  // Screen 3 (duration) → 4 (plans) → 5 (invoice) → API request.
  Future<void> _startConsultationFlow(
    BuildContext context,
    Consultant consultant,
  ) async {
    final duration = await showConsultationDetailsSheet(context);
    if (duration == null || !context.mounted) return;

    final plan = await showPlansSheet(
      context,
      title: duration.planTitle,
      discount: duration.discount,
    );
    if (plan == null || !context.mounted) return;

    final paid =
        await showInvoiceSheet(context, duration: duration, plan: plan);
    if (paid != true || !context.mounted) return;

    await _submitRequest(consultant, duration, plan);
  }

  Future<void> _submitRequest(
    Consultant consultant,
    ConsultationDurationOption duration,
    ConsultationPlan plan,
  ) async {
    final repo = _repository;
    final messenger = ScaffoldMessenger.of(context);

    // With sample data (no repo / not from API) there is nothing real to
    // submit; treat it as a successful mock so the preview flow still completes.
    if (repo == null || !_fromApi || consultant.id.isEmpty) {
      if (!mounted) return;
      await showConsultationSuccessSheet(context, duration: duration, plan: plan);
      return;
    }

    try {
      await repo.requestCounseling(
        counselorProfileID: consultant.id,
        durationMonths: duration.months,
        planType: plan.planType,
      );
      if (!mounted) return;
      await showConsultationSuccessSheet(context, duration: duration, plan: plan);
    } catch (e) {
      messenger.showSnackBar(_snack('ثبت درخواست ناموفق بود: $e', error: true));
    }
  }

  SnackBar _snack(String message, {bool error = false}) {
    return SnackBar(
      backgroundColor: error ? AppColors.errorColor : AppColors.done,
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: ReText(
          message,
          color: AppColors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray1,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: reAppHeader(
                'مشاوران',
                prefixIcon: const SizedBox(width: 48),
                suffixIcon: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      SolarIconsOutline.altArrowRight,
                      size: 22,
                      color: AppColors.black1,
                    ),
                  ),
                ),
              ).bMargin(18),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
                      itemCount: _consultants.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final consultant = _consultants[index];
                        return _ConsultantCard(
                          consultant: consultant,
                          expanded: index == _expandedIndex,
                          onToggle: () => _toggle(index),
                          onSelect: () {
                            if (widget.onSelect != null) {
                              widget.onSelect!(consultant);
                            } else {
                              _startConsultationFlow(context, consultant);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsultantCard extends StatelessWidget {
  const _ConsultantCard({
    required this.consultant,
    required this.expanded,
    required this.onToggle,
    required this.onSelect,
  });

  final Consultant consultant;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(expanded ? 32 : 56),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 44,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopRow(),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: expanded
                ? _buildExpandedBody()
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      children: [
        _ChevronButton(expanded: expanded, onTap: onToggle),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNameRow(),
                  const SizedBox(height: 2),
                  ReText(
                    consultant.specialty,
                    color: expanded
                        ? AppColors.secondary
                        : AppColors.black1.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              _Avatar(path: consultant.avatar),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNameRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 13, color: AppColors.simoCoin),
        const SizedBox(width: 3),
        ReText(
          consultant.rating,
          color: AppColors.black1,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          textDirection: TextDirection.ltr,
        ),
        ReText(
          '/${consultant.maxRating}',
          color: AppColors.black1.withOpacity(0.5),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          textDirection: TextDirection.ltr,
        ),
        const SizedBox(width: 8),
        ReText(
          consultant.name,
          color: AppColors.black1,
          fontSize: 14,
          fontWeight: 900,
        ),
      ],
    );
  }

  Widget _buildExpandedBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ReText(
            'رزومه مشاور',
            color: AppColors.gray,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < consultant.resume.length; i++)
            _buildResumeItem(consultant.resume[i], i + 1),
          const SizedBox(height: 8),
          ReButton(
            text: 'انتخاب مشاور',
            background: AppColors.secondary,
            borderRadius: 40,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            onPressed: onSelect,
          ),
        ],
      ),
    );
  }

  Widget _buildResumeItem(ConsultantResumeItem item, int number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray2),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.black1,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ReText(
                number.toString(),
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ReText(
                item.title,
                color: AppColors.black1,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChevronButton extends StatelessWidget {
  const _ChevronButton({required this.expanded, required this.onTap});

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          expanded
              ? SolarIconsOutline.altArrowUp
              : SolarIconsOutline.altArrowDown,
          size: 18,
          color: AppColors.black1.withOpacity(expanded ? 1 : 0.5),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.gray2,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    const fallback = Icon(SolarIconsBold.user, size: 24, color: AppColors.gray);
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}
