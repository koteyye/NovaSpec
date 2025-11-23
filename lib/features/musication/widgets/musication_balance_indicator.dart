import 'package:flutter/material.dart';
import '../services/musication_service.dart';
import '../../../shared/services/di_container.dart';

class MusicationBalanceIndicator extends StatefulWidget {
  const MusicationBalanceIndicator({super.key});

  @override
  State<MusicationBalanceIndicator> createState() =>
      _MusicationBalanceIndicatorState();
}

class _MusicationBalanceIndicatorState
    extends State<MusicationBalanceIndicator> {
  int? _balance;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = getIt<MusicationService>();

      // Сначала пробуем получить кэшированный баланс
      final cachedBalance = service.getCachedBalance();
      if (cachedBalance != null) {
        setState(() {
          _balance = cachedBalance;
          _isLoading = false;
        });
      }

      // Обновляем баланс в фоне
      await service.refreshMusicBalance();
      final freshBalance = await service.getMusicBalance();

      if (mounted) {
        setState(() {
          _balance = freshBalance;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            ),
            SizedBox(width: 6),
            Text('...', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    if (_error != null) {
      // При ошибке просто не показываем индикатор
      return const SizedBox.shrink();
    }

    final balance = _balance ?? 0;
    final balanceColor = balance > 0 ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: balanceColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_note, size: 16, color: balanceColor),
          const SizedBox(width: 6),
          Text(
            '$balance ₽',
            style: TextStyle(
              color: balanceColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
