import 'package:flutter/material.dart';

import '../models/student_class_result_model.dart';
import '../models/student_grade_classroom_model.dart';
import '../models/student_result_subject_model.dart';
import '../services/student_service.dart';

class StudentResultScreen extends StatefulWidget {
  const StudentResultScreen({super.key});

  @override
  State<StudentResultScreen> createState() => _StudentResultScreenState();
}

class _StudentResultScreenState extends State<StudentResultScreen> {
  final StudentService _studentService = StudentService();

  bool _isLoadingClassRooms = true;
  bool _isLoadingResult = false;

  String? _errorMessage;

  List<StudentGradeClassRoomModel> _classRooms = [];
  StudentGradeClassRoomModel? _selectedClassRoom;

  String _selectedResultType = 'MidYear';

  StudentClassResultModel? _result;

  @override
  void initState() {
    super.initState();
    _loadClassRooms();
  }

  String _gradeLabel(double percentage) {
    if (percentage >= 90) {
      return 'ممتاز';
    }

    if (percentage >= 80) {
      return 'جيد جدًا';
    }

    if (percentage >= 70) {
      return 'جيد';
    }

    if (percentage >= 60) {
      return 'مقبول';
    }

    if (percentage >= 50) {
      return 'ضعيف';
    }

    return 'راسب';
  }

  int _failedSubjectsCount() {
    /*
    هذه الدالة تحسب عدد المواد التي حالتها راسب.

    إذا رجع العدد أكبر من 0:
    نعرض عدد مواد الرسوب بجانب الحالة.

    إذا رجع 0:
    نخفي خانة عدد مواد الرسوب.
  */
    final result = _result;

    if (result == null) return 0;

    return result.subjects.where((subject) => subject.status == 'راسب').length;
  }

  /*
    =====================================================
    تحميل الصفوف المتاحة
    =====================================================
  */
  Future<void> _loadClassRooms() async {
    setState(() {
      _isLoadingClassRooms = true;
      _errorMessage = null;
    });

    try {
      final classRooms = await _studentService.getMyGradeClassRooms();

      if (!mounted) return;

      setState(() {
        _classRooms = classRooms;
        _selectedClassRoom = classRooms.isNotEmpty ? classRooms.first : null;
        _isLoadingClassRooms = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoadingClassRooms = false;
      });
    }
  }

