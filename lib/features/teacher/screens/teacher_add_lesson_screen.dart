import 'package:flutter/material.dart';

import '../models/teacher_assignment_model.dart';
import '../models/teacher_lesson_model.dart';
import '../services/teacher_service.dart';

class TeacherAddLessonScreen extends StatefulWidget {
  /*
    هذه الصفحة تعمل بطريقتين:

    1) إضافة درس:
       عندما لا نرسل lesson.

    2) تعديل درس:
       عندما نرسل lesson من صفحة دروسي.
  */

  final TeacherLessonModel? lesson;

  const TeacherAddLessonScreen({super.key, this.lesson});

  bool get isEditMode => lesson != null;

  @override
  State<TeacherAddLessonScreen> createState() => _TeacherAddLessonScreenState();
}

class _TeacherAddLessonScreenState extends State<TeacherAddLessonScreen> {
  final TeacherService _teacherService = TeacherService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoadingAssignments = true;
  bool _isSaving = false;

  String? _errorMessage;

  List<TeacherAssignmentModel> _assignments = [];
  TeacherAssignmentModel? _selectedAssignment;

  DateTime _lessonDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    /*
      إذا كانت الصفحة في وضع التعديل،
      نملأ الحقول ببيانات الدرس الحالي.
    */
    final lesson = widget.lesson;

    if (lesson != null) {
      _titleController.text = lesson.title;
      _descriptionController.text = lesson.description;
      _lessonDate = lesson.lessonDate;
    }

    _loadAssignments();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /*
    =====================================================
    تحميل تكليفات الأستاذ
    =====================================================

    نعرضها في قائمة منسدلة:
    المادة - الصف - الشعبة

    في وضع التعديل:
    نحاول تحديد نفس التكليف المرتبط بالدرس.
  */
  Future<void> _loadAssignments() async {
    setState(() {
      _isLoadingAssignments = true;
      _errorMessage = null;
    });

    try {
      final assignments = await _teacherService.getMyAssignments();

      TeacherAssignmentModel? selected;

      /*
        إذا كنا نعدل درسًا موجودًا،
        نختار التكليف الحالي للدرس بدل اختيار أول عنصر.
      */
      if (widget.lesson != null) {
        for (final assignment in assignments) {
          if (assignment.id == widget.lesson!.teacherAssignmentId) {
            selected = assignment;
            break;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _assignments = assignments;
        _selectedAssignment =
            selected ?? (assignments.isNotEmpty ? assignments.first : null);
        _isLoadingAssignments = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoadingAssignments = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /*
    اختيار تاريخ الدرس.
  */
  Future<void> _pickLessonDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lessonDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      _lessonDate = picked;
    });
  }

  /*
    =====================================================
    حفظ الدرس
    =====================================================

    إذا كانت الصفحة إضافة:
    نستدعي createLesson.

    إذا كانت الصفحة تعديل:
    نستدعي updateLesson.
  */
  Future<void> _saveLesson() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final selectedAssignment = _selectedAssignment;

    if (selectedAssignment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار التكليف التدريسي.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.isEditMode) {
        /*
          تعديل درس موجود.
        */
        await _teacherService.updateLesson(
          lessonId: widget.lesson!.id,
          teacherAssignmentId: selectedAssignment.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          lessonDate: _lessonDate,
        );
      } else {
        /*
          إضافة درس جديد.
        */
        await _teacherService.createLesson(
          teacherAssignmentId: selectedAssignment.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          lessonDate: _lessonDate,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditMode
                ? 'تم تعديل الدرس بنجاح.'
                : 'تم إضافة الدرس بنجاح.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      /*
        نرجع true حتى صفحة دروسي تعيد تحميل القائمة.
      */
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceAll('Exception:', '').trim();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
      child: Row(
        children: [
          const CircleAvatar(
            radius: 33,
            backgroundColor: Colors.white24,
            child: Icon(Icons.add_task_outlined, color: Colors.white, size: 34),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEditMode ? 'تعديل درس' : 'إضافة درس',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isEditMode
                      ? 'عدّل بيانات الدرس ثم احفظ التغييرات.'
                      : 'اختر التكليف ثم أضف عنوان ووصف وتاريخ الدرس.',
                  style: const TextStyle(
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

  Widget _buildFormCard() {
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
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            DropdownButtonFormField<TeacherAssignmentModel>(
              value: _selectedAssignment,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'التكليف التدريسي',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              items:
                  _assignments.map((assignment) {
                    return DropdownMenuItem<TeacherAssignmentModel>(
                      value: assignment,
                      child: Text(
                        assignment.displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAssignment = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'التكليف التدريسي مطلوب';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان الدرس',
                prefixIcon: Icon(Icons.title_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'عنوان الدرس مطلوب';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'وصف الدرس',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: _pickLessonDate,
              child: Container(
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
                      Icons.calendar_today_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'تاريخ الدرس: ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatDate(_lessonDate),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    const Icon(Icons.edit_calendar_outlined),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveLesson,
                icon:
                    _isSaving
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.save_outlined),
                label: Text(
                  _isSaving
                      ? 'جاري الحفظ...'
                      : widget.isEditMode
                      ? 'حفظ التعديل'
                      : 'حفظ الدرس',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingAssignments) {
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
                  onPressed: _loadAssignments,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_assignments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'لا توجد تكليفات مرتبطة بهذا الأستاذ، لذلك لا يمكن إضافة درس.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, height: 1.6),
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _buildHeaderCard(),
        const SizedBox(height: 18),
        _buildFormCard(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditMode ? 'تعديل درس' : 'إضافة درس'),
          centerTitle: true,
        ),
        body: _buildBody(),
      ),
    );
  }
}
