// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/presentation/screens/consultants/active_counselor_store.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_models.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/counseling_checkout.dart';
import 'package:simo_learn/presentation/screens/consultants/invoice_sheet.dart';
import 'package:simo_learn/presentation/screens/consultants/payment_tab.dart';
import 'package:simo_learn/presentation/screens/consultants/payment_tab_screen.dart';
import 'package:simo_learn/presentation/screens/consultants/payment_webview_screen.dart';
import 'package:simo_learn/presentation/screens/consultants/plans_sheet.dart';
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

  // Second card expanded by default, matching the design.
  int _expandedIndex = 1;

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
      final counselors = await repo.fetchCounselors();
      if (!mounted) return;
      setState(() {
        _consultants = counselors;
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
    while (true) {
      if (!context.mounted) return;
      PaymentTab? tab;
      final initiation = await showInvoiceSheet<PaymentInitiation>(
        context,
        choice: choice,
        notice: notice,
        noticeIsError: noticeIsError,
        onConfirm: () async {
          // Web: open the tab now, while still inside the tap, or the
          // browser blocks it as a popup once the request below returns.
          if (kIsWeb) tab = openPaymentTab();
          try {
            final initiation = await checkout.start(
              counselorProfileID: consultant.id,
              durationMonths: choice.months,
              planType: choice.plan.planType,
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
    return ListView.separated(
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
    );
  }
}

enum _LoadFailure { noAccess, network }

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
  });

  final Consultant consultant;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onSelect;

  // A single shared curve/duration keeps the radius, size and fade in sync so
  // the card feels like one smooth morph rather than three separate tweens.
  static const Duration _animDuration = Duration(milliseconds: 280);
  static const Curve _animCurve = Curves.easeInOutCubic;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _animDuration,
      curve: _animCurve,
      // Clip to the animated rounded corners so the expanding body (buttons and
      // bordered résumé rows) never bleeds past the corners mid-animation.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
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
            duration: _animDuration,
            curve: _animCurve,
            alignment: Alignment.topCenter,
            child: AnimatedOpacity(
              duration: _animDuration,
              curve: _animCurve,
              opacity: expanded ? 1 : 0,
              child: expanded
                  ? _buildExpandedBody()
                  : const SizedBox(width: double.infinity),
            ),
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
