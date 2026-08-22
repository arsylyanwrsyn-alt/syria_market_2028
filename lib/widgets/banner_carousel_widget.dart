import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class BannerCarouselWidget extends StatefulWidget {
  final List<Map<String, dynamic>> banners;

  const BannerCarouselWidget({super.key, required this.banners});

  @override
  State<BannerCarouselWidget> createState() => _BannerCarouselWidgetState();
}

class _BannerCarouselWidgetState extends State<BannerCarouselWidget> {
  int _currentSlideIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();
  Timer? _customTimer;

  List<Map<String, dynamic>> get _activeBanners =>
      widget.banners.where((b) => (b['is_active'] as bool? ?? true)).toList();

  @override
  void initState() {
    super.initState();
    _startCustomTimer();
  }

  @override
  void didUpdateWidget(covariant BannerCarouselWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners != widget.banners) {
      _startCustomTimer();
    }
  }

  void _startCustomTimer() {
    _customTimer?.cancel();
    final list = _activeBanners;
    if (list.isEmpty) return;

    final currentBanner = list[_currentSlideIndex % list.length];
    final int durationSec = (currentBanner['duration_seconds'] as int? ?? 5).clamp(2, 60);

    _customTimer = Timer(Duration(seconds: durationSec), () {
      if (!mounted || list.isEmpty) return;
      _carouselController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _customTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = _activeBanners;

    // الشرط: في حال عدم وجود صور، يتم عرض كرت خفيف بكتابة: "منطقة إعلان فارغة"
    if (list.isEmpty) {
      return Container(
        height: 160,
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 40, color: Colors.blueGrey.shade300),
            const SizedBox(height: 8),
            const Text(
              'منطقة إعلان فارغة',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 4),
            Text(
              'يمكنك إضافة وتفعيل البانرات من لوحة التحكم',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          CarouselSlider.builder(
            carouselController: _carouselController,
            itemCount: list.length,
            options: CarouselOptions(
              height: 175,
              viewportFraction: 0.92,
              enlargeCenterPage: true,
              autoPlay: false, // يتم التحكم بالانتقال بدقة عبر المؤقت المخصص لكل بانر
              onPageChanged: (index, reason) {
                setState(() => _currentSlideIndex = index);
                _startCustomTimer();
              },
            ),
            itemBuilder: (context, index, realIndex) {
              final banner = list[index];
              final imageUrl = banner['image_url']?.toString() ?? '';

              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: Icon(Icons.broken_image_rounded, size: 36, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // مؤشر النقاط أسفل السلايدر
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: list.asMap().entries.map((entry) {
              final isSelected = _currentSlideIndex % list.length == entry.key;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 20.0 : 7.0,
                height: 7.0,
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isSelected ? const Color(0xFF006837) : Colors.grey.shade300,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}