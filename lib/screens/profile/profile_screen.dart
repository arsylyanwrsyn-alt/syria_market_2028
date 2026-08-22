import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/routes/app_routes.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final email = user?.email ?? 'مستخدم ضيف';

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي الشخصي'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppConfig.primaryColor,
                      child: Icon(Icons.person, size: 36, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'سوق سوريا الشامل',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppConfig.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.list_alt, color: AppConfig.primaryColor),
              title: const Text('إعلاناتي المعروضة'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, color: AppConfig.primaryColor),
              title: const Text('تعديل الملف الشخصي'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline, color: AppConfig.primaryColor),
              title: const Text('مركز المساعدة والدعم'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await AuthService.instance.signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}