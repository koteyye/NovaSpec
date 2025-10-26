import 'package:flutter/material.dart';
import '../../../shared/widgets/modern_button.dart';

class OnboardingContent extends StatefulWidget {
  final VoidCallback onCreateProject;
  final VoidCallback onOpenProject;
  final VoidCallback onCancel;

  const OnboardingContent({
    super.key,
    required this.onCreateProject,
    required this.onOpenProject,
    required this.onCancel,
  });

  @override
  State<OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends State<OnboardingContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start the animation when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: child,
          ),
        );
      },
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient background
            _buildHeader(context),

            // Content section with features
            _buildContent(context),

            // Action buttons
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7C2D12),
            Color(0xFF92400E),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // App icon with animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Welcome text
          const Text(
            'Добро пожаловать в NovaSpec',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Создавайте технические задания с помощью ИИ-ассистента',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildFeatureItem(
            icon: Icons.flash_on_outlined,
            title: 'Быстрое создание',
            description: 'Создавайте ТЗ за минуты, а не часы',
            delay: 0,
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.psychology_outlined,
            title: 'ИИ-ассистент',
            description: 'Умная помощь на каждом этапе',
            delay: 100,
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.integration_instructions_outlined,
            title: 'Интеграции',
            description: 'Работа с популярными системами',
            delay: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF7C2D12).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF7C2D12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Primary action - Create Project
          ModernButton(
            text: 'Создать новый проект',
            onPressed: widget.onCreateProject,
            type: ButtonType.primary,
            fullWidth: true,
            icon: Icons.add_circle_outline,
          ),
          const SizedBox(height: 12),
          // Secondary action - Open Project
          ModernButton(
            text: 'Открыть существующий проект',
            onPressed: widget.onOpenProject,
            type: ButtonType.secondary,
            fullWidth: true,
            icon: Icons.folder_open_outlined,
          ),
          const SizedBox(height: 12),
          // Cancel action
          ModernButton(
            text: 'Отмена',
            onPressed: widget.onCancel,
            type: ButtonType.tertiary,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
