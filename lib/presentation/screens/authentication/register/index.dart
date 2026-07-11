import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/auth/cubit/auth_cubit.dart';
import 'package:simo_learn/features/auth/username_repository.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';
import 'package:simo_learn/presentation/screens/authentication/register/widgets/birth_date_picker_bottom_sheet.dart';
import 'package:simo_learn/presentation/screens/authentication/widgets/auth_header.dart';
import 'package:simo_learn/presentation/widgets/re_button.dart';
import 'package:simo_learn/presentation/widgets/re_modal_bottom_sheet.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/presentation/widgets/re_text_field.dart';
import 'package:simo_learn/presentation/widgets/re_toast.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/enums.dart';
import 'package:simo_learn/utils/extentions.dart';
import 'package:simo_learn/utils/fonts.dart';
import 'package:simo_learn/utils/username.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    this.phoneNumber,
    this.code,
    this.completeProfileOnly = false,
    this.usernameRepository,
  });

  final String? phoneNumber;
  final String? code;
  final bool completeProfileOnly;
  final UsernameRepository? usernameRepository;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late FocusNode _fullNameFocusNode;
  late UsernameRepository _usernameRepository;
  Timer? _usernameAvailabilityDebounce;
  Jalali? _birthDate;
  int? _selectedStudyIndex;
  bool _isStudyMenuExpanded = false;
  final LayerLink _studyLayerLink = LayerLink();
  final GlobalKey _studyHeaderKey = GlobalKey();
  OverlayEntry? _studyOverlayEntry;
  UsernameAvailability? _usernameAvailability;
  String? _validatedUsername;
  String? _usernameError;
  bool _usernameWasManuallyEdited = false;
  bool _isSuggestedUsername = false;
  bool _isSuggestingUsername = false;
  bool _isCheckingUsername = false;
  int _suggestionRequestRevision = 0;
  int _availabilityRequestRevision = 0;
  String? _suggestionFullNameInFlight;
  String? _lastSuggestedFullName;

  static const _usernameDebounceDuration = Duration(milliseconds: 650);

  static const List<String> _studyOptions = [
    'زیر ۴ ساعت',
    'بین ۴ تا ۷ ساعت',
    'بیش از ۷ ساعت',
  ];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _usernameController = TextEditingController();
    _phoneController = TextEditingController(text: widget.phoneNumber);
    _fullNameFocusNode = FocusNode()..addListener(_handleFieldFocusChange);
    _usernameRepository = widget.usernameRepository ??
        UsernameRepository(context.read<GraphQLRepository>());
  }

  @override
  void dispose() {
    _removeStudyOverlay();
    _usernameAvailabilityDebounce?.cancel();
    _fullNameFocusNode
      ..removeListener(_handleFieldFocusChange)
      ..dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleFieldFocusChange() {
    if (!mounted) return;
    setState(() {});
    if (!_fullNameFocusNode.hasFocus) {
      unawaited(_suggestUsernameAfterFullNameBlur());
    }
  }

  bool get _hasValidPersianFullName {
    return isValidPersianFullName(_fullNameController.text);
  }

  void _onFullNameChanged(String value) {
    _suggestionRequestRevision += 1;
    _suggestionFullNameInFlight = null;

    setState(() {
      _isSuggestingUsername = false;
      if (!_usernameWasManuallyEdited) {
        _usernameController.clear();
        _usernameAvailability = null;
        _validatedUsername = null;
        _isSuggestedUsername = false;
        _usernameError = null;
      }
    });
  }

  Future<void> _suggestUsernameAfterFullNameBlur() async {
    final fullName = _fullNameController.text.trim();
    if (!isValidPersianFullName(fullName) || _usernameWasManuallyEdited) {
      return;
    }
    if (_suggestionFullNameInFlight == fullName ||
        (_lastSuggestedFullName == fullName && _isSuggestedUsername)) {
      return;
    }

    final revision = ++_suggestionRequestRevision;
    _suggestionFullNameInFlight = fullName;
    await _suggestUsername(fullName, revision);
  }

  Future<void> _suggestUsername(String fullName, int revision) async {
    if (!mounted || revision != _suggestionRequestRevision) return;
    setState(() {
      _isSuggestingUsername = true;
      _usernameError = null;
    });

    try {
      final suggestion = await _usernameRepository.suggestUsername(fullName);
      if (!mounted || revision != _suggestionRequestRevision) return;
      _setUsernameText(suggestion.username);
      setState(() {
        _suggestionFullNameInFlight = null;
        _lastSuggestedFullName = fullName;
        _isSuggestingUsername = false;
        _usernameAvailability = UsernameAvailability(
          available: suggestion.available,
          normalizedUsername: suggestion.username,
        );
        _validatedUsername = suggestion.available ? suggestion.username : null;
        _isSuggestedUsername = true;
        _usernameError = suggestion.available
            ? null
            : 'نام کاربری پیشنهادی در دسترس نیست؛ یک نام دیگر وارد کنید.';
      });
    } catch (error) {
      if (!mounted || revision != _suggestionRequestRevision) return;
      setState(() {
        _suggestionFullNameInFlight = null;
        _isSuggestingUsername = false;
        _usernameError = _friendlyUsernameError(error);
      });
    }
  }

  void _onUsernameChanged(String value) {
    _usernameAvailabilityDebounce?.cancel();
    _suggestionRequestRevision += 1;
    _suggestionFullNameInFlight = null;
    final revision = ++_availabilityRequestRevision;
    final username = value.trim();
    final hasValidCharacters =
        username.isEmpty || hasValidUsernameCharacters(username);

    setState(() {
      _usernameWasManuallyEdited = true;
      _isSuggestedUsername = false;
      _usernameAvailability = null;
      _validatedUsername = null;
      _isSuggestingUsername = false;
      _usernameError = !hasValidCharacters
          ? 'نام کاربری را فقط با حروف انگلیسی، عدد و _ وارد کنید.'
          : username.isNotEmpty && username.length < 3
              ? 'نام کاربری باید حداقل ۳ کاراکتر باشد.'
              : null;
      _isCheckingUsername = hasValidCharacters && username.length >= 3;
    });

    if (!hasValidCharacters || username.length < 3) return;
    _usernameAvailabilityDebounce = Timer(
      _usernameDebounceDuration,
      () => _checkUsernameAvailability(username, revision),
    );
  }

  Future<void> _checkUsernameAvailability(
    String username,
    int revision,
  ) async {
    if (!mounted || revision != _availabilityRequestRevision) return;
    try {
      final availability =
          await _usernameRepository.checkUsernameAvailability(username);
      if (!mounted || revision != _availabilityRequestRevision) return;
      _setUsernameText(availability.normalizedUsername);
      setState(() {
        _isCheckingUsername = false;
        _usernameAvailability = availability;
        _validatedUsername =
            availability.available ? availability.normalizedUsername : null;
        _usernameError = availability.available
            ? null
            : 'این نام کاربری قبلاً انتخاب شده است.';
      });
    } catch (error) {
      if (!mounted || revision != _availabilityRequestRevision) return;
      setState(() {
        _isCheckingUsername = false;
        _usernameError = _friendlyUsernameError(error);
      });
    }
  }

  void _setUsernameText(String username) {
    _usernameController.value = TextEditingValue(
      text: username,
      selection: TextSelection.collapsed(offset: username.length),
    );
  }

  void _useUsernameSuggestion(String suggestion) {
    _setUsernameText(suggestion);
    _onUsernameChanged(suggestion);
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
                    const SizedBox(width: 4),
                    Expanded(
                      child: ReText(
                        _birthDate == null
                            ? 'تاریخ تولد'
                            : '${_birthDate!.year}/${_birthDate!.month}/${_birthDate!.day}',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _birthDate == null
                            ? AppColors.black
                            : AppColors.black1,
                        maxLines: 1,
                      ),
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
                  key: const ValueKey('register-full-name-field'),
                  focusNode: _fullNameFocusNode,
                  controller: _fullNameController,
                  onChanged: _onFullNameChanged,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  textAlign: TextAlign.right,
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(
                    fontFamily: AppFonts.iranSansVar,
                    fontSize: 13,
                    height: 1.2,
                    fontVariations: AppFonts.fontVariations(FontWeight.w600),
                    color: AppColors.black1,
                  ),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'نام و نام خانوادگی',
                    hintStyle: TextStyle(
                      fontFamily: AppFonts.iranSansVar,
                      fontSize: 13,
                      height: 1.2,
                      fontVariations: AppFonts.fontVariations(FontWeight.w600),
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
      maxLength: 11,
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

  Widget _buildUsernameField() {
    final isBusy = _isSuggestingUsername || _isCheckingUsername;
    return Column(
      children: [
        ReTextField(
          key: const ValueKey('register-username-field'),
          controller: _usernameController,
          placeholder: 'نام کاربری',
          inputTextAlign: TextAlign.left,
          placeholderAlign: TextAlign.right,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          maxLength: 64,
          backgroundColor: AppColors.gray1,
          borderRadius: 100,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          onChanged: _onUsernameChanged,
          suffixIcon: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: 1,
              child: isBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      _usernameAvailability?.available == true
                          ? Icons.check_circle_rounded
                          : Icons.alternate_email_rounded,
                      color: _usernameAvailability?.available == true
                          ? AppColors.done
                          : AppColors.black1,
                      size: 19,
                    ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ReText(
                _usernameError ??
                    (_isSuggestedUsername
                        ? 'نام کاربری پیشنهادی: @$_validatedUsername'
                        : _usernameAvailability?.available == true
                            ? 'این نام کاربری در دسترس است.'
                            : 'فقط از حروف انگلیسی، عدد و _ استفاده کنید.'),
                color: _usernameError != null
                    ? AppColors.errorColor
                    : _usernameAvailability?.available == true
                        ? AppColors.done
                        : AppColors.black1.withOpacity(0.55),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.right,
                maxLines: 2,
              ),
              if (_usernameAvailability?.suggestion != null)
                GestureDetector(
                  onTap: () => _useUsernameSuggestion(
                    _usernameAvailability!.suggestion!,
                  ),
                  child: ReText(
                    '  استفاده از @${_usernameAvailability!.suggestion}',
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.left,
                    isPersian: false,
                  ),
                ),
            ],
          ),
        ).tMargin(5),
      ],
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
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated && state.action == AuthAction.register) {
          showReToast(
            context,
            'ثبت نام با موفقیت انجام شد',
            ReToastType.success,
          );
        } else if (state is AuthFailure &&
            (state.action == AuthAction.register ||
                state.action == AuthAction.sendOtp)) {
          showReToast(context, state.message, ReToastType.failed);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading &&
            (state.action == AuthAction.register ||
                state.action == AuthAction.sendOtp);

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
                            authHeaderWidget(
                              context,
                              authType: AuthMode.register,
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Column(
                                children: [
                                  _buildNameAndDateRow(),
                                  if (_fullNameController.text
                                          .trim()
                                          .isNotEmpty &&
                                      !_hasValidPersianFullName)
                                    const Align(
                                      alignment: Alignment.centerRight,
                                      child: ReText(
                                        'نام و نام خانوادگی را به فارسی وارد کنید.',
                                        color: AppColors.errorColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ).tMargin(5),
                                  _buildUsernameField().tMargin(8),
                                  _buildPhoneField().tMargin(8),
                                  _buildStudyHeader().tMargin(8),
                                  ReButton(
                                    isLoading: isLoading,
                                    isEnabled: _canSubmitRegistration,
                                    onPressed: _submitRegistration,
                                    text: 'ثبت نام',
                                  ).tMargin(16),
                                  ReButton(
                                    isOutlined: true,
                                    color: AppColors.gray2,
                                    textColor: AppColors.black1,
                                    background: AppColors.white,
                                    onPressed: () {
                                      _closeStudyMenu();
                                      context.read<AuthCubit>().logout();
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
      },
    );
  }

  bool get _canSubmitRegistration {
    return _hasValidPersianFullName &&
        _usernameAvailability?.available == true &&
        _validatedUsername != null &&
        !_isSuggestingUsername &&
        !_isCheckingUsername &&
        _normalizeDigits(_phoneController.text).length == 11 &&
        _birthDate != null &&
        _selectedStudyIndex != null;
  }

  void _submitRegistration() {
    _closeStudyMenu();

    final phoneNumber = _normalizeDigits(_phoneController.text);
    final birthDate = _birthDate!.toGregorian();
    final registrationBirthDate = DateTime(
      birthDate.year,
      birthDate.month,
      birthDate.day,
    );
    if (widget.completeProfileOnly) {
      context.read<AuthCubit>().completeRegistrationProfile(
            fullName: _fullNameController.text.trim(),
            username: _validatedUsername!,
            birthDate: registrationBirthDate,
            studyTime: _studyTime,
          );
      return;
    }

    final code = widget.code;
    if (code == null || code.isEmpty) {
      context.read<AuthCubit>().sendRegistrationOtp(
            phoneNumber: phoneNumber,
            fullName: _fullNameController.text.trim(),
            username: _validatedUsername!,
            birthDate: registrationBirthDate,
            studyTime: _studyTime,
          );
      return;
    }

    context.read<AuthCubit>().verifyRegister(
          phoneNumber: phoneNumber,
          code: code,
          fullName: _fullNameController.text.trim(),
          username: _validatedUsername!,
          birthDate: registrationBirthDate,
          studyTime: _studyTime,
        );
  }

  GUserStudyTime get _studyTime {
    return switch (_selectedStudyIndex) {
      0 => GUserStudyTime.UNDER_4_HOURS,
      1 => GUserStudyTime.BETWEEN_4_AND_7,
      2 => GUserStudyTime.OVER_7_HOURS,
      _ => throw StateError('Study time is not selected'),
    };
  }

  String _normalizeDigits(String value) {
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    var result = value;
    for (var i = 0; i < 10; i++) {
      result = result.replaceAll(persian[i], '$i').replaceAll(arabic[i], '$i');
    }
    return result;
  }
}

String _friendlyUsernameError(Object error) {
  final message = error.toString();
  final normalized = message.toLowerCase();
  if (error is ArgumentError || normalized.contains('at least 3')) {
    if (normalized.contains('english letters')) {
      return 'نام کاربری را فقط با حروف انگلیسی، عدد و _ وارد کنید.';
    }
    return 'نام کاربری باید حداقل ۳ کاراکتر باشد.';
  }
  if (normalized.contains('rate_limit') ||
      normalized.contains('too many') ||
      normalized.contains('429')) {
    return 'تعداد درخواست‌ها زیاد شده است؛ لطفاً کمی بعد تلاش کنید.';
  }
  if (normalized.contains('socket') ||
      normalized.contains('network') ||
      normalized.contains('host lookup')) {
    return 'اتصال به سرور برقرار نشد.';
  }
  return 'بررسی نام کاربری ناموفق بود؛ دوباره تلاش کنید.';
}
