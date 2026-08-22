import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../services/supabase_service.dart';
import '../../widgets/marquee_ticker_widget.dart';
import '../../widgets/banner_carousel_widget.dart';

class HomeMainContentView extends StatelessWidget {
  const HomeMainContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF006837).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.storefront_rounded, color: Color(0xFF006837), size: 22),
            ),
            const SizedBox(width: 8),
            const Text(
              'سوق سوريا الشامل 2026',
              style: TextStyle(
                color: Color(0xFF0D1B2A),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF0D1B2A)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF0D1B2A)),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),

              // =====================================================================
              // 1. الشريط الإخباري المتحرك العلوي المضاف (Ticker News Bar - نص فقط)
              // =====================================================================
              StreamBuilder<Map<String, dynamic>?>(
                stream: SupabaseService.instance.getTickerNewsStream(),
                builder: (context, snapshot) {
                  final data = snapshot.data;
                  final text = data?['text']?.toString() ?? '';
                  final speed = (data?['speed'] as int?) ?? 45;
                  final isActive = (data?['is_active'] as bool?) ?? true;

                  return MarqueeTickerWidget(
                    text: text,
                    speed: speed,
                    isActive: isActive,
                  );
                },
              ),

              // =====================================================================
              // 2. سلايدر البانرات الإعلانية المصورة المضاف (Banner Ads Carousel)
              // =====================================================================
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: SupabaseService.instance.getBannerAdsStream(),
                builder: (context, snapshot) {
                  final banners = snapshot.data ?? [];
                  return BannerCarouselWidget(banners: banners);
                },
              ),

              const SizedBox(height: 8),

              // =====================================================================
              // 3. أقسام ومحتويات الصفحة الرئيسية الأصلية
              // =====================================================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'تصفح حسب الأقسام',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D1B2A),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'عرض الكل',
                        style: TextStyle(color: Color(0xFF006837), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              // قائمة الأقسام السريعة
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _buildCategoryItem('سيارات ومركبات', Icons.directions_car_rounded, Colors.blue),
                    _buildCategoryItem('عقارات وأملاك', Icons.apartment_rounded, Colors.amber.shade800),
                    _buildCategoryItem('إلكترونيات وموبايل', Icons.phone_android_rounded, Colors.purple),
                    _buildCategoryItem('وظائف وخدمات', Icons.work_outline_rounded, Colors.teal),
                    _buildCategoryItem('أثاث ومفروشات', Icons.chair_rounded, Colors.brown),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // قسم أحدث الإعلانات
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'أحدث الإعلانات المضافة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D1B2A),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'تصفية',
                        style: TextStyle(color: Color(0xFF006837), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              // قائمة الإعلانات المحدثة
              FutureBuilder<List<Map<String, dynamic>>>(
                future: SupabaseService.instance.searchAds(limit: 10),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(color: Color(0xFF006837)),
                      ),
                    );
                  }

                  final ads = snapshot.data ?? [];
                  if (ads.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Center(
                        child: Text(
                          'لا توجد إعلانات منشورة حالياً',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: ads.length,
                    itemBuilder: (context, index) {
                      final ad = ads[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 1.5,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(
                            ad['title']?.toString() ?? 'إعلان بدون عنوان',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '${ad['province'] ?? 'كل المحافظات'} • ${ad['condition'] ?? 'جديد'}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${ad['price_syp'] ?? 'السعر عند الاتصال'} ل.س',
                                style: const TextStyle(
                                  color: Color(0xFF006837),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                          onTap: () {},
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon, Color color) {
    return Container(
      width: 78,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}