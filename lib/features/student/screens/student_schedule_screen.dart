import 'package:flutter/material.dart';

import '../models/student_profile_model.dart';
import '../models/student_schedule_model.dart';
import '../services/student_service.dart';

class StudentScheduleScreen extends StatefulWidget {
  final StudentProfileModel student;

  const StudentScheduleScreen({super.key, required this.student});

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  final StudentService _studentService = StudentService();

  bool _isLoading = true;
  String? _errorMessage;

  List<StudentScheduleModel> _schedules = [];
  List<StudentScheduleModel> _filteredSchedules = [];

  final TextEditingController _searchController = TextEditingController();

  final List<String> _dayOrder = const [
    'السبت',
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
  ];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /*
    =====================================================
    تحميل الجدول الدراسي
    =====================================================
  */
  Future<void> _loadSchedule() async {
    if (widget.student.classRoomId == null ||
        widget.student.sectionId == null) {
      setState(() {
        _errorMessage = 'بيانات الصف أو الشعبة غير مكتملة.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final schedules = await _studentService.getMySchedule(
        classRoomId: widget.student.classRoomId!,
        sectionId: widget.student.sectionId!,
      );

      if (!mounted) return;

      setState(() {
        _schedules = schedules;
        _filteredSchedules = schedules;
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
    تجهيز النص للبحث
    =====================================================

    الهدف:
    نخلي البحث أسهل للمستخدم.

    أمثلة:
    - إذا كتب الطالب: الاحد
      يظهر له: الأحد

    - إذا كتب: رياضيات
      يبحث في المادة والمدرس والقاعة والملاحظات.

    - إذا كتب: الحصة 1
      يبحث في رقم الحصة أيضًا.

    - إذا كتب: قاعه
      يقابل: قاعة

    نزيل التشكيل ونوحد بعض الحروف العربية حتى يكون البحث مرن.
  */
  String _normalizeText(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /*
    =====================================================
    البحث داخل الجدول
    =====================================================

    هنا نبحث في كل شيء يظهر تقريبًا داخل بطاقة الحصة:
    - اسم اليوم
    - رقم الحصة
    - كلمة الحصة مع الرقم
    - وقت البداية
    - وقت النهاية
    - الوقت كامل
    - اسم القاعة
    - الملاحظات
    - اسم المادة
    - اسم المدرس
    - اسم الصف
    - اسم الشعبة
    - رقم الصف
    - رقم الشعبة
  */
  void _searchSchedule(String value) {
    final query = _normalizeText(value);

    setState(() {
      if (query.isEmpty) {
        _filteredSchedules = _schedules;
        return;
      }

      _filteredSchedules =
          _schedules.where((item) {
            final timeText =
                item.startTime.isEmpty && item.endTime.isEmpty
                    ? 'وقت غير محدد'
                    : '${item.startTime.isEmpty ? '--:--' : item.startTime} - ${item.endTime.isEmpty ? '--:--' : item.endTime}';

            final searchableText = _normalizeText('''
${item.dayName}
${item.periodNumber}
الحصة ${item.periodNumber}
حصه ${item.periodNumber}
حصة ${item.periodNumber}
${item.startTime}
${item.endTime}
$timeText
${item.roomName}
قاعة ${item.roomName}
قاعه ${item.roomName}
${item.notes}
${item.subjectName}
مادة ${item.subjectName}
ماده ${item.subjectName}
${item.teacherName}
مدرس ${item.teacherName}
معلم ${item.teacherName}
${item.classRoomName}
صف ${item.classRoomName}
${item.sectionName}
شعبة ${item.sectionName}
شعبه ${item.sectionName}
${item.classRoomId ?? ''}
${item.sectionId ?? ''}
''');

            return searchableText.contains(query);
          }).toList();
    });
  }

  /*
    =====================================================
    تجميع الحصص حسب اليوم
    =====================================================

    بعد البحث، نجمع النتائج حسب اليوم.
    ثم نرتب الحصص داخل كل يوم حسب رقم الحصة.
  */
  Map<String, List<StudentScheduleModel>> _groupByDay() {
    final map = <String, List<StudentScheduleModel>>{};

    for (final item in _filteredSchedules) {
      final day =
          item.dayName.trim().isEmpty ? 'غير محدد' : item.dayName.trim();

      map.putIfAbsent(day, () => []);
      map[day]!.add(item);
    }

    for (final day in map.keys) {
      map[day]!.sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
    }

    return map;
  }

  /*
    =====================================================
    ترتيب أسماء الأيام للعرض
    =====================================================

    نعرض كل أيام الأسبوع الدراسي حتى لو لا توجد حصص.
    نستثني يوم الجمعة لأنه ليس يومًا دراسيًا.

    إذا رجع API يوم غير موجود في القائمة، نضيفه في النهاية.
    لكن الجمعة لا نضيفها.
  */
  List<String> _orderedVisibleDays(
    Map<String, List<StudentScheduleModel>> grouped,
  ) {
    final days = <String>[
      'السبت',
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
    ];

    final otherDays =
        grouped.keys
            .where((day) => !days.contains(day) && day != 'الجمعة')
            .toList()
          ..sort();

    days.addAll(otherDays);

    return days;
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

  Widget _buildScheduleCard(StudentScheduleModel item) {
    final timeText =
        item.startTime.isEmpty && item.endTime.isEmpty
            ? 'وقت غير محدد'
            : '${item.startTime.isEmpty ? '--:--' : item.startTime} - ${item.endTime.isEmpty ? '--:--' : item.endTime}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  Icons.table_chart_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.subjectName.isEmpty
                      ? 'مادة غير محددة'
                      : item.subjectName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'الحصة ${item.periodNumber}',
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(
                icon: Icons.person_outline,
                text:
                    item.teacherName.isEmpty
                        ? 'مدرس غير محدد'
                        : item.teacherName,
              ),
              _buildBadge(icon: Icons.access_time, text: timeText),
              _buildBadge(
                icon: Icons.meeting_room_outlined,
                text: item.roomName.isEmpty ? 'قاعة غير محددة' : item.roomName,
              ),
            ],
          ),

          if (item.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              item.notes,
              style: const TextStyle(
                color: Colors.grey,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDaySection({
    required String day,
    required List<StudentScheduleModel> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12, top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            day,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        if (items.isEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Text(
              'لا توجد حصص في هذا اليوم.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          )
        else
          ...items.map(_buildScheduleCard),
      ],
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
                  onPressed: _loadSchedule,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final grouped = _groupByDay();
    final hasSearch = _searchController.text.trim().isNotEmpty;

    final visibleDays =
        hasSearch
            ? _orderedVisibleDays(
              grouped,
            ).where((day) => grouped.containsKey(day)).toList()
            : _orderedVisibleDays(grouped);

    return RefreshIndicator(
      onRefresh: _loadSchedule,
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
                  'جدولي الدراسي',
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
            onChanged: _searchSchedule,
            decoration: const InputDecoration(
              labelText: 'بحث في الجدول',
              prefixIcon: Icon(Icons.search),
            ),
          ),

          const SizedBox(height: 18),

          if (_filteredSchedules.isEmpty && hasSearch)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'لا توجد نتائج مطابقة للبحث.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          else
            ...visibleDays.map(
              (day) => _buildDaySection(day: day, items: grouped[day] ?? []),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }
}
