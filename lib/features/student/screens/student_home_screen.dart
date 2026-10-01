import 'dart:async';

import 'package:flutter/material.dart';
import 'package:school_mobile/features/student/screens/student_notes_screen.dart';

import '../../../core/services/storage_service.dart';
import '../../auth/screens/login_screen.dart';
import '../models/student_new_counts_model.dart';
import '../models/student_profile_model.dart';
import '../services/student_service.dart';
import 'student_lessons_screen.dart';
import 'student_homeworks_screen.dart';
import 'student_attendance_screen.dart';
import 'student_schedule_screen.dart';
import 'student_grades_screen.dart';
import 'student_result_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final StorageService _storageService = StorageService();
  final StudentService _studentService = StudentService();

  bool _isLoading = true;
  String? _errorMessage;
  StudentProfileModel? _student;

  /*
    عدادات الجديد القادمة من API:
    - دروس جديدة
    - واجبات جديدة
    - حضور جديد
    - جدول جديد
    - ملاحظات جديدة
  */
  StudentNewCountsModel _newCounts = StudentNewCountsModel.empty;

  int _currentIndex = 0;
  Timer? _navInfoTimer;

  @override
  void initState() {
    super.initState();
    _loadStudentProfile();
  }

  @override
  void dispose() {
    _navInfoTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStudentProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final student = await _studentService.getMyProfile();

      /*
        نحاول تحميل العدادات أيضًا.
        إذا فشل تحميل العدادات لا نوقف صفحة الطالب.
      */
      StudentNewCountsModel counts = StudentNewCountsModel.empty;

      try {
        counts = await _studentService.getMyNewCounts();
      } catch (_) {
        counts = StudentNewCountsModel.empty;
      }

      if (!mounted) return;

      setState(() {
        _student = student;
        _newCounts = counts;
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

  Future<void> _loadNewCounts() async {
    /*
      تحميل عدادات الجديد من API.
      إذا فشل الطلب لا نوقف الصفحة، فقط نخلي العدادات 0.
    */
    try {
      final counts = await _studentService.getMyNewCounts();

      if (!mounted) return;

      setState(() {
        _newCounts = counts;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _newCounts = StudentNewCountsModel.empty;
      });
    }
  }

  Future<void> _logout() async {
    await _storageService.clearLoginData();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _onNavTap(int index) async {
    setState(() {
      _currentIndex = index;
    });

    /*
      عند فتح القسم، نصفر عداد هذا القسم.
      المحتوى لا ينحذف، فقط يختفي رقم "جديد".
    */
    String? areaKey;

    if (index == 1) {
      areaKey = 'Lessons';
    } else if (index == 2) {
      areaKey = 'Homeworks';
    } else if (index == 3) {
      areaKey = 'Attendance';
    } else if (index == 4) {
      areaKey = 'Notes';
    }

    if (areaKey == null) return;

    try {
      await _studentService.markAreaAsViewed(areaKey);
      await _loadNewCounts();
    } catch (_) {
      /*
        لا نوقف الصفحة إذا فشل تصفير العداد.
      */
    }
  }

  Future<void> _markScheduleAsViewed() async {
    /*
      الجدول موجود داخل Drawer وليس في الشريط السفلي.
      لذلك نصفر عداده عند فتحه من القائمة الجانبية.
    */
    try {
      await _studentService.markAreaAsViewed('Schedule');
      await _loadNewCounts();
    } catch (_) {
      /*
        لا نوقف الصفحة إذا فشل تصفير عداد الجدول.
      */
    }
  }

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
        return Container(
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
        );
      },
    );
  }

  void _showDrawerPage({
    required IconData icon,
    required String title,
    required String description,
  }) {
    Navigator.pop(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                const SizedBox(height: 24),
                CircleAvatar(
                  radius: 38,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.12),
                  child: Icon(
                    icon,
                    size: 38,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 25,
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
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Text(
                    'هذه الصفحة جاهزة من ناحية التصميم، وسنربطها مع API في الخطوات القادمة.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
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
                  onPressed: _loadStudentProfile,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final student = _student;

    if (student == null) {
      return const Center(child: Text('لا توجد بيانات للطالب.'));
    }

    return RefreshIndicator(
      onRefresh: _loadStudentProfile,
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
                    Icons.school_rounded,
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
                        'مرحبًا بك',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        student.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${student.classRoomName} • ${student.sectionName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
            title: 'رقم الطالب',
            value: student.studentNumber,
          ),

          const SizedBox(height: 12),

          _buildSummaryCard(
            icon: Icons.person_outline,
            title: 'اسم المستخدم',
            value: student.username,
          ),

          const SizedBox(height: 12),

          _buildSummaryCard(
            icon: Icons.school_outlined,
            title: 'الصف',
            value: student.classRoomName,
          ),

          const SizedBox(height: 12),

          _buildSummaryCard(
            icon: Icons.groups_outlined,
            title: 'الشعبة',
            value: student.sectionName,
          ),

          const SizedBox(height: 12),

          _buildSummaryCard(
            icon: Icons.wc_outlined,
            title: 'الجنس',
            value: student.gender,
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('بيانات التواصل'),

          const SizedBox(height: 14),

          _buildSummaryCard(
            icon: Icons.phone_outlined,
            title: 'رقم الهاتف',
            value: student.phoneNumber,
          ),

          const SizedBox(height: 12),

          _buildSummaryCard(
            icon: Icons.family_restroom_outlined,
            title: 'اسم ولي الأمر',
            value: student.parentName,
          ),

          const SizedBox(height: 12),

          _buildSummaryCard(
            icon: Icons.contact_phone_outlined,
            title: 'هاتف ولي الأمر',
            value: student.parentPhone,
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
        final student = _student;

        if (student == null) {
          return const Center(child: Text('تعذر تحميل بيانات الطالب.'));
        }

        return StudentLessonsScreen(student: student);

      case 2:
        final student = _student;

        if (student == null) {
          return const Center(child: Text('تعذر تحميل بيانات الطالب.'));
        }

        return StudentHomeworksScreen(student: student);

      case 3:
        final student = _student;

        if (student == null) {
          return const Center(child: Text('تعذر تحميل بيانات الطالب.'));
        }

        return StudentAttendanceScreen(student: student);

      case 4:
        return const StudentNotesScreen();

      default:
        return _buildHomeTab();
    }
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required String description,
    required int count,
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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade600,
                  ),
                  if (count > 0)
                    Positioned(
                      top: -8,
                      right: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
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
        ),
        child: Row(
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_rounded,
              label: 'الرئيسية',
              description:
                  'تعرض الملف الشخصي وبيانات الطالب الأساسية وبيانات التواصل.',
              count: 0,
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.menu_book_outlined,
              label: 'دروسي',
              description: 'تعرض المواد والدروس المرتبطة بصفك وشعبتك.',
              count: _newCounts.lessonsCount,
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.assignment_outlined,
              label: 'واجباتي',
              description:
                  'تعرض الواجبات الدراسية والمطلوب تسليمه والمواعيد المحددة.',
              count: _newCounts.homeworksCount,
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.calendar_month_outlined,
              label: 'حضوري',
              description: 'تعرض سجل حضورك وغيابك والتأخير إن وجد.',
              count: _newCounts.attendanceCount,
            ),
            _buildNavItem(
              index: 4,
              icon: Icons.note_alt_outlined,
              label: 'ملاحظاتي',
              description:
                  'تعرض الملاحظات والتنبيهات الخاصة بك بشكل واضح ومرتب.',
              count: _newCounts.notesCount,
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
    int count = 0,
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
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.12),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            if (count > 0)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
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
    final student = _student;

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
                              student?.fullName ?? 'طالب',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              student == null
                                  ? 'بوابة الطالب'
                                  : '${student.classRoomName} • ${student.sectionName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
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
                  icon: Icons.table_chart_outlined,
                  title: 'جدولي الدراسي',
                  subtitle: 'عرض الجدول اليومي والأسبوعي للحصص',
                  onTap: () async {
                    Navigator.pop(context);

                    final student = _student;

                    if (student == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تعذر تحميل بيانات الطالب.'),
                        ),
                      );
                      return;
                    }

                    /*
      عند فتح الجدول الدراسي، نصفر عداد الجدول.
      المحتوى لا ينحذف، فقط يختفي رقم الجديد.
    */
                    try {
                      await _studentService.markAreaAsViewed('Schedule');
                      await _loadNewCounts();
                    } catch (_) {
                      /*
        لا نوقف فتح الصفحة إذا فشل تصفير العداد.
      */
                    }

                    if (!mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: Scaffold(
                                appBar: AppBar(
                                  title: const Text('جدولي الدراسي'),
                                  centerTitle: true,
                                ),
                                body: StudentScheduleScreen(student: student),
                              ),
                            ),
                      ),
                    );
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.grade_outlined,
                  title: 'درجاتي',
                  subtitle: 'عرض درجات المواد والمحصّلات',
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: Scaffold(
                                appBar: AppBar(
                                  title: const Text('درجاتي'),
                                  centerTitle: true,
                                ),
                                body: const StudentGradesScreen(),
                              ),
                            ),
                      ),
                    );
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.emoji_events_outlined,
                  title: 'نتيجتي',
                  subtitle: 'عرض نتيجة نصف العام أو نهاية العام',
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => Directionality(
                              textDirection: TextDirection.rtl,
                              child: Scaffold(
                                appBar: AppBar(
                                  title: const Text('نتيجتي'),
                                  centerTitle: true,
                                ),
                                body: const StudentResultScreen(),
                              ),
                            ),
                      ),
                    );
                  },
                ),

                _buildDrawerItem(
                  icon: Icons.account_circle_outlined,
                  title: 'بياناتي',
                  subtitle: 'عرض بيانات الطالب وولي الأمر',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 0;
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
                      'الخروج من حساب الطالب',
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: _buildDrawer(),
        appBar: AppBar(title: const Text('لوحة الطالب'), centerTitle: true),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}
