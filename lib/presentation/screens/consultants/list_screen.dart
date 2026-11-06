// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/presentation/screens/consultants/active_counselor_store.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/profile/user_major.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_models.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/counseling_checkout.dart';
import 'package:simo_learn/presentation/screens/consultants/details_screen.dart';
import 'package:simo_learn/presentation/screens/consultants/invoice_sheet.dart';
import 'package:simo_learn/presentation/screens/consultants/payment_tab.dart';
import 'package:simo_learn/presentation/screens/consultants/payment_tab_screen.dart';
import 'package:simo_learn/presentation/screens/consultants/payment_webview_screen.dart';
import 'package:simo_learn/presentation/screens/consultants/plans_sheet.dart';
import 'package:simo_learn/presentation/screens/consultants/reviews_sheet.dart';
import 'package:simo_learn/presentation/screens/consultants/success_sheet.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

/// Screen 2 of the consultants flow: the consultants list with expandable
/// (accordion) cards. Loads counselors from the API; when that fails it says
/// why (no access for this account, or a connection problem) instead.
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
  List<Consultant> _consultants = const [];
  bool _loading = true;

  /// Set when the list could not be loaded.
  _LoadFailure? _failure;

  /// True while the payment result is read back after the gateway closes;
  /// blocks the screen so a second purchase can't start mid-flow.
  bool _verifying = false;

  // The top match opens with its résumé and button showing.
  int _expandedIndex = 0;

  /// The student's major; null until known or when none is set.
  UserMajor? _studentMajor;

  @override
  void initState() {
    super.initState();
    _loadConsultants();
  }

  Future<void> _loadConsultants() async {
    ConsultantRepository? repo = _repository;
    if (repo == null) {
      try {
        repo = ConsultantRepository(context.read<GraphQLRepository>());
      } catch (_) {
        // No repository available (e.g. widget used outside the app shell).
        repo = null;
      }
      _repository = repo;
    }

    if (repo == null) {
      if (mounted) {
        setState(() {
          _failure = _LoadFailure.network;
          _loading = false;
        });
      }
      return;
    }

    if (_failure != null) {
      setState(() {
        _failure = null;
        _loading = true;
      });
    }

    try {
      final major = repo.fetchMyMajor();
      final counselors = await repo.fetchCounselors();
      final studentMajor = await major;
      if (!mounted) return;
      setState(() {
        _consultants = counselors;
        _studentMajor = studentMajor;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _failure = isCounselingAccessDenied(error)
            ? _LoadFailure.noAccess
            : _LoadFailure.network;
        _loading = false;
      });
    }
  }

  void _toggle(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? -1 : index;
    });
  }

  // Plan + duration → invoice → request + online payment.
  Future<void> _startConsultationFlow(
    BuildContext context,
    Consultant consultant,
  ) async {
    // Best-effort: fetch real offer prices up-front so the plans/invoice sheets
    // show the amounts the backend will actually charge. Falls back silently to
    // the static prices when unavailable.
    final offers = await _loadOffers(consultant);
    if (!context.mounted) return;

    final choice = await showPlansSheet(
      context,
      counselorName: consultant.name,
      plans: _plansFromOffers(offers),
    );
    if (choice == null || !context.mounted) return;

    await _payFromInvoice(context, consultant, choice);
  }

  Future<List<CounselingOffer>> _loadOffers(Consultant consultant) async {
    final repo = _repository;
    if (repo == null || consultant.id.isEmpty) return const [];
    try {
      return await repo.fetchOffers(consultant.id);
    } catch (_) {
      return const [];
    }
  }

  /// Replaces the static price list with the server's offers, so the sheet
  /// shows exactly the plans and durations that can be bought. Plans without
  /// any offer are left out.
  List<ConsultationPlan> _plansFromOffers(List<CounselingOffer> offers) {
    if (offers.isEmpty) return kPlans;
    final plans = <ConsultationPlan>[];
    for (final plan in kPlans) {
      final prices = {
        for (final offer in offers)
          if (offer.planType == plan.planType && offer.durationMonths > 0)
            offer.durationMonths: PlanPrice(
              months: offer.durationMonths,
              total: offer.totalPrice,
              baseTotal: offer.baseTotalPrice,
              discountPercent: offer.discountPercent,
            ),
      };
      if (prices.isNotEmpty) plans.add(plan.withPrices(prices));
    }
    return plans.isEmpty ? kPlans : plans;
  }

  /// Shows the invoice, and on "تایید و پرداخت" reserves the request and opens
  /// the bank gateway in-app, then verifies the payment. A cancelled or failed
  /// payment reopens the invoice with an explanation so the student can retry
  /// in one tap. The success dialog is shown ONLY when the server confirms the
  /// attempt SUCCEEDED and the subscription is ACTIVE. The charged amount is
  /// always the server-side cost, independent of the displayed price.
  Future<void> _payFromInvoice(
    BuildContext context,
    Consultant consultant,
    ConsultationChoice choice,
  ) async {
    final repo = _repository;
    final messenger = ScaffoldMessenger.of(context);

    // Nothing may be granted without a verified payment.
    if (repo == null || consultant.id.isEmpty) {
      messenger.showSnackBar(
        _snack('در حال حاضر امکان پرداخت وجود ندارد. لطفاً دوباره تلاش کنید.',
            error: true),
      );
      return;
    }
    final checkout = CounselingCheckout(repo);

    String? notice;
    var noticeIsError = false;
    // Kept across retries so a reopened invoice still shows the code.
    DiscountPreview? discount;
    while (true) {
      if (!context.mounted) return;
      PaymentTab? tab;
      final initiation = await showInvoiceSheet<PaymentInitiation>(
        context,
        choice: choice,
        notice: notice,
        noticeIsError: noticeIsError,
        discount: discount,
        checkDiscount: (code) => repo.previewDiscount(
          code: code,
          planType: choice.plan.planType,
          durationMonths: choice.months,
        ),
        onConfirm: (applied) async {
          discount = applied;
          // Web: open the tab now, while still inside the tap, or the
          // browser blocks it as a popup once the request below returns.
          if (kIsWeb) tab = openPaymentTab();
          try {
            final initiation = await checkout.start(
              counselorProfileID: consultant.id,
              durationMonths: choice.months,
              planType: choice.plan.planType,
              discountCode: applied?.code,
            );
            // Send the tab to the bank right away. It has the focus now, so
            // this tab is in the background, where the browser holds back
            // frames and the next screen would not build until the student
            // came back here.
            tab?.navigate(initiation.redirectURL);
            return initiation;
          } catch (_) {
            tab?.close();
            tab = null;
            rethrow;
          }
        },
      );
      if (initiation == null || !context.mounted) {
        tab?.close();
        return;
      }

      final result = await context.to<PaymentWebViewResult>(
        kIsWeb
            ? PaymentTabScreen(
                redirectURL: initiation.redirectURL,
                tab: tab,
                checkStatus: () =>
                    repo.fetchPaymentAttemptStatus(initiation.attemptID),
              )
            : PaymentWebViewScreen(redirectURL: initiation.redirectURL),
      );
      if (!mounted || !context.mounted) return;

      // Verify regardless of how the WebView closed: the bank may have
      // completed the transaction even if the student left early.
      setState(() => _verifying = true);
      final CheckoutOutcome outcome;
      try {
        outcome = await checkout.finish(
          initiation,
          returnedFromGateway: result == PaymentWebViewResult.completed,
        );
      } finally {
        if (mounted) setState(() => _verifying = false);
      }
      if (!context.mounted) return;

      switch (outcome.kind) {
        case CheckoutOutcomeKind.succeeded:
          unawaited(ActiveCounselorStore.instance.refresh(repo, force: true));
          await showConsultationSuccessSheet(context, choice: choice);
          return;
        case CheckoutOutcomeKind.pending:
        case CheckoutOutcomeKind.unknown:
          // Possibly charged: offering "pay again" here would invite a double
          // payment. The server activates the counselor once the bank settles.
          unawaited(ActiveCounselorStore.instance.refresh(repo, force: true));
          messenger.showSnackBar(_snack(outcome.message));
          return;
        case CheckoutOutcomeKind.cancelled:
        case CheckoutOutcomeKind.failed:
          notice = outcome.message;
          noticeIsError = outcome.kind == CheckoutOutcomeKind.failed;
      }
    }
  }

  SnackBar _snack(String message, {bool error = false}) {
    return SnackBar(
      backgroundColor: error ? AppColors.errorColor : AppColors.black1,
      duration: const Duration(seconds: 6),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: ReText(
          message,
          maxLines: 5,
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
      body: Stack(
        children: [
          _buildContent(context),
          if (_verifying) ...[
            const ModalBarrier(dismissible: false, color: Colors.black26),
            const Center(child: _VerifyingCard()),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(48),
              bottomRight: Radius.circular(48),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                const Spacer(),
                const ReText(
                  'مشاوران',
                  textAlign: TextAlign.start,
                  color: AppColors.black1,
                  fontSize: 16,
                  fontWeight: 1000,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    SolarIconsOutline.altArrowRight,
                    size: 22,
                    color: AppColors.black1,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: _buildList()),
      ],
    );
  }

  void _select(Consultant consultant) {
    if (widget.onSelect != null) {
      widget.onSelect!(consultant);
    } else {
      _startConsultationFlow(context, consultant);
    }
  }

  void _showDetails(Consultant consultant) {
    openConsultantDetails(
      context,
      consultant: consultant,
      repository: _repository,
      onSelect: () {
        if (mounted) _select(consultant);
      },
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    switch (_failure) {
      case _LoadFailure.noAccess:
        return const _ListMessage(
          icon: SolarIconsOutline.lockKeyhole,
          title: kCounselingNoAccessTitle,
          message: kCounselingNoAccessMessage,
        );
      case _LoadFailure.network:
        return _ListMessage(
          icon: SolarIconsOutline.dangerTriangle,
          title: 'دریافت فهرست مشاوران ممکن نشد',
          message: 'اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.',
          onRetry: _loadConsultants,
        );
      case null:
        break;
    }
    if (_consultants.isEmpty) {
      return const _ListMessage(
        icon: SolarIconsOutline.usersGroupRounded,
        title: 'فعلاً مشاوری در دسترس نیست',
        message: 'به‌زودی مشاوران جدید به این فهرست اضافه می‌شوند.',
      );
    }
    final matched = _studentMajor != null &&
        _consultants.every((c) => c.major == _studentMajor);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          _MatchHeading(
            major: _studentMajor,
            count: _consultants.length,
            matched: matched,
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < _consultants.length; index++) ...[
            if (index > 0) const SizedBox(height: 14),
            _ConsultantCard(
              consultant: _consultants[index],
              expanded: index == _expandedIndex,
              showMajor: !matched,
              onToggle: () => _toggle(index),
              onShowDetails: () => _showDetails(_consultants[index]),
              onSelect: () => _select(_consultants[index]),
            ),
          ],
        ],
      ),
    );
  }
}

