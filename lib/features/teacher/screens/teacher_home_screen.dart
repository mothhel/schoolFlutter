import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/storage_service.dart';
import '../../auth/screens/login_screen.dart';
import '../models/teacher_profile_model.dart';
import '../services/teacher_service.dart';
import 'teacher_homeworks_screen.dart';
import 'teacher_schedule_screen.dart';
import 'teacher_lessons_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final StorageService _storageService = StorageService();
  final TeacherService _teacherService = TeacherService();

  bool _isLoading = true;
  String? _errorMessage;

  TeacherProfileModel? _teacher;

  int _currentIndex = 0;
  Timer? _navInfoTimer;

  @override
  void initState() {
    super.initState();
    _loadTeacherProfile();
  }

  @override
  void dispose() {
    _navInfoTimer?.cancel();
    super.dispose();
  }

  /*
    =====================================================
    تحميل بيانات الأستاذ
    =====================================================

    نجلب بيانات الأستاذ الحالي من API حسب التوكن.
  */
  Future<void> _loadTeacherProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final teacher = await _teacherService.getMyProfile();

      if (!mounted) return;

      setState(() {
        _teacher = teacher;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  /*
    =====================================================
    تسجيل الخروج
    =====================================================

    نحذف بيانات الدخول ثم نرجع إلى شاشة تسجيل الدخول.
  */
  Future<void> _logout() async {
    await _storageService.clearLoginData();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  /*
    عند الضغط على أيقونة من الشريط السفلي نغير الصفحة الحالية.
  */
  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /*
    عند الضغط المطوّل على أيقونة من الشريط السفلي
    نعرض شرح الصفحة بعد مدة قصيرة.
  */
  void _startNavInfoTimer({
    required String title,
    required String description,
  }) {
    _navInfoTimer?.cancel();

    _navInfoTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      _showNavInfoSheet(title: title, description: description);
    });
  }

  void _cancelNavInfoTimer() {
    _navInfoTimer?.cancel();
  }

  void _showNavInfoSheet({required String title, required String description}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.12),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value.isEmpty ? 'غير متوفر' : value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
    );
  }

  Widget _buildHomeTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 56, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadTeacherProfile,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final teacher = _teacher;

    if (teacher == null) {
      return const Center(child: Text('لا توجد بيانات للأستاذ.'));
    }

    return RefreshIndicator(
      onRefresh: _loadTeacherProfile,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.78),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white.withOpacity(0.18),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'مرحبًا أستاذ',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        teacher.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'أستاذ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('البيانات الأساسية'),

          const SizedBox(height: 14),

          _buildSummaryCard(
            icon: Icons.badge_outlined,
            title: 'رقم الأستاذ',
            value: teacher.teacherNumber,
          ),

          const SizedBox(height: 12),

          _buildSummaryCard(
            icon: Icons.person_outline,
            title: 'اسم المستخدم',
            value: teacher.username,
          ),

          const SizedBox(height: 12),

          _buildSummaryCard(
            icon: Icons.phone_outlined,
            title: 'رقم الهاتف',
            value: teacher.phoneNumber,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.12),
                child: Icon(
                  icon,
                  size: 34,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'سنربط صفحة $title مع API في الخطوات القادمة.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('متابعة لاحقًا'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();

      case 1:
        return const TeacherScheduleScreen();

      case 2:
        return const TeacherLessonsScreen();

      case 3:
        return const TeacherHomeworksScreen();

      default:
        return _buildHomeTab();
    }
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required String description,
  }) {
    final bool isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _onNavTap(index);
        },
        onLongPressStart: (_) {
          _startNavInfoTimer(title: label, description: description);
        },
        onLongPressEnd: (_) {
          _cancelNavInfoTimer();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color:
                    isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade600,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 10),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_rounded,
              label: 'الرئيسية',
              description:
                  'تعرض الملف الشخصي وبيانات الأستاذ الأساسية وبيانات التواصل.',
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.table_chart_outlined,
              label: 'جدولي',
              description: 'تعرض جدول الحصص المرتبط بتكليفات الأستاذ.',
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.menu_book_outlined,
              label: 'دروسي',
              description: 'تعرض دروس الأستاذ حسب التكليفات المرتبطة به.',
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.assignment_outlined,
              label: 'واجباتي',
              description: 'تعرض واجبات الأستاذ المرتبطة بتكليفاته.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.12),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12.5, color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
      ),
    );
  }

  Widget _buildDrawer() {
    final teacher = _teacher;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.78),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withOpacity(0.18),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teacher?.fullName ?? 'أستاذ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'بوابة الأستاذ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                _buildDrawerItem(
                  icon: Icons.home_rounded,
                  title: 'الرئيسية',
                  subtitle: 'عرض بيانات الأستاذ الأساسية',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.table_chart_outlined,
                  title: 'جدولي الدراسي',
                  subtitle: 'عرض الجدول اليومي والأسبوعي للحصص',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.menu_book_outlined,
                  title: 'دروسي',
                  subtitle: 'عرض الدروس المرتبطة بالأستاذ',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 2;
                    });
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.assignment_outlined,
                  title: 'واجباتي',
                  subtitle: 'عرض الواجبات المرتبطة بالأستاذ',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 3;
                    });
                  },
                ),

                const Spacer(),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    onTap: _logout,
                    leading: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.logout, color: Colors.white),
                    ),
                    title: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: const Text(
                      'الخروج من حساب الأستاذ',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _appBarTitle() {
    if (_currentIndex == 0) {
      return 'لوحة الأستاذ';
    }

    if (_currentIndex == 1) {
      return 'جدولي الدراسي';
    }

    if (_currentIndex == 2) {
      return 'دروسي';
    }

    if (_currentIndex == 3) {
      return 'واجباتي';
    }

    return 'لوحة الأستاذ';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: _buildDrawer(),
        appBar: AppBar(title: Text(_appBarTitle()), centerTitle: true),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}
