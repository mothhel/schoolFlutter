import 'package:flutter/material.dart';

import '../models/teacher_lesson_model.dart';
import '../services/teacher_service.dart';
import 'teacher_add_lesson_screen.dart';

class TeacherLessonsScreen extends StatefulWidget {
  const TeacherLessonsScreen({super.key});

  @override
  State<TeacherLessonsScreen> createState() => _TeacherLessonsScreenState();
}

class _TeacherLessonsScreenState extends State<TeacherLessonsScreen> {
  final TeacherService _teacherService = TeacherService();

  bool _isLoading = true;
  String? _errorMessage;

  List<TeacherLessonModel> _lessons = [];
  List<TeacherLessonModel> _filteredLessons = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /*
    تحميل دروس الأستاذ من API.
  */
  Future<void> _loadLessons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final lessons = await _teacherService.getMyLessons();

      if (!mounted) return;

      setState(() {
        _lessons = lessons;
        _filteredLessons = lessons;
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
    البحث داخل الدروس.
  */
  void _searchLessons(String value) {
    final query = value.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredLessons = _lessons;
      });
      return;
    }

    setState(() {
      _filteredLessons =
          _lessons.where((lesson) {
            final text =
                '${lesson.title} '
                        '${lesson.description} '
                        '${lesson.subjectName} '
                        '${lesson.classRoomName} '
                        '${lesson.sectionName} '
                        '${_formatDate(lesson.lessonDate)} '
                        '${lesson.createdDayName} '
                        '${lesson.createdTime} '
                        '${lesson.updatedDayName} '
                        '${lesson.updatedTime}'
                    .toLowerCase();

            return text.contains(query);
          }).toList();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _dayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.saturday:
        return 'السبت';
      case DateTime.sunday:
        return 'الأحد';
      case DateTime.monday:
        return 'الاثنين';
      case DateTime.tuesday:
        return 'الثلاثاء';
      case DateTime.wednesday:
        return 'الأربعاء';
      case DateTime.thursday:
        return 'الخميس';
      case DateTime.friday:
        return 'الجمعة';
      default:
        return '';
    }
  }

  String _formatTime(DateTime date) {
    final period = date.hour >= 12 ? 'مساءً' : 'صباحًا';

    int hour = date.hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    final minute = date.minute.toString().padLeft(2, '0');

    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  /*
    فتح صفحة إضافة درس جديد.
  */
  Future<void> _openAddLessonScreen() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TeacherAddLessonScreen()),
    );

    if (added == true) {
      await _loadLessons();
    }
  }

  /*
    فتح نفس صفحة إضافة الدرس، لكن في وضع التعديل.
  */
  Future<void> _openEditLessonScreen(TeacherLessonModel lesson) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TeacherAddLessonScreen(lesson: lesson)),
    );

    if (updated == true) {
      await _loadLessons();
    }
  }

  /*
    تأكيد حذف الدرس قبل الحذف.
  */
  Future<void> _confirmDeleteLesson(TeacherLessonModel lesson) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: Text('هل أنتِ متأكدة من حذف الدرس:\n${lesson.title}؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('حذف', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _teacherService.deleteLesson(lessonId: lesson.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف الدرس بنجاح.'),
          backgroundColor: Colors.green,
        ),
      );

      await _loadLessons();
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceAll('Exception:', '').trim();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildHeaderCard() {
    return Container(
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
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 33,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.menu_book_outlined,
              color: Colors.white,
              size: 34,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'دروسي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'هنا تظهر دروسك ويمكنك إضافة درس جديد للطلاب.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.grey.shade700),
          const SizedBox(width: 5),
          Text(
            text.isEmpty ? 'غير متوفر' : text,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(TeacherLessonModel lesson) {
    final createdAt = lesson.createdAt;

    final createdDayName =
        lesson.createdDayName.isNotEmpty
            ? lesson.createdDayName
            : createdAt == null
            ? ''
            : _dayName(createdAt);

    final createdTime =
        lesson.createdTime.isNotEmpty
            ? lesson.createdTime
            : createdAt == null
            ? ''
            : _formatTime(createdAt);

    final updatedAt = lesson.updatedAt;

    final updatedDayName =
        lesson.updatedDayName.isNotEmpty
            ? lesson.updatedDayName
            : updatedAt == null
            ? ''
            : _dayName(updatedAt);

    final updatedTime =
        lesson.updatedTime.isNotEmpty
            ? lesson.updatedTime
            : updatedAt == null
            ? ''
            : _formatTime(updatedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.12),
                child: Icon(
                  Icons.menu_book_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  lesson.title.isEmpty ? 'درس بدون عنوان' : lesson.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          if (lesson.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              lesson.description,
              style: const TextStyle(
                color: Colors.grey,
                height: 1.7,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(icon: Icons.book_outlined, text: lesson.subjectName),
              _buildBadge(
                icon: Icons.school_outlined,
                text: lesson.classRoomName,
              ),
              _buildBadge(
                icon: Icons.groups_outlined,
                text: lesson.sectionName,
              ),
              _buildBadge(
                icon: Icons.calendar_today_outlined,
                text:
                    '${_dayName(lesson.lessonDate)} - ${_formatDate(lesson.lessonDate)}',
              ),
            ],
          ),

          if (createdAt != null ||
              createdDayName.isNotEmpty ||
              createdTime.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildBadge(
                    icon: Icons.add_circle_outline,
                    text:
                        createdAt == null
                            ? 'وقت الإضافة غير متوفر'
                            : 'أضيف: $createdDayName - ${_formatDate(createdAt)}',
                  ),
                  if (createdTime.isNotEmpty)
                    _buildBadge(icon: Icons.access_time, text: createdTime),
                ],
              ),
            ),
          ],

          if (updatedAt != null ||
              updatedDayName.isNotEmpty ||
              updatedTime.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.orange.withOpacity(0.18)),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildBadge(
                    icon: Icons.edit_calendar_outlined,
                    text:
                        updatedAt == null
                            ? 'تم تعديل الدرس'
                            : 'آخر تعديل: $updatedDayName - ${_formatDate(updatedAt)}',
                  ),
                  if (updatedTime.isNotEmpty)
                    _buildBadge(icon: Icons.access_time, text: updatedTime),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openEditLessonScreen(lesson),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('تعديل'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDeleteLesson(lesson),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('حذف'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _searchLessons,
      decoration: InputDecoration(
        labelText: 'بحث في الدروس',
        hintText: 'ابحث بالعنوان، المادة، الصف، الشعبة، التاريخ...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            _searchController.text.trim().isEmpty
                ? null
                : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _searchLessons('');
                  },
                  icon: const Icon(Icons.close),
                ),
      ),
    );
  }

  Widget _buildBody() {
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
                  onPressed: _loadLessons,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLessons,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _buildHeaderCard(),

          const SizedBox(height: 18),

          _buildSearchField(),

          const SizedBox(height: 18),

          if (_filteredLessons.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'لا توجد دروس مرتبطة بك حتى الآن.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          else
            ..._filteredLessons.map(_buildLessonCard),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddLessonScreen,
        icon: const Icon(Icons.add),
        label: const Text(
          'إضافة درس',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
