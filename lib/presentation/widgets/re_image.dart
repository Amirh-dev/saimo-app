import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simo_learn/utils/assets.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/extentions.dart';
   
class ReImage extends StatelessWidget {
  final String path;
  final double? height;
  final double? width;
  final BoxFit fit;
  final double borderRadius;
  final Alignment alignment;
  final bool enabled;
  final VoidCallback? onTap;
  final Widget? customBottomChild;
  final double? customBottomChildHeight;
  final Color? imageColor;
  final double? imageHeight;
  const ReImage(
    this.path, {
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius = 0,
    this.enabled = false,
    this.onTap,
    this.customBottomChildHeight,
    this.customBottomChild,
    this.imageHeight,
    this.imageColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled
          ? () {
              if (onTap != null) {
                onTap!();
              } else {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  builder: (BuildContext dialogContext) => Material(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 8),
                      ),
                      height: customBottomChildHeight ?? 600,
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(top: 12),
                                width: 37,
                                decoration: BoxDecoration(
                                  color: AppColors.dark1Color,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                height: 5,
                              ),
                              SizedBox(
                                height:
                                    imageHeight ?? context.percentHeight(40),
                                width: imageHeight ?? context.percentHeight(40),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _buildImage(
                                    defaultFit: BoxFit.contain,
                                  ),
                                ),
                              ).center,
                              if (customBottomChild != null)
                                Expanded(child: customBottomChild!),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).sizedBox(height: customBottomChildHeight ?? 500),
                );
              }
            }
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage({BoxFit? defaultFit}) {
    if (path.startsWith('http') || path.startsWith('https')) {
      return Image.network(
        path,
        height: height,
        width: width,
        fit: defaultFit ?? fit,
        color: imageColor,
        alignment: alignment,
        errorBuilder: (input, __, ___) => _buildErrorImage(),
        loadingBuilder: (input, child, proccess) =>
            proccess != null ? _buildLoaderImage() : child,
      );
    } else if (path.startsWith('assets')) {
      return Image.asset(
        color: imageColor,
        path,
        height: height,
        width: width,
        fit: defaultFit ?? fit,
        alignment: alignment,
        errorBuilder: (input, __, ___) => _buildErrorImage(),
      );
    } else if (!kIsWeb && File(path).existsSync()) {
      return Image.file(
        File(path),
        height: height,
        width: width,
        fit: defaultFit ?? fit,
        alignment: alignment,
        errorBuilder: (input, __, ___) => _buildErrorImage(),
      );
    } else if (path.endsWith('svg')) {
      return SvgPicture.asset(
        path,
        height: height,
        width: width,
        alignment: alignment,
        fit: defaultFit ?? fit,
      );
    } else {
      return SvgPicture.asset(
        Assets.emptyImagePlaceholder,
        height: height,
        width: width,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildErrorImage() {
    return SvgPicture.asset(
      Assets.emptyImagePlaceholder,
      height: height,
      width: width,
      fit: BoxFit.cover,
    );
  }

  Widget _buildLoaderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      height: height,
      width: width,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SvgPicture.asset(Assets.neshatRokhLoader, height: 30, width: 30),
          ],
        ),
      ),
    );
  }
}
