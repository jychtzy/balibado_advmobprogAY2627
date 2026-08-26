import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<User>? _userFuture;
  final UserService _userService = UserService();

  static const Color _brandColor = Color(0xFF313376);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userFuture ??= _userService.getUser();
  }

  void _reload() {
    setState(() {
      _userFuture = _userService.getUser();
    });
  }

  Future<void> _logout() async {
    await _userService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: 'Error loading profile: ${snapshot.error}',
                    fontSize: 14.sp,
                  ),
                  SizedBox(height: 12.h),
                  TextButton(onPressed: _reload, child: const Text('Retry')),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.username.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(text: 'No user data found.', fontSize: 14.sp),
                SizedBox(height: 12.h),
                TextButton(onPressed: _reload, child: const Text('Retry')),
              ],
            ),
          );
        }

        final user = snapshot.data!;

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                ClipOval(
                  child: Image.network(
                    user.image,
                    width: 88.r,
                    height: 88.r,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.person, size: 40.sp, color: _brandColor),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2.h),
                Text(
                  '@${user.username}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? Colors.amber : _brandColor,
                  ),
                ),
                SizedBox(height: 20.h),
                _card(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(context, Icons.badge_outlined, 'Account'),
                      SizedBox(height: 12.h),
                      _infoRow(context, Icons.alternate_email, 'Username', user.username),
                      _divider(context),
                      _infoRow(context, Icons.email_outlined, 'Email', user.email),
                      _divider(context),
                      _infoRow(
                        context,
                        Icons.wc_outlined,
                        'Gender',
                        user.gender.isNotEmpty
                            ? user.gender[0].toUpperCase() + user.gender.substring(1)
                            : '-',
                      ),
                      _divider(context),
                      _infoRow(context, Icons.tag, 'User ID', '#${user.id}'),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: Text(
                      'Log Out',
                      style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(BuildContext context, IconData icon, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerIconColor = isDark ? Colors.amber : _brandColor;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: headerIconColor.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16.sp, color: headerIconColor),
        ),
        SizedBox(width: 8.w),
        CustomText(text: title, fontSize: 15.sp, fontWeight: FontWeight.bold),
      ],
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.sp, color: Colors.amber),
          SizedBox(width: 10.w),
          SizedBox(
            width: 100.w,
            child: CustomText(text: label, fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          Expanded(child: CustomText(text: value, fontSize: 13.sp)),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    final theme = Theme.of(context);
    return Divider(
      height: 1,
      thickness: 1,
      color: theme.dividerColor.withOpacity(0.15),
    );
  }
}