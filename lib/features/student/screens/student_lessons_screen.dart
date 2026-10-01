import 'package:flutter/material.dart';

import '../models/student_lesson_model.dart';
import '../models/student_profile_model.dart';
import '../services/student_service.dart';

class StudentLessonsScreen extends StatefulWidget {
  final StudentProfileModel student;

  const StudentLessonsScreen({super.key, required this.student});

  @override
  State<StudentLessonsScreen> createState() => _StudentLessonsScreenState();
}

class _StudentLessonsScreenState extends State<StudentLessonsScreen> {
  final StudentService _studentService = StudentService();

  bool _isLoading = true;
  String? _errorMessage;

  List<StudentLessonModel> _lessons = [];
  List<StudentLessonModel> _filteredLessons = [];

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
    =====================================================
    ترتيب الدروس
    =====================================================

    المطلوب:
    - أول درس تم إضافته يظهر في البداية
    - آخر درس تم إضافته يظهر في الأخير

    لذلك نرتب تصاعديًا حسب createdAt.
  */
  void _sortLessonsOldestFirst(List<StudentLessonModel> lessons) {
    lessons.sort((a, b) {
      return a.createdAt.compareTo(b.createdAt);
    });
  }

  /*
    =====================================================
    تحميل دروس الطالب
    =====================================================

    نرسل صف وشعبة الطالب حتى يتم عرض الدروس المطابقة فقط.
  */
  Future<void> _loadLessons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final lessons = await _studentService.getMyLessons(
        classRoomName: widget.student.classRoomName,
        sectionName: widget.student.sectionName,
      );

      /*
        نرتب الدروس من الأقدم إلى الأحدث.
      */
      _sortLessonsOldestFirst(lessons);

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
    =====================================================
    البحث داخل الدروس
    =====================================================

    البحث يشمل:
    - عنوان الدرس
    - وصف الدرس
    - المادة
    - المدرس
    - الصف
    - الشعبة
    - تاريخ الدرس
    - يوم الدرس
    - وقت الإضافة
    - وقت آخر تعديل
  */
  void _searchLessons(String value) {
    final query = value.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredLessons = _lessons;
      });
      return;
    }

    final filtered =
        _lessons.where((lesson) {
          final createdDayName =
              lesson.createdDayName.isNotEmpty
                  ? lesson.createdDayName
                  : _dayName(lesson.createdAt);

          final createdTime =
              lesson.createdTime.isNotEmpty
                  ? lesson.createdTime
                  : _formatTime(lesson.createdAt);

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

          final text =
              '${lesson.title} '
                      '${lesson.description} '
                      '${lesson.subjectName} '
                      '${lesson.teacherName} '
                      '${lesson.classRoomName} '
                      '${lesson.sectionName} '
                      '${_dayName(lesson.lessonDate)} '
                      '${_formatDate(lesson.lessonDate)} '
                      '$createdDayName '
                      '${_formatDate(lesson.createdAt)} '
                      '$createdTime '
                      '$updatedDayName '
                      '${updatedAt == null ? '' : _formatDate(updatedAt)} '
                      '$updatedTime'
                  .toLowerCase();

          return text.contains(query);
        }).toList();

    /*
      نحافظ على نفس الترتيب بعد البحث:
      الأقدم أولًا، والأحدث أخيرًا.
    */
    _sortLessonsOldestFirst(filtered);

    setState(() {
      _filteredLessons = filtered;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    /*
      تحويل الوقت إلى 12 ساعة مع صباحًا / مساءً.

      مثال:
      08:30 صباحًا
      02:15 مساءً
    */
    final period = date.hour >= 12 ? 'مساءً' : 'صباحًا';

    int hour = date.hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    final minute = date.minute.toString().padLeft(2, '0');

    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  String _dayName(DateTime date) {
    /*
      هذه الدالة ترجع اسم اليوم بالعربي حسب التاريخ.

      مثال:
      2026-05-10 => الأحد
    */
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

  Widget _buildLessonCard(StudentLessonModel lesson) {
    final createdDayName =
        lesson.createdDayName.isNotEmpty
            ? lesson.createdDayName
            : _dayName(lesson.createdAt);

    final createdTime =
        lesson.createdTime.isNotEmpty
            ? lesson.createdTime
            : _formatTime(lesson.createdAt);

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
              ),
            ),
          ],

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(
                icon: Icons.book_outlined,
                text:
                    lesson.subjectName.isEmpty
                        ? 'غير محدد'
                        : lesson.subjectName,
              ),
              _buildBadge(
                icon: Icons.person_outline,
                text:
                    lesson.teacherName.isEmpty
                        ? 'غير محدد'
                        : lesson.teacherName,
              ),
              _buildBadge(
                icon: Icons.calendar_today_outlined,
                text:
                    '${_dayName(lesson.lessonDate)} - ${_formatDate(lesson.lessonDate)}',
              ),
            ],
          ),

          const SizedBox(height: 14),

          /*
            صندوق وقت الإضافة.
          */
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
                      'أضيف: $createdDayName - ${_formatDate(lesson.createdAt)}',
                ),
                _buildBadge(icon: Icons.access_time, text: createdTime),
              ],
            ),
          ),

          /*
            صندوق وقت آخر تعديل.
            يظهر فقط إذا وصل updatedAt من API
            أو وصلت بيانات updatedDayName / updatedTime.
          */
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
            text,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ],
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
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'دروسي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.student.classRoomName} • ${widget.student.sectionName}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: _searchController,
            onChanged: _searchLessons,
            decoration: InputDecoration(
              labelText: 'بحث في الدروس',
              hintText: 'ابحث بالعنوان، المادة، المدرس، التاريخ...',
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
          ),

          const SizedBox(height: 18),

          if (_filteredLessons.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'لا توجد دروس متاحة لصفك وشعبتك حتى الآن.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          else
            ..._filteredLessons.map(_buildLessonCard),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }
}
