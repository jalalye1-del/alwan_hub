import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';

import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/theme/app_colors.dart';
import 'package:alwan_hub/core/widgets/alwan_page_header.dart';
import 'package:alwan_hub/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:alwan_hub/features/profile/data/app_rating_repository.dart';
import 'package:alwan_hub/features/profile/presentation/widgets/profile_typography.dart';

class AppRatingScreen extends StatefulWidget {
  const AppRatingScreen({super.key});

  @override
  State<AppRatingScreen> createState() => _AppRatingScreenState();
}

class _AppRatingScreenState extends State<AppRatingScreen> {
  final _repository = AppRatingRepository();
  final _commentController = TextEditingController();

  int _overallRating = 5;
  int _speedRating = 5;
  int _designRating = 5;
  int _contentRating = 5;
  int _streamingRating = 5;
  String? _recommendation;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_onCommentChanged);
    _loadRating();
  }

  @override
  void dispose() {
    _commentController
      ..removeListener(_onCommentChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadRating() async {
    final rating = await _repository.load();
    if (!mounted) return;
    setState(() {
      _overallRating = rating.overallRating;
      _speedRating = rating.speedRating;
      _designRating = rating.designRating;
      _contentRating = rating.contentRating;
      _streamingRating = rating.streamingRating;
      _recommendation = rating.recommendation;
      _commentController.text = rating.comment;
      _loading = false;
    });
  }

  void _onCommentChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ProfileTypography(
      child: Scaffold(
        backgroundColor: dark
            ? const Color(0xFF091A34)
            : const Color(0xFFF7F8FD),
        body: Column(
          children: [
            AlwanPageHeader(
              title: 'تقييم التطبيق',
              subtitle: 'رأيك يصنع تجربة ألوان',
              dark: dark,
              onNotificationTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: ResponsiveContent(
                        maxWidth: 760,
                        child: Column(
                          children: [
                            _OverallRatingCard(
                              rating: _overallRating,
                              dark: dark,
                              onChanged: (rating) =>
                                  setState(() => _overallRating = rating),
                            ),
                            const SizedBox(height: 18),
                            _SectionTitle(
                              title: 'تفاصيل التقييم',
                              englishTitle: 'Detailed Ratings',
                              dark: dark,
                            ),
                            const SizedBox(height: 9),
                            _DetailedRatingCard(
                              emoji: '🚀',
                              title: 'سرعة التطبيق',
                              rating: _speedRating,
                              dark: dark,
                              onChanged: (rating) =>
                                  setState(() => _speedRating = rating),
                            ),
                            const SizedBox(height: 8),
                            _DetailedRatingCard(
                              emoji: '🎨',
                              title: 'تصميم وواجهة المستخدم',
                              rating: _designRating,
                              dark: dark,
                              onChanged: (rating) =>
                                  setState(() => _designRating = rating),
                            ),
                            const SizedBox(height: 8),
                            _DetailedRatingCard(
                              emoji: '📚',
                              title: 'تنوع المحتوى',
                              rating: _contentRating,
                              dark: dark,
                              onChanged: (rating) =>
                                  setState(() => _contentRating = rating),
                            ),
                            const SizedBox(height: 8),
                            _DetailedRatingCard(
                              emoji: '🎙️',
                              title: 'جودة البث',
                              rating: _streamingRating,
                              dark: dark,
                              onChanged: (rating) =>
                                  setState(() => _streamingRating = rating),
                            ),
                            const SizedBox(height: 20),
                            _RecommendationSection(
                              selection: _recommendation,
                              dark: dark,
                              onSelected: (value) =>
                                  setState(() => _recommendation = value),
                            ),
                            const SizedBox(height: 20),
                            _CommentSection(
                              controller: _commentController,
                              dark: dark,
                            ),
                            const SizedBox(height: 12),
                            _PrivacyNote(dark: dark),
                          ],
                        ),
                      ),
                    ),
            ),
            if (!_loading)
              SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 728),
                  child: _SubmitRatingButton(
                    submitting: _submitting,
                    onPressed: _submitRating,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRating() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    await _repository.save(
      AppRatingDraft(
        overallRating: _overallRating,
        speedRating: _speedRating,
        designRating: _designRating,
        contentRating: _contentRating,
        streamingRating: _streamingRating,
        recommendation: _recommendation,
        comment: _commentController.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => ProfileTypography(
        child: AlertDialog(
          icon: Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF303A92), Color(0xFFA321AF)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          title: const Text('شكرًا لمشاركتنا رأيك'),
          content: const Text(
            'تم حفظ تقييمك بنجاح، وسيساعدنا في تطوير تجربة منصة ألوان.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('تم'),
            ),
          ],
        ),
      ),
    );

    if (!mounted) return;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) navigator.pop(true);
  }
}

class _OverallRatingCard extends StatelessWidget {
  const _OverallRatingCard({
    required this.rating,
    required this.dark,
    required this.onChanged,
  });

  final int rating;
  final bool dark;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: dark
              ? const [Color(0xFF152E53), Color(0xFF102442)]
              : const [Color(0xFFFFFFFF), Color(0xFFF4F3FF)],
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: dark ? const Color(0xFF29486E) : const Color(0xFFD9DEEB),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120D1B38),
            blurRadius: 13,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF1C3A62) : const Color(0xFFF0F2F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: dark ? const Color(0xFF31527C) : const Color(0xFFD9DFE9),
              ),
            ),
            child: const Text(
              '✨ تقييمك يعني لنا الكثير',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 11),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StarSelector(
                  rating: rating,
                  onChanged: onChanged,
                  iconSize: 26,
                  spacing: 1,
                ),
                const SizedBox(width: 12),
                Text(
                  '$rating.0',
                  style: TextStyle(
                    color: dark ? Colors.white : const Color(0xFF302D84),
                    fontFamily: 'MohammadBoldArt',
                    fontSize: 37,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'من 5',
                    style: TextStyle(
                      color: dark ? Colors.white60 : AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _ratingMessage(rating),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: dark ? Colors.white70 : const Color(0xFF5C6682),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _ratingMessage(int value) {
    return switch (value) {
      5 => '🇾🇪 ممتاز! تقييمك يمنح فريق ألوان دفعة جميلة',
      4 => 'رائع! شكرًا لتقديرك وسنواصل التطوير',
      3 => 'تجربة جيدة، وملاحظتك ستجعلها أفضل',
      2 => 'نقدّر صراحتك وسنعمل على تحسين التجربة',
      _ => 'نأسف لعدم رضاك؛ أخبرنا كيف نصنع تجربة أفضل',
    };
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.englishTitle,
    required this.dark,
  });

  final String title;
  final String englishTitle;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: dark ? Colors.white : const Color(0xFF292F70),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            englishTitle,
            style: TextStyle(
              color: dark ? Colors.white54 : AppColors.textSecondary,
              fontFamily: 'MohammadBoldArt',
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailedRatingCard extends StatelessWidget {
  const _DetailedRatingCard({
    required this.emoji,
    required this.title,
    required this.rating,
    required this.dark,
    required this.onChanged,
  });

  final String emoji;
  final String title;
  final int rating;
  final bool dark;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF10294D) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: dark ? const Color(0xFF28466C) : const Color(0xFFDDE2EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF19385F) : const Color(0xFFF1F4F9),
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 17)),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: dark ? Colors.white : const Color(0xFF283168),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Directionality(
            textDirection: TextDirection.ltr,
            child: _StarSelector(
              rating: rating,
              onChanged: onChanged,
              iconSize: 22,
              spacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _StarSelector extends StatelessWidget {
  const _StarSelector({
    required this.rating,
    required this.onChanged,
    required this.iconSize,
    required this.spacing,
  });

  final int rating;
  final ValueChanged<int> onChanged;
  final double iconSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'التقييم $rating من 5 نجوم',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 1; index <= 5; index++)
            InkResponse(
              onTap: () => onChanged(index),
              radius: iconSize,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing),
                child: Icon(
                  index <= rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: index <= rating
                      ? const Color(0xFFFFB000)
                      : const Color(0xFFBAC3D0),
                  size: iconSize,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  const _RecommendationSection({
    required this.selection,
    required this.dark,
    required this.onSelected,
  });

  final String? selection;
  final bool dark;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const options = <(String, String)>[
      ('نعم', '👍'),
      ('إلى حد ما', '😐'),
      ('لا', '👎'),
    ];
    return Column(
      children: [
        Text(
          'هل توصي بتطبيق ألوان لراديو؟',
          style: TextStyle(
            color: dark ? Colors.white : const Color(0xFF292F70),
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var index = 0; index < options.length; index++) ...[
              Expanded(
                child: _RecommendationChoice(
                  label: options[index].$1,
                  emoji: options[index].$2,
                  selected: selection == options[index].$1,
                  dark: dark,
                  onTap: () => onSelected(options[index].$1),
                ),
              ),
              if (index != options.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }
}

class _RecommendationChoice extends StatelessWidget {
  const _RecommendationChoice({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.dark,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool selected;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 52,
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFF8F1FF)
                : dark
                ? const Color(0xFF10294D)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF8732A6)
                  : dark
                  ? const Color(0xFF28466C)
                  : const Color(0xFFD9E0E9),
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF5E2C88)
                      : dark
                      ? Colors.white70
                      : const Color(0xFF4E5A75),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentSection extends StatelessWidget {
  const _CommentSection({required this.controller, required this.dark});

  final TextEditingController controller;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اكتب رأيك',
          style: TextStyle(
            color: dark ? Colors.white : const Color(0xFF292F70),
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLength: 500,
          minLines: 4,
          maxLines: 6,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: context.translateInterface(
              'شاركنا رأيك واقتراحاتك لتحسين التطبيق...',
            ),
            hintStyle: TextStyle(
              color: dark ? Colors.white38 : const Color(0xFF9AA6B7),
              fontSize: 11,
            ),
            filled: true,
            fillColor: dark ? const Color(0xFF10294D) : Colors.white,
            counterText: '${controller.text.length}/500',
            counterStyle: TextStyle(
              color: dark ? Colors.white54 : AppColors.textSecondary,
              fontFamily: 'MohammadBoldArt',
              fontSize: 9,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(
                color: dark ? const Color(0xFF28466C) : const Color(0xFFD9E0E9),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(
                color: dark ? const Color(0xFF28466C) : const Color(0xFFD9E0E9),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: Color(0xFF8732A6),
                width: 1.8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline_rounded,
          size: 14,
          color: dark ? Colors.white54 : const Color(0xFF78849B),
        ),
        const SizedBox(width: 5),
        Text(
          'يُستخدم تقييمك لتحسين التطبيق فقط',
          style: TextStyle(
            color: dark ? Colors.white54 : AppColors.textSecondary,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

class _SubmitRatingButton extends StatelessWidget {
  const _SubmitRatingButton({
    required this.submitting,
    required this.onPressed,
  });

  final bool submitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF31368B), Color(0xFF9B20B2)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3D5E238C),
              blurRadius: 14,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: submitting ? null : onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.send_rounded),
          label: Text(
            submitting ? 'جارٍ الإرسال...' : 'إرسال التقييم',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
