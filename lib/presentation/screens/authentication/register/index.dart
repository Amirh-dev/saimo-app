import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/screens/authentication/otp_code/index.dart';
import 'package:simo_learn/presentation/screens/authentication/widgets/auth_header.dart';
import 'package:simo_learn/presentation/widgets/re_button.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/enums.dart';
import 'package:simo_learn/utils/extentions.dart';
import 'package:solar_icons/solar_icons.dart';

import '../../../widgets/re_date_picker.dart';
import '../../../widgets/re_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
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
                              borderRadius: BorderRadius.circular(40)),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: ReTextField(
                                      backgroundColor: AppColors.gray1,
                                      placeholder: 'نام خانوادگی',
                                      controller: _firstNameController,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: ReTextField(
                                      backgroundColor: AppColors.gray1,
                                      placeholder: 'نام',
                                      controller: _lastNameController,
                                    ),
                                  )
                                ],
                              ),
                              ReTextField(
                                backgroundColor: AppColors.gray1,
                                placeholder: 'شماره تماس',
                                maxLength: 11,
                                keyboardType: TextInputType.number,
                                placeholderAlign: TextAlign.right,
                                textInputAction: TextInputAction.done,
                                controller: _phoneController,
                                suffixIcon: Container(
                                    margin: const EdgeInsets.only(
                                        top: 15, left: 15),
                                    child: const ReText(
                                      '98+',
                                      color: AppColors.black1,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ).tMargin(16),
                              Container(
                                margin: const EdgeInsets.only(top: 16),
                                width: double.infinity,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.gray2),
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      SolarIconsOutline.arrowDown,
                                      size: 18,
                                    ),
                                    ReText(
                                      'انتخاب رشته، شغل و ...',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ).hMargin(16),
                              ),
                              ReDatePicker(
                                onDateChanged: (date) {
                                  // Handle date selection
                                  debugPrint(
                                      'Selected date: ${date?.toString()}');
                                },
                              ).tMargin(16),
                              ReButton(
                                onPressed: () {
                                  context.to(OTPCodeScreen());
                                },
                                text: 'ورود',
                              ).tMargin(24),
                              ReButton(
                                isOutlined: true,
                                color: AppColors.gray2,
                                textColor: AppColors.black1,
                                background: AppColors.white,
                                onPressed: () {
                                  context.to(const RegisterScreen());
                                },
                                text: 'ثبت نام',
                              ).tMargin(8),
                            ],
                          ).hMargin(16).vMargin(18),
                        ),
                      ],
                    ).tMargin(130),
                    const ReText(
                      'سایمو لرن',
                      color: AppColors.black1,
                      fontSize: 13,
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
