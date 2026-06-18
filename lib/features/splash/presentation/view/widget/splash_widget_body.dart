import 'package:flutter/material.dart';
import 'package:untitled7/core/color/app_colors.dart';

class SplashWidgetBody extends StatefulWidget {
  const SplashWidgetBody({super.key});

  @override
  State<SplashWidgetBody> createState() => _SplashWidgetBodyState();
}

class _SplashWidgetBodyState extends State<SplashWidgetBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // إعداد وحدة التحكم في الأنميشن (تكرار مستمر)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(); // يجعل الأنميشن يعيد نفسه تلقائياً

    // إنشاء تحريك يبدأ من اليسار (-1.0) إلى اليمين (2.0)
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // تنظيف الذاكرة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ShaderMask(
            // تأثير التدرج (شفاف من الأطراف وواضح من المنتصف)
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: [
                  _animation.value - 0.4,
                  _animation.value,
                  _animation.value + 0.4,
                ],
                colors: [
                  AppColors.primary.withOpacity(0.1), // شفاف من اليسار
                  AppColors.primary, // اللون الأصلي في المنتصف
                  AppColors.primary.withOpacity(0.1), // شفاف من اليمين
                ],
              ).createShader(rect);
            },
            child: Text(
              'Druginfo',

              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w400,
                fontFamily: "pacifico",
                // يجب أن يكون اللون هنا أبيض ليعمل الـ ShaderMask بشكل صحيح
                color: Colors.white,
                height: 1.8,
              ),
            ),
          );
        },
      ),
    );
  }
}