enum _LoadFailure { noAccess, network }

/// Says why these counselors are listed: the student's major, or a calm note
/// when the list could not be narrowed down to it.
class _MatchHeading extends StatelessWidget {
  const _MatchHeading({
    required this.major,
    required this.count,
    required this.matched,
  });

  final UserMajor? major;
  final int count;
  final bool matched;

  @override
  Widget build(BuildContext context) {
    final major = this.major;
    final title = matched ? 'مشاوران رشته ${major!.label}' : 'همه مشاوران';
    final String? note;
    if (matched) {
      note = null;
    } else if (major == null) {
      note = 'برای دیدن مشاوران رشته خود، رشته‌تان را در پروفایل ثبت کنید.';
    } else {
      note = 'فعلاً مشاوری برای رشته ${major.label} نداریم.';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ReText(
                  title,
                  color: AppColors.black1,
                  fontSize: 16,
                  fontWeight: 900,
                  textAlign: TextAlign.right,
                ),
              ),
              ReText(
                '${convertToPersianNumbers(count.toString())} مشاور',
                color: AppColors.gray,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          if (note != null) ...[
            const SizedBox(height: 4),
            ReText(
              note,
              color: AppColors.gray,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.right,
              maxLines: 2,
              lineHeight: 1.6,
            ),
          ],
        ],
      ),
    );
  }
}

