import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const LoadingWidget({
    super.key,
    this.message,
    this.size,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: padding ?? const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 24,
            height: size ?? 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? theme.primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// Полноэкранный индикатор загрузки
class FullScreenLoadingWidget extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;
  final Color? spinnerColor;

  const FullScreenLoadingWidget({
    super.key,
    this.message,
    this.backgroundColor,
    this.spinnerColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      body: Center(
        child: LoadingWidget(
          message: message,
          size: 48,
          color: spinnerColor,
        ),
      ),
    );
  }
}

// Кнопка с индикатором загрузки
class LoadingButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;
  final Widget? child;
  final Color? color;
  final Color? textColor;
  final double borderRadius;

  const LoadingButton({
    super.key,
    required this.text,
    this.isLoading = false,
    this.onPressed,
    this.child,
    this.color,
    this.textColor,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.primaryColor;
    final buttonTextColor = textColor ?? Colors.white;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: buttonTextColor,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(buttonTextColor),
              ),
            )
          : child ??
              Text(
                text,
                style: TextStyle(
                  color: buttonTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
    );
  }
}

// Индикатор загрузки для карточек
class CardLoadingWidget extends StatelessWidget {
  final double height;
  final double borderRadius;
  final Color? color;

  const CardLoadingWidget({
    super.key,
    this.height = 200,
    this.borderRadius = 8.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// Скелетон для загрузки контента
class SkeletonLoader extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.height,
    this.width = double.infinity,
    this.borderRadius = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// Скелетон для карточки
class CardSkeletonLoader extends StatelessWidget {
  final double height;
  final double borderRadius;

  const CardSkeletonLoader({
    super.key,
    this.height = 120,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLoader(
              height: 20,
              width: 150,
              borderRadius: 4.0,
            ),
            SizedBox(height: 12),
            SkeletonLoader(
              height: 14,
              borderRadius: 4.0,
            ),
            SizedBox(height: 8),
            SkeletonLoader(
              height: 14,
              width: 200,
              borderRadius: 4.0,
            ),
          ],
        ),
      ),
    );
  }
}

// Скелетон для списка
class ListSkeletonLoader extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ListSkeletonLoader({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: SkeletonLoader(height: itemHeight),
        );
      },
    );
  }
}
