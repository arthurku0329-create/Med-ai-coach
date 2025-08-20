import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../repo.dart';
import '../models.dart';
import '../app_router.dart';

/// Page for reviewing flashcards using the SM‑2 algorithm.
class ReviewPage extends ConsumerStatefulWidget {
  const ReviewPage({super.key});

  @override
  ConsumerState<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends ConsumerState<ReviewPage> {
  int _index = 0;
  bool _showBack = false;

  void _gradeCard(CardItem card, int quality) async {
    final repo = ref.read(repoProvider);
    await repo.gradeCard(card, quality);
    ref.invalidate(dueCardsProvider);
    setState(() {
      _showBack = false;
      _index += 1;
    });
    final cards = ref.read(dueCardsProvider).value ?? [];
    if (_index >= cards.length) {
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(dueCardsProvider);
    return HomeScaffold(
      child: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('載入複習卡失敗: $e')),
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(child: Text('今天沒有到期卡片'));  
          }
          if (_index >= cards.length) {
            return const Center(child: Text('複習完成！'));  
          }
          final card = cards[_index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showBack = !_showBack),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _showBack ? card.back : card.front,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: List.generate(
                    6,
                    (q) => ElevatedButton(
                      onPressed: () => _gradeCard(card, q),
                      child: Text('$q'),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}