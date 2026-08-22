import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/app_config.dart';
import 'auth_service.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  final SupabaseClient _client = Supabase.instance.client;
  SupabaseClient get client => _client;

  bool get isAdmin {
    final email = _client.auth.currentUser?.email;
    return email != null && email.toLowerCase() == kAdminEmail.toLowerCase();
  }

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<String> compressAndUploadImage(File file, {required String adId}) async {
    final compressedFile = await _compressImage(file);
    final fileBytes = await compressedFile.readAsBytes();
    final ext = p.extension(compressedFile.path).replaceAll('.', '');
    final fileName = '$adId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _client.storage.from(AppConfig.adsImagesBucket).uploadBinary(
          fileName,
          fileBytes,
          fileOptions: FileOptions(
            contentType: 'image/$ext',
            upsert: false,
          ),
        );

    final publicUrl = _client.storage.from(AppConfig.adsImagesBucket).getPublicUrl(fileName);
    return publicUrl;
  }

  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      '${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path).isEmpty ? '.jpg' : p.extension(file.path)}',
    );

    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 1280,
      minHeight: 1280,
      format: CompressFormat.jpeg,
    );

    if (result == null) return file;
    return File(result.path);
  }

  Future<void> deleteAdImages(List<String> imageUrls) async {
    final paths = imageUrls.map((url) {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final idx = segments.indexOf(AppConfig.adsImagesBucket);
      return segments.sublist(idx + 1).join('/');
    }).toList();
    if (paths.isEmpty) return;
    await _client.storage.from(AppConfig.adsImagesBucket).remove(paths);
  }

  Future<String> createAdRecord(Map<String, dynamic> data) async {
    final response = await _client.from('ads').insert(data).select('id').single();
    return response['id'] as String;
  }

  Future<Map<String, dynamic>> fetchAdById(String adId) async {
    await _client.rpc('increment_ad_views', params: {'ad_id_input': adId}).catchError((_) {});
    final response = await _client.from('ads').select().eq('id', adId).single();
    return response;
  }

  Future<List<Map<String, dynamic>>> searchAds({
    String? keyword,
    String? province,
    String? categoryId,
    String? condition,
    double? minPrice,
    double? maxPrice,
    int limit = 30,
    int offset = 0,
  }) async {
    var query = _client.from('ads').select().eq('is_active', true);

    if (keyword != null && keyword.trim().isNotEmpty) {
      query = query.ilike('title', '%${keyword.trim()}%');
    }
    if (province != null && province.isNotEmpty) {
      query = query.eq('province', province);
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.eq('category_id', categoryId);
    }
    if (minPrice != null) {
      query = query.gte('price_syp', minPrice);
    }
    if (maxPrice != null) {
      query = query.lte('price_syp', maxPrice);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return List<Map<String, dynamic>>.from(response);
  }

  // =========================================================================
  // الدوال الجديدة المضافة: إدارة الشريط الإخباري والبانرات المصورة (Append Mode)
  // =========================================================================

  // 1. تدفق بيانات الشريط الإخباري المتحرك
  Stream<Map<String, dynamic>?> getTickerNewsStream() {
    return _client
        .from('ticker_news')
        .stream(primaryKey: ['id'])
        .eq('id', 'ticker_primary')
        .map((list) => list.isNotEmpty ? list.first : null);
  }

  // 2. تحديث إعدادات ونصوص الشريط الإخباري
  Future<void> updateTickerNews({
    required String text,
    required int speed,
    required bool isActive,
  }) async {
    await _client.from('ticker_news').upsert({
      'id': 'ticker_primary',
      'text': text,
      'speed': speed,
      'is_active': isActive,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  // 3. تدفق بيانات البانرات الإعلانية المصورة
  Stream<List<Map<String, dynamic>>> getBannerAdsStream() {
    return _client
        .from('banner_ads')
        .stream(primaryKey: ['id'])
        .order('display_order', ascending: true)
        .map((list) => List<Map<String, dynamic>>.from(list));
  }

  // 4. إضافة بانر إعلاني جديد
  Future<void> addBannerAd({
    required String title,
    required String imageUrl,
    required String redirectUrl,
    required int durationSeconds,
    required int displayOrder,
  }) async {
    await _client.from('banner_ads').insert({
      'title': title,
      'image_url': imageUrl,
      'redirect_url': redirectUrl,
      'duration_seconds': durationSeconds,
      'display_order': displayOrder,
      'is_active': true,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  // 5. تعديل حالة تفعيل البانر (تشغيل / إيقاف)
  Future<void> toggleBannerAdStatus(String bannerId, bool currentStatus) async {
    await _client.from('banner_ads').update({'is_active': !currentStatus}).eq('id', bannerId);
  }

  // 6. حذف بانر إعلاني
  Future<void> deleteBannerAd(String bannerId) async {
    await _client.from('banner_ads').delete().eq('id', bannerId);
  }
}