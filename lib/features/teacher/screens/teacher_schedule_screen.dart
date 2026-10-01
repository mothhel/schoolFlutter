import 'package:flutter/material.dart';

import '../models/teacher_schedule_model.dart';
import '../services/teacher_service.dart';

class TeacherScheduleScreen extends StatefulWidget {
  const TeacherScheduleScreen({super.key});

  @override
  State<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> {
  final TeacherService _teacherService = TeacherService();

  bool _isLoading = true;
  String? _errorMessage;

  List<TeacherScheduleModel> _schedules = [];
  List<TeacherScheduleModel> _filteredSchedules = [];

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

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final schedules = await _teacherService.getMySchedule();

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
    البحث داخل جدول الأستاذ
    =====================================================

    البحث الآن يعمل في:
    - اليوم
    - اسم المادة
    - الصف
    - الشعبة
    - القاعة
    - رقم الحصة
    - وقت البداية
    - وقت النهاية
    - الملاحظات

    وأيضًا إذا كتب المستخدم اسم يوم مثل:
    الأحد
    يظهر قسم الأحد فقط.
  */
  void _searchSchedule(String value) {
    final query = value.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredSchedules = _schedules;
      });
      return;
    }

    setState(() {
      _filteredSchedules =
          _schedules.where((item) {
            final timeText =
                '${item.startTime} ${item.endTime} ${item.startTime} - ${item.endTime}';

            final periodText =
                'الحصة ${item.periodNumber} حصة ${item.periodNumber} ${item.periodNumber}';

            final text =
                '${item.dayName} '
                        '${item.subjectName} '
                        '${item.classRoomName} '
                        '${item.sectionName} '
                        '${item.roomName} '
                        '${item.notes} '
                        '$periodText '
                        '$timeText'
                    .toLowerCase();

            return text.contains(query);
          }).toList();
    });
  }

  /*
    نرجع اسم اليوم إذا كان البحث هو اسم يوم.
    هذا يساعدنا نعرض اليوم حتى لو لم توجد فيه حصص.
  */
  String? _searchedDayName() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) return null;

    for (final day in _dayOrder) {
      if (day.toLowerCase().contains(query) ||
          query.contains(day.toLowerCase())) {
        return day;
      }
    }

    return null;
  }

  Map<String, List<TeacherScheduleModel>> _groupByDay() {
    final map = <String, List<TeacherScheduleModel>>{};

    for (final item in _filteredSchedules) {
      map.putIfAbsent(item.dayName, () => []);
      map[item.dayName]!.add(item);
    }

    for (final day in map.keys) {
      map[day]!.sort((a, b) => a.periodNumber.compareTo(b.periodNumber));
    }

    return map;
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
              Icons.table_chart_outlined,
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
                  'جدولي الدراسي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'هنا تظهر الحصص المرتبطة بتكليفاتك فقط.',
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

  Widget _buildScheduleCard(TeacherScheduleModel item) {
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
                  Icons.menu_book_outlined,
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
                icon: Icons.school_outlined,
                text: item.classRoomName,
              ),
              _buildBadge(icon: Icons.groups_outlined, text: item.sectionName),
              _buildBadge(icon: Icons.access_time, text: timeText),
              _buildBadge(
                icon: Icons.meeting_room_outlined,
                text: item.roomName.isEmpty ? 'قاعة غير محددة' : item.roomName,
              ),
            ],
          ),

          if (item.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                item.notes,
                style: const TextStyle(
                  color: Colors.grey,
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDaySection({
    required String day,
    required List<TeacherScheduleModel> items,
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

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: _searchSchedule,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: 'بحث في الجدول',
        prefixIcon: const Icon(Icons.search),
        suffixIcon:
            _searchController.text.trim().isEmpty
                ? null
                : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _searchSchedule('');
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
    final searchedDay = _searchedDayName();
    final isSearching = _searchController.text.trim().isNotEmpty;

    return RefreshIndicator(
      onRefresh: _loadSchedule,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _buildHeaderCard(),

          const SizedBox(height: 18),

          _buildSearchField(),

          const SizedBox(height: 18),

          if (_filteredSchedules.isEmpty && searchedDay == null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                isSearching
                    ? 'لا توجد نتائج مطابقة للبحث.'
                    : 'لا يوجد جدول دراسي مرتبط بتكليفاتك حتى الآن.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          else if (searchedDay != null)
            _buildDaySection(
              day: searchedDay,
              items: grouped[searchedDay] ?? [],
            )
          else
            ..._dayOrder.map(
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
