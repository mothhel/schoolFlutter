import 'package:flutter/material.dart';

import '../models/student_attendance_model.dart';
import '../models/student_profile_model.dart';
import '../services/student_service.dart';

class StudentAttendanceScreen extends StatefulWidget {
  final StudentProfileModel student;

  const StudentAttendanceScreen({super.key, required this.student});

  @override
  State<StudentAttendanceScreen> createState() =>
      _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  final StudentService _studentService = StudentService();

  bool _isLoading = true;
  String? _errorMessage;

  List<StudentAttendanceModel> _attendances = [];
  List<StudentAttendanceModel> _filteredAttendances = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /*
    =====================================================
    تحميل سجل الحضور والغياب
    =====================================================
  */
  Future<void> _loadAttendance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final attendances = await _studentService.getMyAttendance(
        studentId: widget.student.id,
      );

      if (!mounted) return;

      setState(() {
        _attendances = attendances;
        _filteredAttendances = attendances;
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
    البحث داخل السجل
  */
  void _searchAttendance(String value) {
    final query = value.trim().toLowerCase();

    setState(() {
      _filteredAttendances =
          _attendances.where((item) {
            final text =
                '${item.subjectName} ${item.teacherName} ${item.status}'
                    .toLowerCase();

            return text.contains(query);
          }).toList();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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

  Color _statusColor(String status) {
    if (status == 'غائب') {
      return Colors.red;
    }

    if (status == 'مستأذن') {
      return Colors.orange;
    }

    return Colors.green;
  }

  IconData _statusIcon(String status) {
    if (status == 'غائب') {
      return Icons.cancel_outlined;
    }

    if (status == 'مستأذن') {
      return Icons.info_outline;
    }

    return Icons.check_circle_outline;
  }

  Widget _buildStatusBadge(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(status), size: 16, color: color),
          const SizedBox(width: 5),
          Text(
            status.isEmpty ? 'غير محدد' : status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(StudentAttendanceModel item) {
    final color = _statusColor(item.status);

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
        border: Border.all(color: color.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: color.withOpacity(0.10),
                child: Icon(_statusIcon(item.status), color: color),
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
              _buildStatusBadge(item.status),
            ],
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSmallBadge(
                icon: Icons.person_outline,
                text:
                    item.teacherName.isEmpty
                        ? 'مدرس غير محدد'
                        : item.teacherName,
              ),
              _buildSmallBadge(
                icon: Icons.calendar_today_outlined,
                text:
                    '${_dayName(item.attendanceDate)} - ${_formatDate(item.attendanceDate)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge({required IconData icon, required String text}) {
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

  Widget _buildSummaryBoxes() {
    final presentCount = _attendances.where((x) => x.status == 'حاضر').length;
    final absentCount = _attendances.where((x) => x.status == 'غائب').length;
    final excusedCount = _attendances.where((x) => x.status == 'مستأذن').length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryBox(
            title: 'حاضر',
            count: presentCount,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSummaryBox(
            title: 'غائب',
            count: absentCount,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSummaryBox(
            title: 'مستأذن',
            count: excusedCount,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryBox({
    required String title,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.16)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
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
                  onPressed: _loadAttendance,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAttendance,
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
                  'حضوري وغيابي',
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

          _buildSummaryBoxes(),

          const SizedBox(height: 18),

          TextField(
            controller: _searchController,
            onChanged: _searchAttendance,
            decoration: const InputDecoration(
              labelText: 'بحث في السجل',
              prefixIcon: Icon(Icons.search),
            ),
          ),

          const SizedBox(height: 18),

          if (_filteredAttendances.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'لا يوجد سجل حضور وغياب حتى الآن.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          else
            ..._filteredAttendances.map(_buildAttendanceCard),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }
}
