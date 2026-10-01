import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../../student/screens/student_home_screen.dart';
import '../../teacher/screens/teacher_home_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /*
    مفتاح الفورم:
    نستخدمه للتأكد أن اسم المستخدم وكلمة المرور ليست فارغة.
  */
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /*
    Controllers:
    نستخدمها لقراءة النص الذي يكتبه المستخدم.
  */
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /*
    AuthService:
    هذا الكلاس هو المسؤول عن إرسال بيانات الدخول إلى API.
  */
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    /*
      حذف الـ Controllers من الذاكرة عند إغلاق الشاشة.
    */
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /*
    =====================================================
    تنفيذ تسجيل الدخول
    =====================================================

    الخطوات:
    1) التحقق من الحقول.
    2) إرسال اسم المستخدم وكلمة المرور إلى AuthService.
    3) إذا كان المستخدم طالبًا، ننتقل إلى StudentHomeScreen.
    4) إذا كان غير طالب، نعرض رسالة مؤقتة.
    5) إذا حدث خطأ، نعرضه داخل SnackBar.
  */
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result.roleName == 'Student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentHomeScreen()),
        );
      } else if (result.roleName == 'Teacher') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TeacherHomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حاليًا واجهة المدير سنعملها بعد الطالب والأستاذ.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceAll('Exception:', '').trim();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildLogo(BuildContext context) {
    /*
      شعار أعلى صفحة تسجيل الدخول.
      يعرض أيقونة المدرسة بشكل واضح واحترافي.
    */
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.72),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Icon(Icons.school_rounded, color: Colors.white, size: 48),
    );
  }

  Widget _buildWelcomeText() {
    /*
      عنوان وترحيب الصفحة.
    */
    return const Column(
      children: [
        Text(
          'مرحبًا بك',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'سجّل الدخول للوصول إلى بوابة الطالب',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 15,
            height: 1.7,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    /*
      بطاقة تسجيل الدخول:
      تحتوي على حقول اسم المستخدم وكلمة المرور وزر الدخول.
    */
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.8)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: 0.2,
              ),
              decoration: InputDecoration(
                labelText: 'اسم المستخدم',
                hintText: 'اسم المستخدم',
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF475569),
                ),
                hintStyle: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'اسم المستخدم مطلوب';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _passwordController,
              obscureText: _hidePassword,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: 0.3,
              ),
              onFieldSubmitted: (_) {
                if (!_isLoading) {
                  _login();
                }
              },
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                hintText: 'كلمة المرور',
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF475569),
                ),
                hintStyle: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _hidePassword = !_hidePassword;
                    });
                  },
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'كلمة المرور مطلوبة';
                }

                return null;
              },
            ),

            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                        : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login_rounded),
                            SizedBox(width: 8),
                            Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontSize: 17.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoStrip(BuildContext context) {
    /*
      شريط معلومات أسفل البطاقة.
      يعطي الصفحة شكلًا احترافيًا ويوضح هدف التطبيق.
    */
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'بياناتك محفوظة ويتم التحقق منها عبر النظام المدرسي.',
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppName() {
    /*
      اسم التطبيق أسفل صفحة تسجيل الدخول.
      يظهر بشكل أجمل من النص القديم.
    */
    return const Column(
      children: [
        Text(
          'بوابة مدرستي',
          style: TextStyle(
            color: Color(0xFF2563EB),
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'School Mobile App',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildBackground(BuildContext context, {required Widget child}) {
    /*
      خلفية الصفحة:
      نستخدم ألوان هادئة ودوائر شفافة لإعطاء شكل حديث.
    */
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC), Color(0xFFE0F2FE)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -55,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.13),
              ),
            ),
          ),
          Positioned(
            bottom: -85,
            left: -70,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: 28,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      /*
        لأن التطبيق عربي.
      */
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _buildBackground(
          context,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLogo(context),

                      const SizedBox(height: 20),

                      _buildWelcomeText(),

                      const SizedBox(height: 26),

                      _buildLoginCard(context),

                      const SizedBox(height: 18),

                      _buildInfoStrip(context),

                      const SizedBox(height: 18),

                      _buildAppName(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
