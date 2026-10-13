import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:simo_learn/utils/helpers.dart';
import 'package:simo_learn/utils/username.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    this.phoneNumber,
    this.completeProfileOnly = false,
    this.usernameRepository,
  });

  final String? phoneNumber;
  final bool completeProfileOnly;
  final UsernameRepository? usernameRepository;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late FocusNode _fullNameFocusNode;
  late FocusNode _usernameFocusNode;
  late UsernameRepository _usernameRepository;
  Timer? _usernameAvailabilityDebounce;
  Jalali? _birthDate;
  int? _selectedStudyIndex;
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

  /// Set by the first tap on «ثبت نام»; from then on every missing field
  /// says so under itself.
  bool _showMissingFields = false;

  static const _usernameDebounceDuration = Duration(milliseconds: 650);

  static const List<String> _studyOptions = [
    'زیر ۴ ساعت',
    '۴ تا ۷ ساعت',
    'بیش از ۷ ساعت',
  ];

  /// Usernames are Latin, but a Persian keyboard types Persian digits; they
  /// become English digits as they are typed.
  static final List<TextInputFormatter> _usernameFormatters = [
    TextInputFormatter.withFunction(
      (oldValue, newValue) =>
          newValue.copyWith(text: convertToEnglishNumbers(newValue.text)),
    ),
    LengthLimitingTextInputFormatter(64),
  ];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _usernameController = TextEditingController();
    _fullNameFocusNode = FocusNode()..addListener(_handleFieldFocusChange);
    _usernameFocusNode = FocusNode();
    _usernameRepository = widget.usernameRepository ??
        UsernameRepository(context.read<GraphQLRepository>());
  }

  @override
  void dispose() {
    _usernameAvailabilityDebounce?.cancel();
    _fullNameFocusNode
      ..removeListener(_handleFieldFocusChange)
      ..dispose();
    _usernameFocusNode.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
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
    FocusManager.instance.primaryFocus?.unfocus();
    // Most users are students, so the wheel starts near their birth year
    // rather than at today.
    final now = Jalali.now();
    final selectedDate = await showReModalBottomSheet<Jalali>(
      context: context,
      isScrollControlled: false,
      builder: (_) => BirthDatePickerBottomSheet(
        initialDate: _birthDate ?? Jalali(now.year - 16, 1, 1),
      ),
    );

    if (selectedDate == null) return;
    setState(() {
      _birthDate = selectedDate;
    });
  }

  // ── Field errors, shown once the user has tried to submit ──

  String? get _fullNameMessage {
    final text = _fullNameController.text.trim();
    if (text.isNotEmpty && !_hasValidPersianFullName) {
      return 'نام و نام خانوادگی را به فارسی وارد کنید.';
    }
    if (_showMissingFields && text.isEmpty) {
      return 'نام و نام خانوادگی را وارد کنید.';
    }
    return null;
  }

  bool get _usernameMissing =>
      _showMissingFields &&
      _usernameError == null &&
      _usernameController.text.trim().isEmpty;

  String? get _birthDateMessage => _showMissingFields && _birthDate == null
      ? 'تاریخ تولد را انتخاب کنید.'
      : null;

  String? get _studyMessage =>
      _showMissingFields && _selectedStudyIndex == null
          ? 'میزان مطالعه روزانه را انتخاب کنید.'
          : null;

  // ── Building blocks ──

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 6, bottom: 6),
      child: ReText(
        text,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.gray,
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _note(String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(right: 6, top: 5),
      child: ReText(
        text,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.black1.withValues(alpha: 0.55),
        textAlign: TextAlign.right,
        maxLines: 2,
      ),
    );
  }

  Widget _error(String text) => _note(text, color: AppColors.errorColor);

  Widget _verifiedPhone() {
    final phone = widget.phoneNumber?.trim() ?? '';
    if (phone.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.gray2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_rounded, size: 16, color: AppColors.done),
            const SizedBox(width: 6),
            ReText(
              'شماره تأییدشده: ${convertToPersianNumbers(phone)}',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.black1,
            ),
          ],
        ),
      ),
    ).bMargin(14);
  }

  Widget _buildFullNameField() {
    final hasFocus = _fullNameFocusNode.hasFocus;
    final hasError = _showMissingFields && _fullNameMessage != null;
    final textStyle = TextStyle(
      fontFamily: AppFonts.iranSansVar,
      fontSize: 13,
      height: 1.2,
      fontVariations: AppFonts.fontVariations(FontWeight.w600),
      color: AppColors.black1,
    );
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: hasFocus
              ? AppColors.primary
              : hasError
                  ? AppColors.errorColor
                  : AppColors.gray1,
          width: hasFocus || hasError ? kFocusedFieldBorderWidth : 0,
        ),
        boxShadow: hasFocus ? kFocusedFieldShadow : null,
      ),
      alignment: Alignment.center,
      child: TextFormField(
        key: const ValueKey('register-full-name-field'),
        focusNode: _fullNameFocusNode,
        controller: _fullNameController,
        onChanged: _onFullNameChanged,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) => _usernameFocusNode.requestFocus(),
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        textAlign: TextAlign.right,
        textAlignVertical: TextAlignVertical.center,
        style: textStyle,
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: 'مثلاً علی رضایی',
          hintStyle: textStyle.copyWith(
            color: AppColors.black1.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    final isBusy = _isSuggestingUsername || _isCheckingUsername;
    final isAvailable = _usernameAvailability?.available == true;
    final suggestion = _usernameAvailability?.suggestion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReTextField(
          key: const ValueKey('register-username-field'),
          controller: _usernameController,
          focusNode: _usernameFocusNode,
          placeholder: 'مثلاً ali_rezaei',
          inputTextAlign: TextAlign.left,
          placeholderAlign: TextAlign.right,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          inputFormatters: _usernameFormatters,
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
                      isAvailable
                          ? Icons.check_circle_rounded
                          : Icons.alternate_email_rounded,
                      color: isAvailable ? AppColors.done : AppColors.black1,
                      size: 19,
                    ),
            ),
          ),
        ),
        if (_usernameError != null)
          _error(_usernameError!)
        else if (_usernameMissing)
          _error('نام کاربری را وارد کنید.')
        else if (_isSuggestedUsername)
          _note('بر اساس نام شما پیشنهاد شد و قابل تغییر است.')
        else if (isAvailable)
          _note('این نام کاربری در دسترس است.', color: AppColors.done)
        else
          _note('فقط از حروف انگلیسی، عدد و _ استفاده کنید.'),
        if (suggestion != null)
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _useUsernameSuggestion(suggestion),
              child: ReText(
                'استفاده از @$suggestion',
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                isPersian: false,
              ).hMargin(6).tMargin(4),
            ),
          ),
      ],
    );
  }

  Widget _buildBirthDateField() {
    final hasError = _birthDateMessage != null;
    final date = _birthDate;
    final text = date == null
        ? 'انتخاب کنید'
        : convertToPersianNumbers(
            '${date.day} ${date.formatter.mN} ${date.year}',
          );
    return GestureDetector(
      key: const ValueKey('register-birth-date-field'),
      onTap: _openBirthDatePicker,
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.gray1,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: hasError ? AppColors.errorColor : AppColors.gray1,
            width: hasError ? kFocusedFieldBorderWidth : 0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: ReText(
                text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: date == null
                    ? AppColors.black1.withValues(alpha: 0.45)
                    : AppColors.black1,
                textAlign: TextAlign.right,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.calendar_month_outlined,
              size: 19,
              color: AppColors.black1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyChips() {
    return Row(
      children: [
        for (var index = 0; index < _studyOptions.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              key: ValueKey('register-study-$index'),
              onTap: () => setState(() => _selectedStudyIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedStudyIndex == index
                      ? AppColors.black1
                      : AppColors.gray1,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: ReText(
                  _studyOptions[index],
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _selectedStudyIndex == index
                      ? AppColors.white
                      : AppColors.black1,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ],
      ],
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
            state.action == AuthAction.register) {
          showReToast(context, state.message, ReToastType.failed);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is AuthLoading && state.action == AuthAction.register;
        final fullNameMessage = _fullNameMessage;

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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            authHeaderWidget(
                              context,
                              authType: AuthMode.register,
                              subtitle: 'فقط چند مورد کوتاه تا شروع',
                            ),
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _verifiedPhone(),
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 20, 16, 18),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _label('نام و نام خانوادگی'),
                                        _buildFullNameField(),
                                        if (fullNameMessage != null)
                                          _error(fullNameMessage),
                                        const SizedBox(height: 14),
                                        _label('نام کاربری'),
                                        _buildUsernameField(),
                                        const SizedBox(height: 14),
                                        _label('تاریخ تولد'),
                                        _buildBirthDateField(),
                                        if (_birthDateMessage != null)
                                          _error(_birthDateMessage!),
                                        const SizedBox(height: 14),
                                        _label('میزان مطالعه روزانه'),
                                        _buildStudyChips(),
                                        if (_studyMessage != null)
                                          _error(_studyMessage!),
                                        ReButton(
                                          key: const ValueKey(
                                              'register-submit'),
                                          isLoading: isLoading,
                                          isEnabled: !isLoading,
                                          onPressed: _submitRegistration,
                                          text: 'ثبت نام',
                                        ).tMargin(20),
                                      ],
                                    ),
                                  ),
                                ],
                              ).tMargin(14),
                            ),
                          ],
                        ).tMargin(64),
                        const ReText(
                          'سایمو لرن',
                          color: AppColors.black1,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ).tMargin(16).bMargin(10)
                      ],
                    ).hMargin(24),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool get _isFormComplete {
    return _hasValidPersianFullName &&
        _usernameAvailability?.available == true &&
        _validatedUsername != null &&
        _birthDate != null &&
        _selectedStudyIndex != null;
  }

  void _submitRegistration() {
    // Wait for the username check in flight; its answer decides validity.
    if (_isSuggestingUsername || _isCheckingUsername) return;

    if (!_isFormComplete) {
      setState(() => _showMissingFields = true);
      if (!_hasValidPersianFullName) {
        _fullNameFocusNode.requestFocus();
      } else if (_validatedUsername == null) {
        _usernameFocusNode.requestFocus();
      } else {
        FocusManager.instance.primaryFocus?.unfocus();
      }
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
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

    context.read<AuthCubit>().register(
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
