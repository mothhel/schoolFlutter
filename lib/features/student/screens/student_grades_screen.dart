import 'package:flutter/material.dart';

import '../models/student_assessment_result_model.dart';
import '../models/student_grade_classroom_model.dart';
import '../services/student_service.dart';

class StudentGradesScreen extends StatefulWidget {
  const StudentGradesScreen({super.key});

  @override
  State<StudentGradesScreen> createState() => _StudentGradesScreenState();
}

class _StudentGradesScreenState extends State<StudentGradesScreen> {
  final StudentService _studentService = StudentService();

  bool _isLoadingClassRooms = true;
  bool _isLoadingGrades = false;

  String? _errorMessage;

  List<StudentGradeClassRoomModel> _classRooms = [];
  StudentGradeClassRoomModel? _selectedClassRoom;

  String _selectedAssessmentType = 'First';

  StudentAssessmentResultModel? _result;

  @override
  void initState() {
    super.initState();
    _loadClassRooms();
  }

  /*
    =====================================================
    تحميل الصفوف المتاحة للطالب
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
    تحميل درجات المحصلة
    =====================================================
  */
  Future<void> _loadGrades() async {
    final selectedClassRoom = _selectedClassRoom;

    if (selectedClassRoom == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار الصف أولًا.')));
      return;
    }

    setState(() {
      _isLoadingGrades = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final result = await _studentService.getMyAssessmentGrades(
        classRoomId: selectedClassRoom.classRoomId,
        assessmentType: _selectedAssessmentType,
      );

      if (!mounted) return;

      setState(() {
        _result = result;
        _isLoadingGrades = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoadingGrades = false;
      });
    }
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  double _calculateTotalScore() {
    final result = _result;

    if (result == null) return 0;

    return result.items.fold<double>(0, (sum, item) => sum + item.score);
  }

  double _calculateTotalMaxScore() {
    final result = _result;

    if (result == null) return 0;

    return result.items.fold<double>(0, (sum, item) => sum + item.maxScore);
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
            child: Icon(Icons.grade_outlined, color: Colors.white, size: 34),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'درجاتي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'اختر الصف والمحصلة لعرض درجات المواد.',
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

  Widget _buildSelectBox() {
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
            'اختيار البيانات',
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
            'نوع المحصلة',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildAssessmentChoice(
                  title: 'المحصلة الأولى',
                  value: 'First',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAssessmentChoice(
                  title: 'المحصلة الثانية',
                  value: 'Second',
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isLoadingGrades ? null : _loadGrades,
              icon:
                  _isLoadingGrades
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.search),
              label: Text(
                _isLoadingGrades ? 'جاري التحميل...' : 'عرض الدرجات',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentChoice({
    required String title,
    required String value,
  }) {
    final isSelected = _selectedAssessmentType == value;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        setState(() {
          _selectedAssessmentType = value;
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
            style: TextStyle(
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary
                      : const Color(0xFF1E293B),
              fontWeight: FontWeight.w900,
              fontSize: 13.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader() {
    final result = _result;

    if (result == null) return const SizedBox.shrink();

    final totalScore = _calculateTotalScore();
    final totalMax = _calculateTotalMaxScore();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.assessmentTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
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
                    '${_formatNumber(totalScore)} / ${_formatNumber(totalMax)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
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

  Widget _buildGradeCard(item) {
    final percentage =
        item.maxScore == 0 ? 0.0 : (item.score / item.maxScore).clamp(0.0, 1.0);

    Color color = Colors.green;

    if (percentage < 0.5) {
      color = Colors.red;
    } else if (percentage < 0.75) {
      color = Colors.orange;
    }

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
                      item.subjectName.isEmpty
                          ? 'مادة غير محددة'
                          : item.subjectName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.teacherName.isEmpty
                          ? 'مدرس غير محدد'
                          : item.teacherName,
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
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_formatNumber(item.score)} / ${_formatNumber(item.maxScore)}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
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

          if (item.notes != null &&
              item.notes.toString().trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              item.notes.toString(),
              style: const TextStyle(
                color: Colors.grey,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
          'اختر الصف ونوع المحصلة ثم اضغط عرض الدرجات.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            height: 1.6,
          ),
        ),
      );
    }

    if (result.items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text(
          'لا توجد درجات مسجلة لهذه المحصلة حتى الآن.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    return Column(
      children: [
        _buildResultHeader(),
        const SizedBox(height: 16),
        ...result.items.map(_buildGradeCard),
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
      onRefresh: () async {
        await _loadClassRooms();
      },
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 18),
          _buildSelectBox(),
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
