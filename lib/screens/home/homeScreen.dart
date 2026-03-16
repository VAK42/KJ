import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../appTheme.dart';
import '../../data/kanjiData.dart';
import '../../widgets/searchBox.dart';
import '../../widgets/shimmerLoader.dart';
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;
  final List<(String, Color)> _levels = [
    ('N5', AppTheme.jlptColors[0]),
    ('N4', AppTheme.jlptColors[1]),
    ('N3', AppTheme.jlptColors[2]),
    ('N2', AppTheme.jlptColors[3]),
    ('N1', AppTheme.jlptColors[4]),
  ];
  @override
  Widget build(BuildContext context) {
    final kanjiAsync = ref.watch(kanjiDataProvider);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (b) => AppTheme.accentGradient.createShader(b),
                          child: const Text('KJ', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
                          onPressed: () => context.push('/home/settings'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('漢字を学ぼう', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                    const SizedBox(height: 48),
                    const Text('JLPT Levels', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: kanjiAsync.when(
                loading: () => const SliverToBoxAdapter(child: ShimmerGrid()),
                error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e', style: const TextStyle(color: AppTheme.error))),
                data: (data) => SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final (level, color) = _levels[i];
                      final count = data[level]?.length ?? 0;
                      return GestureDetector(
                        onTap: () => context.push('/home/kanji/$level'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(level, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color, letterSpacing: 1)),
                              const SizedBox(height: 6),
                              Text('$count Kanji', style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8))),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_circle_filled_rounded, size: 14, color: color.withValues(alpha: 0.7)),
                                  const SizedBox(width: 4),
                                  Text('Study', style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _levels.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.3),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Radicals', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 1.2)),
                    GestureDetector(
                      onTap: () => context.push('/home/radicals'),
                      child: const Text('See All', style: TextStyle(fontSize: 13, color: AppTheme.accentLight)),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 72,
                child: ref.watch(kanjiDataProvider).when(
                  loading: () => const ShimmerLoader(height: 72),
                  error: (_, __) => const SizedBox(),
                  data: (_) => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: ref.watch(radicalListProvider).length,
                    itemBuilder: (_, i) {
                      final r = ref.watch(radicalListProvider)[i];
                      return Container(
                        margin: const EdgeInsets.only(right: 10),
                          width: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(r.character, style: const TextStyle(fontSize: 22, color: AppTheme.textPrimary)),
                              Text(r.meaning, style: const TextStyle(fontSize: 8, color: AppTheme.textMuted), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.border))),
        child: BottomNavigationBar(
          currentIndex: _navIndex,
          onTap: (i) async {
            setState(() => _navIndex = i);
            switch (i) {
              case 1: await context.push('/home/dashboard'); break;
              case 2: await context.push('/home/quiz'); break;
              case 3: await context.push('/home/flashcard'); break;
              default: break;
            }
            if (mounted && i != 0) setState(() => _navIndex = 0);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.quiz_rounded), label: 'Quiz'),
            BottomNavigationBarItem(icon: Icon(Icons.style_rounded), label: 'Flashcard'),
          ],
        ),
      ),
    );
  }
}