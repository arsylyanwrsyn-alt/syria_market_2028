import 'dart:async';
import 'package:flutter/material.dart';

class MarqueeTickerWidget extends StatefulWidget {
  final String text;
  final int speed; // سرعة الحركة بالبكسل/ثانية
  final bool isActive;
  final VoidCallback? onTap;

  const MarqueeTickerWidget({
    super.key,
    required this.text,
    this.speed = 45,
    this.isActive = true,
    this.onTap,
  });

  static const String defaultEmptyText = 'منطقة إعلان نصي فارغة';

  @override
  State<MarqueeTickerWidget> createState() => _MarqueeTickerWidgetState();
}

class _MarqueeTickerWidgetState extends State<MarqueeTickerWidget> {
  late final ScrollController _scrollController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  @override
  void didUpdateWidget(covariant MarqueeTickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.speed != widget.speed || oldWidget.isActive != widget.isActive) {
      _startScrolling();
    }
  }

  void _startScrolling() {
    _timer?.cancel();
    if (!mounted || widget.text.trim().isEmpty || !widget.isActive) return;

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_scrollController.hasClients) return;
      final maxExtent = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;
      final step = (widget.speed.clamp(15, 120) * 0.05);

      if (current >= maxExtent) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(current + step);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();

    final isBlank = widget.text.trim().isEmpty;
    final displayText = isBlank ? MarqueeTickerWidget.defaultEmptyText : widget.text;

    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF006837).withOpacity(0.35), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // شارة العاجل / التنبيه
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isBlank
                    ? [Colors.blueGrey.shade700, Colors.blueGrey.shade900]
                    : [const Color(0xFF006837), const Color(0xFFD97706)],
              ),
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isBlank ? Icons.info_outline_rounded : Icons.campaign_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  isBlank ? 'تنبيه' : 'عاجل',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // منطقة النص المتحرك أو النص الافتراضي
          Expanded(
            child: isBlank
                ? Center(
                    child: Text(
                      displayText,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: widget.onTap,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Row(
                        children: [
                          Text(
                            displayText,
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 80),
                          Text(
                            displayText,
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}