import 'package:flutter/material.dart';

import '../models/student_homework_model.dart';
import '../models/student_profile_model.dart';
import '../services/student_service.dart';

class StudentHomeworksScreen extends StatefulWidget {
  final StudentProfileModel student;

  const StudentHomeworksScreen({super.key, required this.student});

  @override
  State<StudentHomeworksScreen> createState() => _StudentHomeworksScreenState();
}

class _StudentHomeworksScreenState extends State<StudentHomeworksScreen> {
  final StudentService _studentService = StudentService();

  bool _isLoading = true;
  String? _errorMessage;

  List<StudentHomeworkModel> _homeworks = [];
  List<StudentHomeworkModel> _filteredHomeworks = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHomeworks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /*
    =====================================================
    ترتيب الواجبات
    =====================================================

    المطلوب:
    - أول واجب تم إضافته يظهر في البداية
    - آخر واجب تم إضافته يظهر في الأخير

    لذلك نرتب تصاعديًا حسب createdAt.
  */
  void _sortHomeworksOldestFirst(List<StudentHomeworkModel> homeworks) {
    homeworks.sort((a, b) {
      return a.createdAt.compareTo(b.createdAt);
    });
  }

  /*
    =====================================================
    تحميل واجبات الطالب
    =====================================================

    نرسل صف وشعبة الطالب حتى نعرض الواجبات المناسبة فقط.
  */
  Future<void> _loadHomeworks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final homeworks = await _studentService.getMyHomeworks(
        classRoomName: widget.student.classRoomName,
        sectionName: widget.student.sectionName,
      );

      /*
        ترتيب الواجبات من الأقدم إلى الأحدث.
      */
      _sortHomeworksOldestFirst(homeworks);

      if (!mounted) return;

      setState(() {
        _homeworks = homeworks;
        _filteredHomeworks = homeworks;
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
    البحث داخل الواجبات
    =====================================================

    البحث يشمل:
    - عنوان الواجب
    - وصف الواجب
    - المادة
    - المدرس
    - الصف
    - الشعبة
    - تاريخ التسليم
    - يوم التسليم
    - وقت الإضافة
    - وقت آخر تعديل
  */
  void _searchHomeworks(String value) {
    final query = value.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredHomeworks = _homeworks;
      });
      return;
    }

    final filtered =
        _homeworks.where((homework) {
          final createdDayName =
              homework.createdDayName.isNotEmpty
                  ? homework.createdDayName
                  : _dayName(homework.createdAt);

          final createdTime =
              homework.createdTime.isNotEmpty
                  ? homework.createdTime
                  : _formatTime(homework.createdAt);

          final updatedAt = homework.updatedAt;

          final updatedDayName =
              homework.updatedDayName.isNotEmpty
                  ? homework.updatedDayName
                  : updatedAt == null
                  ? ''
                  : _dayName(updatedAt);

          final updatedTime =
              homework.updatedTime.isNotEmpty
                  ? homework.updatedTime
                  : updatedAt == null
                  ? ''
                  : _formatTime(updatedAt);

          final text =
              '${homework.title} '
                      '${homework.description} '
                      '${homework.subjectName} '
                      '${homework.teacherName} '
                      '${homework.classRoomName} '
                      '${homework.sectionName} '
                      '${_dayName(homework.dueDate)} '
                      '${_formatDate(homework.dueDate)} '
                      '$createdDayName '
                      '${_formatDate(homework.createdAt)} '
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
    _sortHomeworksOldestFirst(filtered);

    setState(() {
      _filteredHomeworks = filtered;
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

  bool _isLate(DateTime dueDate) {
    final today = DateTime.now();

    final todayOnly = DateTime(today.year, today.month, today.day);
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);

    return dueDateOnly.isBefore(todayOnly);
  }

  Widget _buildBadge({
    required IconData icon,
    required String text,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: textColor ?? Colors.grey.shade700),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkCard(StudentHomeworkModel homework) {
    final isLate = _isLate(homework.dueDate);

    final createdDayName =
        homework.createdDayName.isNotEmpty
            ? homework.createdDayName
            : _dayName(homework.createdAt);

    final createdTime =
        homework.createdTime.isNotEmpty
            ? homework.createdTime
            : _formatTime(homework.createdAt);

    final updatedAt = homework.updatedAt;

    final updatedDayName =
        homework.updatedDayName.isNotEmpty
            ? homework.updatedDayName
            : updatedAt == null
            ? ''
            : _dayName(updatedAt);

    final updatedTime =
        homework.updatedTime.isNotEmpty
            ? homework.updatedTime
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
        border: Border.all(
          color: isLate ? Colors.red.shade100 : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor:
                    isLate
                        ? Colors.red.withOpacity(0.10)
                        : Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.12),
                child: Icon(
                  Icons.assignment_outlined,
                  color:
                      isLate
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  homework.title.isEmpty ? 'واجب بدون عنوان' : homework.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          if (homework.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              homework.description,
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
                    homework.subjectName.isEmpty
                        ? 'غير محدد'
                        : homework.subjectName,
              ),
              _buildBadge(
                icon: Icons.person_outline,
                text:
                    homework.teacherName.isEmpty
                        ? 'غير محدد'
                        : homework.teacherName,
              ),
              _buildBadge(
                icon: Icons.calendar_today_outlined,
                text:
                    'التسليم: ${_dayName(homework.dueDate)} - ${_formatDate(homework.dueDate)}',
                backgroundColor:
                    isLate ? Colors.red.shade50 : Colors.green.shade50,
                textColor: isLate ? Colors.red.shade700 : Colors.green.shade700,
              ),
            ],
          ),

          if (isLate) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'تنبيه: انتهى تاريخ تسليم هذا الواجب.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

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
                      'أضيف: $createdDayName - ${_formatDate(homework.createdAt)}',
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
                            ? 'تم تعديل الواجب'
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
                  onPressed: _loadHomeworks,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHomeworks,
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
                  'واجباتي',
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
            onChanged: _searchHomeworks,
            decoration: InputDecoration(
              labelText: 'بحث في الواجبات',
              hintText: 'ابحث بالعنوان، المادة، المدرس، التاريخ...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  _searchController.text.trim().isEmpty
                      ? null
                      : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _searchHomeworks('');
                        },
                        icon: const Icon(Icons.close),
                      ),
            ),
          ),

          const SizedBox(height: 18),

          if (_filteredHomeworks.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'لا توجد واجبات متاحة لصفك وشعبتك حتى الآن.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          else
            ..._filteredHomeworks.map(_buildHomeworkCard),

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
