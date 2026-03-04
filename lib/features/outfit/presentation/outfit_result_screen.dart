import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'outfit_provider.dart';
import '../../../shared/widgets/app_button.dart';

class OutfitResultScreen extends ConsumerStatefulWidget {
  const OutfitResultScreen({super.key, required this.imagePath});
  final String imagePath;

  @override
  ConsumerState<OutfitResultScreen> createState() => _OutfitResultScreenState();
}

class _OutfitResultScreenState extends ConsumerState<OutfitResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(outfitProvider.notifier).analyze(widget.imagePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(outfitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('분석 결과'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(outfitProvider.notifier).reset();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: state.isLoading
            ? const _LoadingView()
            : state.error != null
                ? _ErrorView(
                    error: state.error!,
                    onRetry: () => ref
                        .read(outfitProvider.notifier)
                        .analyze(widget.imagePath),
                  )
                : state.analysis != null
                    ? _ResultView(
                        imagePath: widget.imagePath,
                        analysis: state.analysis!,
                      )
                    : const SizedBox.shrink(),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('AI가 코디를 분석 중입니다...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('분석 중 오류가 발생했습니다', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          AppButton(label: '다시 시도', onPressed: onRetry),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.imagePath, required this.analysis});
  final String imagePath;
  final dynamic analysis;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 250,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 64, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _ScoreCard(score: analysis.score, style: analysis.style),
          const SizedBox(height: 16),
          _TagsSection(tags: List<String>.from(analysis.tags)),
          const SizedBox(height: 16),
          _RecommendationsSection(
              recommendations: List<String>.from(analysis.recommendations)),
          const SizedBox(height: 24),
          AppButton(
            label: '홈으로 돌아가기',
            icon: Icons.home,
            outlined: true,
            onPressed: () => context.go('/'),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.score, required this.style});
  final int score;
  final String style;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFFE94560)],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Center(
                child: Text(
                  '$score',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('스타일 점수', style: TextStyle(color: Colors.grey)),
                Text(style,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TagsSection extends StatelessWidget {
  const _TagsSection({required this.tags});
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('스타일 태그',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags
              .map((tag) => Chip(
                    label: Text('#$tag'),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection({required this.recommendations});
  final List<String> recommendations;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AI 추천',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...recommendations.map(
          (rec) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome,
                    size: 16, color: Color(0xFFE94560)),
                const SizedBox(width: 8),
                Expanded(child: Text(rec)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
