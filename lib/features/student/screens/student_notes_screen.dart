import 'package:flutter/material.dart';

import '../models/student_note_model.dart';
import '../services/student_service.dart';

class StudentNotesScreen extends StatefulWidget {
  const StudentNotesScreen({super.key});

  @override
  State<StudentNotesScreen> createState() => _StudentNotesScreenState();
}

class _StudentNotesScreenState extends State<StudentNotesScreen> {
  final StudentService _studentService = StudentService();

  bool _isLoading = true;
  String? _errorMessage;

  List<StudentNoteModel> _notes = [];
  List<StudentNoteModel> _filteredNotes = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /*
    =====================================================
    تحميل ملاحظات الطالب
    =====================================================
  */
  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notes = await _studentService.getMyNotes();

      if (!mounted) return;

      setState(() {
        _notes = notes;
        _filteredNotes = notes;
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
    البحث داخل الملاحظات

    نبحث في:
    - نص الملاحظة
    - اسم اليوم
    - التاريخ
    - الوقت
  */
  void _searchNotes(String value) {
    final query = value.trim().toLowerCase();

    setState(() {
      _filteredNotes =
          _notes.where((note) {
            final text =
                '${note.noteText} ${_dayName(note.createdAt)} ${_formatDate(note.createdAt)} ${_formatTime(note.createdAt)}'
                    .toLowerCase();

            return text.contains(query);
          }).toList();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    /*
    هذه الدالة تعرض الوقت بنظام 12 ساعة
    مع توضيح هل الوقت صباحًا أو مساءً.

    مثال:
    08:30 صباحًا
    02:45 مساءً
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
      هذه الدالة ترجع اسم اليوم بالعربي حسب تاريخ الملاحظة.

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

  Widget _buildNoteCard(StudentNoteModel note, int index) {
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
          /*
            رأس بطاقة الملاحظة:
            يحتوي على أيقونة الملاحظة ورقمها فقط.
            التاريخ والوقت وضعناهما في الأسفل حتى يكون الشكل أنظف.
          */
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.12),
                child: Icon(
                  Icons.note_alt_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ملاحظة رقم ${index + 1}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /*
            نص الملاحظة.
          */
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              note.noteText.isEmpty ? 'لا يوجد نص للملاحظة.' : note.noteText,
              style: const TextStyle(
                height: 1.8,
                fontSize: 15,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 14),

          /*
            معلومات التاريخ والوقت في أسفل البطاقة.
            يظهر اليوم بجانب التاريخ، والوقت في شارة مستقلة.
          */
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoBadge(
                icon: Icons.calendar_today_outlined,
                text:
                    '${_dayName(note.createdAt)} - ${_formatDate(note.createdAt)}',
              ),
              _buildInfoBadge(
                icon: Icons.access_time,
                text: _formatTime(note.createdAt),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({required IconData icon, required String text}) {
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
                  onPressed: _loadNotes,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotes,
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملاحظاتي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'هنا تظهر الملاحظات التي أضافتها الإدارة لك.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: _searchController,
            onChanged: _searchNotes,
            decoration: const InputDecoration(
              labelText: 'بحث في الملاحظات',
              prefixIcon: Icon(Icons.search),
            ),
          ),

          const SizedBox(height: 18),

          if (_filteredNotes.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'لا توجد ملاحظات حتى الآن.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          else
            ..._filteredNotes.asMap().entries.map(
              (entry) => _buildNoteCard(entry.value, entry.key),
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