/// Takes the list's place when there is nothing to choose from.
class _ListMessage extends StatelessWidget {
  const _ListMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, size: 30, color: AppColors.secondary),
            ),
            const SizedBox(height: 18),
            ReText(
              title,
              color: AppColors.black1,
              fontSize: 16,
              fontWeight: 900,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            ReText(
              message,
              color: AppColors.gray,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
              lineHeight: 1.7,
              maxLines: 3,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: 160,
                child: ReButton(
                  text: 'تلاش دوباره',
                  background: AppColors.secondary,
                  borderRadius: 40,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  onPressed: onRetry,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shown over the list while the payment result is being confirmed.
class _VerifyingCard extends StatelessWidget {
  const _VerifyingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 48),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.black1,
            ),
          ),
          SizedBox(height: 16),
          ReText(
            'در حال بررسی وضعیت پرداخت',
            color: AppColors.black1,
            fontSize: 15,
            fontWeight: 900,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          ReText(
            'چند لحظه صبر کنید…',
            color: AppColors.gray,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
        ],
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
    required this.onShowDetails,
    required this.showMajor,
  });

  final Consultant consultant;
  final bool expanded;
  final bool showMajor;
  final VoidCallback onToggle;
  final VoidCallback onSelect;
  final VoidCallback onShowDetails;

  // A single shared curve/duration keeps the radius, size and fade in sync so
  // the card feels like one smooth morph rather than three separate tweens.
  static const Duration _animDuration = Duration(milliseconds: 280);
  static const Curve _animCurve = Curves.easeInOutCubic;

  /// The first résumé item is the counselor's strongest point; it is shown
  /// as the highlight, even on a closed card.
  ConsultantResumeItem? get _highlight =>
      consultant.resume.isEmpty ? null : consultant.resume.first;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _animDuration,
      curve: _animCurve,
      // Clip to the rounded corners so the expanding body never bleeds past
      // them mid-animation.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.whiteSec,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTopRow(),
          AnimatedSize(
            duration: _animDuration,
            curve: _animCurve,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: _animDuration,
              switchInCurve: _animCurve,
              switchOutCurve: _animCurve,
              child: expanded
                  ? KeyedSubtree(
                      key: const ValueKey('expanded'),
                      child: _buildExpandedBody(),
                    )
                  : KeyedSubtree(
                      key: const ValueKey('collapsed'),
                      child: _buildCollapsedBody(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _Avatar(path: consultant.avatar),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ReText(
                    consultant.name,
                    color: AppColors.black1,
                    fontSize: 16,
                    fontWeight: 900,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 2),
                  _buildSubtitle(),
                  if (showMajor && consultant.major != null) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gray1,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ReText(
                          consultant.major!.label,
                          color: AppColors.black1,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _ChevronButton(expanded: expanded, onTap: onToggle),
          ],
        ),
      ),
    );
  }

  /// «مشاور کنکور ریاضی، ★ ۴.۸ (۳۲ نظر)», or «…، مشاور جدید» before any
  /// rating, on one line.
  Widget _buildSubtitle() {
    TextStyle style(Color color, Object weight) => TextStyle(
          color: color,
          fontSize: 12,
          letterSpacing: -0.5,
          fontFamily: AppFonts.iranSansVar,
          fontVariations: AppFonts.fontVariations(weight),
        );
    final specialty = consultant.specialty;
    final rated = consultant.ratingCount > 0;
    return Text.rich(
      TextSpan(
        style: style(AppColors.gray, FontWeight.w600),
        children: [
          if (specialty.isNotEmpty) TextSpan(text: '$specialty، '),
          if (rated) ...[
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsetsDirectional.only(end: 3),
                child: Icon(
                  Icons.star_rounded,
                  size: 15,
                  color: AppColors.simoCoin,
                ),
              ),
            ),
            TextSpan(
              text: consultant.rating,
              style: style(AppColors.black1, 900),
            ),
            TextSpan(
              text:
                  ' (${convertToPersianNumbers(consultant.ratingCount.toString())} نظر)',
            ),
          ] else
            TextSpan(
              text: 'مشاور جدید',
              style: style(AppColors.black1, FontWeight.w700),
            ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }

  /// A closed card still shows the counselor's strongest point.
  Widget _buildCollapsedBody() {
    final highlight = _highlight;
    if (highlight == null) return const SizedBox(width: double.infinity);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          height: 36,
          padding: const EdgeInsetsDirectional.only(start: 5, end: 14),
          decoration: BoxDecoration(
            color: kCoinSoft,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CoinBadge(
                icon: SolarIconsOutline.cupStar,
                size: 26,
                iconSize: 14,
                glow: false,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: ReText(
                  highlight.title,
                  color: AppColors.black1,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedBody() {
    final highlight = _highlight;
    final rest = consultant.resume.skip(1).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (highlight != null) ...[
            Container(
              constraints: const BoxConstraints(minHeight: 60),
              padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 18, 10),
              decoration: BoxDecoration(
                color: kCoinSoft,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                children: [
                  const CoinBadge(icon: SolarIconsOutline.cupStar),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ReText(
                      highlight.title,
                      color: AppColors.black1,
                      fontSize: 16,
                      fontWeight: 900,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          for (final item in rest)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.black1,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ReText(
                      item.title,
                      color: AppColors.black1,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          if (consultant.bio.isNotEmpty) ...[
            if (rest.isNotEmpty) const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.gray2)),
              ),
              child: ReText(
                consultant.bio,
                color: AppColors.dark8Color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.right,
                lineHeight: 1.9,
                maxLines: 4,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              _DetailsButton(onTap: onShowDetails),
              const SizedBox(width: 8),
              Expanded(
                child: ReButton(
                  text: 'انتخاب مشاور',
                  background: AppColors.secondary,
                  borderRadius: 40,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  onPressed: onSelect,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// «جزئیات ‹», beside «انتخاب مشاور»; opens the counselor's details page.
class _DetailsButton extends StatelessWidget {
  const _DetailsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.gray1,
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReText(
                'جزئیات',
                color: AppColors.black1,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
              SizedBox(width: 4),
              Icon(
                SolarIconsOutline.altArrowLeft,
                size: 16,
                color: AppColors.black1,
              ),
            ],
          ),
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
        width: 44,
        height: 44,
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
      width: 60,
      height: 60,
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