  /*
    =====================================================
    تحميل النتيجة
    =====================================================
  */
  Future<void> _loadResult() async {
    final selectedClassRoom = _selectedClassRoom;

    if (selectedClassRoom == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار الصف أولًا.')));
      return;
    }

    setState(() {
      _isLoadingResult = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final result = await _studentService.getMyClassResult(
        classRoomId: selectedClassRoom.classRoomId,
        resultType: _selectedResultType,
      );

      if (!mounted) return;

      setState(() {
        _result = result;
        _isLoadingResult = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoadingResult = false;
      });
    }
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  Color _statusColor(String status) {
    if (status == 'ناجح') {
      return Colors.green;
    }

    if (status == 'راسب') {
      return Colors.red;
    }

    return Colors.orange;
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
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 33,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.emoji_events_outlined,
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
                  'نتيجتي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'اختر الصف ونوع النتيجة لعرض كشف النتيجة الكامل.',
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

  Widget _buildSelectionCard() {
    final selectedClassRoom = _selectedClassRoom;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'اختيار النتيجة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<StudentGradeClassRoomModel>(
            value: selectedClassRoom,
            decoration: const InputDecoration(
              labelText: 'اختر الصف',
              prefixIcon: Icon(Icons.school_outlined),
            ),
            items:
                _classRooms.map((item) {
                  return DropdownMenuItem<StudentGradeClassRoomModel>(
                    value: item,
                    child: Text(item.classRoomName),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedClassRoom = value;
                _result = null;
              });
            },
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.groups_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                const Text(
                  'الشعبة: ',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    selectedClassRoom?.sectionName ?? 'غير متوفر',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'نوع النتيجة',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildResultTypeChoice(
                  title: 'نتيجة نصف العام',
                  value: 'MidYear',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildResultTypeChoice(
                  title: 'نتيجة نهاية العام',
                  value: 'FinalYear',
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isLoadingResult ? null : _loadResult,
              icon:
                  _isLoadingResult
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.search),
              label: Text(
                _isLoadingResult ? 'جاري التحميل...' : 'عرض النتيجة',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTypeChoice({
    required String title,
    required String value,
  }) {
    final isSelected = _selectedResultType == value;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        setState(() {
          _selectedResultType = value;
          _result = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                  : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade200,
          ),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary
                      : const Color(0xFF1E293B),
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultSummary() {
    final result = _result;

    if (result == null) return const SizedBox.shrink();

    final color = _statusColor(result.overallStatus);

    /*
    نحسب عدد المواد الراسبة.
    إذا يوجد رسوب، نعرض الحالة العامة راسب
    ونظهر عدد مواد الرسوب.
  */
    final failedCount = _failedSubjectsCount();
    final displayedStatus = failedCount > 0 ? 'راسب' : result.overallStatus;
    final displayedStatusColor = _statusColor(displayedStatus);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.resultTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMiniBadge(
                icon: Icons.school_outlined,
                text: result.classRoomName,
              ),
              _buildMiniBadge(
                icon: Icons.groups_outlined,
                text: result.sectionName,
              ),
              _buildMiniBadge(
                icon: Icons.calculate_outlined,
                text:
                    '${_formatNumber(result.totalScore)} / ${_formatNumber(result.totalMaxScore)}',
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _buildSummaryBox(
                  title: 'النسبة',
                  value: '${_formatNumber(result.percentage)}%',
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryBox(
                  title: 'التقدير',
                  value: _gradeLabel(result.percentage),
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryBox(
                  title: 'الحالة',
                  value: displayedStatus,
                  color: displayedStatusColor,
                ),
              ),
            ],
          ),

          if (failedCount > 0) ...[
            const SizedBox(height: 10),
            _buildSummaryBox(
              title: 'عدد مواد الرسوب',
              value: failedCount.toString(),
              color: Colors.red,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryBox({
    required String title,
    required String value,
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
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
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

  Widget _buildMiniBadge({required IconData icon, required String text}) {
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

  Widget _buildSubjectCard(StudentResultSubjectModel subject) {
    final color = _statusColor(subject.status);
    final percentage =
        subject.totalMaxScore == 0
            ? 0.0
            : (subject.totalScore / subject.totalMaxScore).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
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
                radius: 24,
                backgroundColor: color.withOpacity(0.10),
                child: Icon(Icons.book_outlined, color: color),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.subjectName.isEmpty
                          ? 'مادة غير محددة'
                          : subject.subjectName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subject.teacherName.isEmpty
                          ? 'مدرس غير محدد'
                          : subject.teacherName,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  subject.status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...subject.components.map(
            (component) => _buildComponentRow(
              title: component.title,
              score: component.score,
              maxScore: component.maxScore,
            ),
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 9,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Text(
                'الإجمالي',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_formatNumber(subject.totalScore)} / ${_formatNumber(subject.totalMaxScore)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${_formatNumber(subject.percentage)}%',
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComponentRow({
    required String title,
    required double score,
    required double maxScore,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
              ),
            ),
          ),
          Text(
            '${_formatNumber(score)} / ${_formatNumber(maxScore)}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildResultContent() {
    final result = _result;

    if (result == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: const Text(
          'اختر الصف ونوع النتيجة ثم اضغط عرض النتيجة.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            height: 1.6,
          ),
        ),
      );
    }

    if (result.subjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text(
          'لا توجد درجات مسجلة لهذه النتيجة حتى الآن.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    return Column(
      children: [
        _buildResultSummary(),
        const SizedBox(height: 16),
        ...result.subjects.map(_buildSubjectCard),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoadingClassRooms) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _classRooms.isEmpty) {
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
                  onPressed: _loadClassRooms,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadClassRooms,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 18),
          _buildSelectionCard(),
          const SizedBox(height: 18),

          if (_errorMessage != null && _result == null)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          _buildResultContent(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }
}
