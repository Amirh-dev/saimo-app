import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/authentication/otp_code/index.dart';
import 'package:simo_learn/presentation/screens/authentication/register/widgets/birth_date_picker_bottom_sheet.dart';
import 'package:simo_learn/presentation/screens/authentication/widgets/auth_header.dart';
import 'package:simo_learn/presentation/widgets/re_button.dart';
import 'package:simo_learn/presentation/widgets/re_modal_bottom_sheet.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/presentation/widgets/re_text_field.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/enums.dart';
import 'package:simo_learn/utils/extentions.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late FocusNode _fullNameFocusNode;
  Jalali? _birthDate;
  int? _selectedStudyIndex;
  bool _isStudyMenuExpanded = false;
  final LayerLink _studyLayerLink = LayerLink();
  final GlobalKey _studyHeaderKey = GlobalKey();
  OverlayEntry? _studyOverlayEntry;

  static const List<String> _studyOptions = [
    'زیر ۴ ساعت',
    'بین ۴ تا ۷ ساعت',
    'بیش از ۷ ساعت',
  ];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _fullNameFocusNode = FocusNode()..addListener(_handleFieldFocusChange);
  }

  @override
  void dispose() {
    _removeStudyOverlay();
    _fullNameFocusNode
      ..removeListener(_handleFieldFocusChange)
      ..dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleFieldFocusChange() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openBirthDatePicker() async {
    _closeStudyMenu();
    final selectedDate = await showReModalBottomSheet<Jalali>(
      context: context,
      isScrollControlled: false,
      builder: (_) => BirthDatePickerBottomSheet(
        initialDate: _birthDate ?? Jalali.now(),
      ),
    );

    if (selectedDate == null) return;
    setState(() {
      _birthDate = selectedDate;
    });
  }

  void _removeStudyOverlay() {
    _studyOverlayEntry?.remove();
    _studyOverlayEntry = null;
  }

  void _closeStudyMenu() {
    _removeStudyOverlay();
    if (!mounted || !_isStudyMenuExpanded) return;
    setState(() {
      _isStudyMenuExpanded = false;
    });
  }

  void _toggleStudyMenu() {
    if (_isStudyMenuExpanded) {
      _closeStudyMenu();
      return;
    }

    final currentContext = _studyHeaderKey.currentContext;
    if (currentContext == null) return;
    final renderBox = currentContext.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context);
    if (renderBox == null) return;

    final menuWidth = renderBox.size.width;
    _studyOverlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeStudyMenu,
                child: const SizedBox.expand(),
              ),
              CompositedTransformFollower(
                link: _studyLayerLink,
                showWhenUnlinked: false,
                offset: const Offset(0, 60),
                child: SizedBox(
                  width: menuWidth,
                  child: _buildStudyOptions(),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    overlay.insert(_studyOverlayEntry!);
    if (!mounted) return;
    setState(() {
      _isStudyMenuExpanded = true;
    });
  }

  Widget _buildNameAndDateRow() {
    const double rowHeight = 55;

    return SizedBox(
      height: rowHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 122,
            child: GestureDetector(
              onTap: _openBirthDatePicker,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: AppColors.gray2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 12,
                      color: AppColors.black,
                    ),
                    const Spacer(),
                    ReText(
                      _birthDate == null
                          ? 'تاریخ تولد'
                          : '${_birthDate!.year}/${_birthDate!.month}/${_birthDate!.day}',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _birthDate == null
                          ? AppColors.black
                          : AppColors.black1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: rowHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.gray1,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: _fullNameFocusNode.hasFocus
                      ? AppColors.primary
                      : AppColors.gray1,
                  width: _fullNameFocusNode.hasFocus ? 1.4 : 0,
                ),
                boxShadow: _fullNameFocusNode.hasFocus
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: AppColors.black1.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextFormField(
                  focusNode: _fullNameFocusNode,
                  controller: _fullNameController,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  textAlign: TextAlign.right,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black1,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'نام و نام خانوادگی',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black1.withOpacity(0.45),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return ReTextField(
      controller: _phoneController,
      keyboardType: TextInputType.number,
      maxLength: 10,
      placeholderAlign: TextAlign.right,
      placeholder: 'شماره تماس',
      backgroundColor: AppColors.gray1,
      onChanged: (p0) {
        setState(() {});
      },
      borderRadius: 100,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      suffixIcon: const Padding(
        padding: EdgeInsets.only(left: 15),
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1,
          child: ReText(
            '98+',
            isPersian: true,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.black1,
          ),
        ),
      ),
    );
  }

  Widget _buildStudyHeader() {
    return CompositedTransformTarget(
      link: _studyLayerLink,
      child: GestureDetector(
        onTap: _toggleStudyMenu,
        child: Container(
          key: _studyHeaderKey,
          height: 55,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _isStudyMenuExpanded ? AppColors.gray1 : AppColors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.gray2, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Icon(
                _isStudyMenuExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: AppColors.black1,
              ),
              const Spacer(),
              ReText(
                _selectedStudyIndex == null
                    ? 'میزان مطالعه'
                    : _studyOptions[_selectedStudyIndex!],
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudyOptions() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.gray2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black1.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_studyOptions.length, (index) {
            final isSelected = _selectedStudyIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedStudyIndex = index;
                });
                _closeStudyMenu();
              },
              child: Container(
                height: 62,
                width: double.infinity,
                color: isSelected ? AppColors.gray2 : AppColors.white,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ReText(
                  _studyOptions[index],
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black1,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray1,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        authHeaderWidget(context, authType: AuthMode.register),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Column(
                            children: [
                              _buildNameAndDateRow(),
                              _buildPhoneField().tMargin(4),
                              _buildStudyHeader().tMargin(14),
                              ReButton(
                                onPressed: () {
                                  _closeStudyMenu();
                                  context.to(OTPCodeScreen());
                                },
                                text: 'ثبت نام',
                              ).tMargin(14),
                              ReButton(
                                isOutlined: true,
                                color: AppColors.gray2,
                                textColor: AppColors.black1,
                                background: AppColors.white,
                                onPressed: () {
                                  _closeStudyMenu();
                                  context.to(const RegisterScreen());
                                },
                                text: 'ورود به حساب',
                              ).tMargin(8),
                            ],
                          ).hMargin(16).vMargin(18),
                        ),
                      ],
                    ).tMargin(130),
                    const ReText(
                      'سایمو لرن',
                      color: AppColors.black1,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ).bMargin(10)
                  ],
                ).hMargin(30),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
