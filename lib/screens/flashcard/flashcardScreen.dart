import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../appTheme.dart';
import '../../data/kanjiData.dart';
import '../../models/kanjiModel.dart';
import '../../services/streakService.dart';
import '../../widgets/flashcardWidget.dart';
class FlashcardScreen extends ConsumerStatefulWidget {
  final String? level;
  const FlashcardScreen({super.key, this.level});
  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}
class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  final _pageCtrl = PageController(viewportFraction: 0.85);
  final _random = Random();
  List<KanjiModel> _cards = [];
  int _idx = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initCards());
  }
  Future<void> _initCards() async {
    final allKanji = ref.read(kanjiDataProvider).valueOrNull ?? {};
    if (allKanji.isEmpty) return;
    List<KanjiModel> pool;
    if (widget.level != null && allKanji.containsKey(widget.level)) {
      pool = List.from(allKanji[widget.level]!);
    } else {
      pool = allKanji.values.expand((e) => e).toList();
    }
    pool.shuffle(_random);
    setState(() => _cards = pool.take(20).toList());
    await StreakService.recordStudySession();
  }
  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.close_rounded)),
        title: Text('${_idx + 1} / ${_cards.length}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text('Swipe To Navigate • Tap To Flip', style: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.8), fontSize: 13, letterSpacing: 1.2)),
            const Spacer(),
            SizedBox(
              height: 480,
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _idx = i),
                itemCount: _cards.length,
                itemBuilder: (context, i) {
                  final k = _cards[i];
                  return AnimatedBuilder(
                    animation: _pageCtrl,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageCtrl.position.haveDimensions) {
                        value = _pageCtrl.page! - i;
                        value = (1 - (value.abs() * 0.15)).clamp(0.0, 1.0);
                      }
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: FlashcardWidget(
                        frontText: k.character,
                        backMeaning: k.primaryMeaning,
                        backOnReading: k.onReadingsText,
                        backKunReading: k.kunReadingsText,
                      ),
                    ),
                  );
                },
              ),
            ),
            const Spacer(flex: 2),
            if (_idx == _cards.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  label: const Text('Complete Session'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}