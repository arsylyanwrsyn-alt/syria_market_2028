import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/config/app_config.dart';
import '../../services/supabase_service.dart';

class AddAdScreen extends StatefulWidget {
  const AddAdScreen({super.key});

  @override
  State<AddAdScreen> createState() => _AddAdScreenState();
}

class _AddAdScreenState extends State<AddAdScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _priceUsdController = TextEditingController();
  final _priceSypController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _sellerNameController = TextEditingController();
  final _telegramController = TextEditingController();

  String _selectedProvinceHeader = 'كل المحافظات';
  String _selectedProvince = 'دمشق';
  String _selectedCityArea = 'المزة';
  String _selectedMainCategory = 'سيارات ومركبات';
  String _selectedSubCategory = 'سيارات سياحية';
  String _selectedCondition = 'مستعمل';

  bool _isLoading = false;
  bool _allowComments = true;
  final List<File> _pickedImages = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _quickTags = [
    'بحالة ممتازة',
    'فحص كامل',
    'قابل للتفاوض',
    'جاهز للتسليم'
  ];
  final Set<String> _selectedTags = {};

  @override
  void dispose() {
    _titleController.dispose();
    _priceUsdController.dispose();
    _priceSypController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _sellerNameController.dispose();
    _telegramController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source, imageQuality: 70);
    if (photo != null) {
      setState(() {
        _pickedImages.add(File(photo.path));
      });
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _submitAd() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = SupabaseService.instance.currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول أولاً لإضافة إعلان')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String finalDescription = _descriptionController.text.trim();
      if (_selectedTags.isNotEmpty) {
        finalDescription += '\n\nالمميزات: ${_selectedTags.join(' | ')}';
      }

      final adData = {
        'user_id': userId,
        'title': _titleController.text.trim(),
        'description': finalDescription,
        'price_usd': double.tryParse(_priceUsdController.text.trim()) ?? 0.0,
        'price_syp': double.tryParse(_priceSypController.text.trim()) ?? 0.0,
        'province': _selectedProvince,
        'area': _selectedCityArea,
        'category_name': _selectedMainCategory,
        'sub_category_name': _selectedSubCategory,
        'condition': _selectedCondition,
        'phone': _phoneController.text.trim(),
        'seller_name': _sellerNameController.text.trim(),
        'telegram_handle': _telegramController.text.trim(),
        'allow_comments': _allowComments,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      };

      final adId = await SupabaseService.instance.createAdRecord(adData);

      for (var imageFile in _pickedImages) {
        await SupabaseService.instance.compressAndUploadImage(
          imageFile,
          adId: adId,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نشر إعلانك بنجاح! ✨')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء نشر الإعلان: $e'),
          backgroundColor: AppConfig.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.backgroundColor,
      appBar: _buildHeader(),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPromoBanner(),
                const SizedBox(height: 16),
                _buildSectionTitle('معلومات الإعلان الرئيسية'),
                const SizedBox(height: 8),
                _buildCustomTextField(
                  controller: _titleController,
                  label: 'ماذا تبيـع؟ *',
                  hint: 'مثال: سيارة كيا سيراتو 2022 بحالة ممتازة',
                  validator: (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildCustomTextField(
                        controller: _priceUsdController,
                        label: 'السعر بالدولار \$',
                        hint: '0',
                        keyboardType: TextInputType.number,
                        suffixText: '\$',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildCustomTextField(
                        controller: _priceSypController,
                        label: 'السعر بالليرة ل.س',
                        hint: '0',
                        keyboardType: TextInputType.number,
                        suffixText: 'ل.س',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildPriceNote(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        label: 'القسم الرئيسي',
                        value: _selectedMainCategory,
                        items: ['سيارات ومركبات', 'عقارات وأملاك', 'موبايلات وتكنولوجيا', 'وظائف وخدمات'],
                        onChanged: (val) => setState(() => _selectedMainCategory = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDropdownField(
                        label: 'القسم الفرعي',
                        value: _selectedSubCategory,
                        items: ['سيارات سياحية', 'شاحنات', 'قطع غيار', 'إكسسوارات'],
                        onChanged: (val) => setState(() => _selectedSubCategory = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        label: 'المحافظة',
                        value: _selectedProvince,
                        items: ['دمشق', 'ريف دمشق', 'حلب', 'حمص', 'اللاذقية', 'طرطوس', 'حماة'],
                        onChanged: (val) => setState(() => _selectedProvince = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDropdownField(
                        label: 'المنطقة / الحي',
                        value: _selectedCityArea,
                        items: ['المزة', 'كفرسوسة', 'الشعلان', 'المالكي', 'الميدان', 'أخرى'],
                        onChanged: (val) => setState(() => _selectedCityArea = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('وصف الإعلان والتفاصيل'),
                const SizedBox(height: 8),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _descriptionController,
                  builder: (context, value, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          maxLength: 600,
                          style: GoogleFonts.cairo(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'وصف الإعلان *',
                            hintText: 'اكتب تفاصيل تساعد المشتري: الحالة، المواصفات، مدة الاستخدام، سبب البيع...',
                            hintStyle: GoogleFonts.cairo(fontSize: 12, color: AppConfig.textSecondaryColor),
                            alignLabelWithHint: true,
                            counterText: '${value.text.length}/600 رمز',
                            counterStyle: GoogleFonts.cairo(fontSize: 11, color: AppConfig.textSecondaryColor),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال وصف الإعلان' : null,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _quickTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return ChoiceChip(
                      label: Text('+ $tag', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600)),
                      selected: isSelected,
                      selectedColor: AppConfig.primaryColor,
                      backgroundColor: AppConfig.primaryLight,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : AppConfig.primaryColor),
                      onSelected: (_) => _toggleTag(tag),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      showCheckmark: false,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('بيانات التواصل وحالة المنتج'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildCustomTextField(
                        controller: _phoneController,
                        label: 'رقم الهاتف *',
                        hint: '09xxxxxxxx',
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildCustomTextField(
                        controller: _sellerNameController,
                        label: 'اسم المعلن',
                        hint: 'اسمك الكريم',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildCustomTextField(
                        controller: _telegramController,
                        label: 'معرف تيليجرام (اختياري)',
                        hint: '@username',
                        prefixIcon: const Icon(Icons.send_rounded, color: Color(0xFF29B6F6), size: 18),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDropdownField(
                        label: 'حالة المنتج',
                        value: _selectedCondition,
                        items: ['جديد (بالكرتونة)', 'مستعمل', 'مجدد', 'بحاجة إصلاح'],
                        onChanged: (val) => setState(() => _selectedCondition = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('صور الإعلان وتفضيلات التفاعل'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildImageUploadButton(
                        icon: Icons.photo_library_outlined,
                        label: 'من المعرض',
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildImageUploadButton(
                        icon: Icons.camera_alt_outlined,
                        label: 'تصوير بالكاميرا',
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                  ],
                ),
                if (_pickedImages.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 70,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _pickedImages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_pickedImages[index], width: 70, height: 70, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: GestureDetector(
                                onTap: () => setState(() => _pickedImages.removeAt(index)),
                                child: Container(
                                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: _allowComments,
                  onChanged: (val) => setState(() => _allowComments = val ?? true),
                  title: Text('السماح بالتعليقات على المنشور', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600)),
                  activeColor: AppConfig.primaryColor,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitAd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'نشر الإعلان الآن ✨',
                          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  'بالنشر أنت توافق على أن تكون المعلومات والصور حقيقية وواضحة',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(fontSize: 11, color: AppConfig.textSecondaryColor),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildHeader() {
    return AppBar(
      backgroundColor: AppConfig.primaryColor,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppConfig.appName, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('المنصة الشاملة الأولى للإعلانات المبوبة', style: GoogleFonts.cairo(fontSize: 10, color: Colors.white70)),
            ],
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedProvinceHeader,
              dropdownColor: AppConfig.primaryColor,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
              style: GoogleFonts.cairo(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
              items: ['كل المحافظات', 'دمشق', 'حلب', 'حمص', 'اللاذقية']
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedProvinceHeader = val!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConfig.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: AppConfig.primaryColor, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('خَلّي إعلانك يلفت الانتباه ✨', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: AppConfig.primaryColor)),
                Text('كلما كان الوصف أدق والصور أوضح، زادت فرص وصول المشتري المناسب إليك.', style: GoogleFonts.cairo(fontSize: 11, color: AppConfig.textPrimaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceNote() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppConfig.accentYellow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, size: 18, color: Colors.black.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '💡 فيك تحط السعر بعملة واحدة أو بالعملتين معاً ليؤصل إعلانك لعدد أكبر من الناس.',
              style: GoogleFonts.cairo(fontSize: 11, color: AppConfig.textPrimaryColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: AppConfig.primaryColor),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
    Widget? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.cairo(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffixText,
        prefixIcon: prefixIcon,
        hintStyle: GoogleFonts.cairo(fontSize: 12, color: AppConfig.textSecondaryColor),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      style: GoogleFonts.cairo(fontSize: 13, color: AppConfig.textPrimaryColor),
      decoration: InputDecoration(labelText: label),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildImageUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppConfig.primaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppConfig.primaryColor, style: BorderStyle.solid, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppConfig.primaryColor, size: 26),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: AppConfig.primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        BottomNavigationBar(
          currentIndex: 2,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppConfig.primaryColor,
          unselectedItemColor: AppConfig.textSecondaryColor,
          selectedLabelStyle: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.cairo(fontSize: 11),
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.bookmark_outline),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                    ),
                  ),
                ],
              ),
              label: 'المفضلة',
            ),
            const BottomNavigationBarItem(icon: SizedBox(width: 24), label: ''),
            const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'حسابي'),
          ],
        ),
        Positioned(
          top: -20,
          child: Column(
            children: [
              FloatingActionButton(
                onPressed: () {},
                backgroundColor: AppConfig.primaryColor,
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, size: 28, color: Colors.white),
              ),
              Text('أضف إعلانك', style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.bold, color: AppConfig.primaryColor)),
            ],
          ),
        ),
      ],
    );
  }
}