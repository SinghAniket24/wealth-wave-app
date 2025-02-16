import 'package:flutter/material.dart';
import 'package:stocks/main.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _sloganAnimation;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _sloganAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    _navigateToHome();
  }

   _navigateToHome() async {
     await Future.delayed(const Duration(seconds: 3));
     Navigator.pushReplacement(
       context,
       MaterialPageRoute(builder: (context) => const AuthWrapper()), // Ensure MyHomePage is defined correctly
     );
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: WavePainter(),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: _logoScaleAnimation,
                        child: const Icon(
                          Icons.account_balance_wallet,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Wealth Wave',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: const Offset(0, 0),
                        ).animate(_controller),
                        child: const Text(
                          'Your gateway to financial freedom!',
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (_) => _buildDotAnimation()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotAnimation() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double scale = 1.0 + (_controller.value * 0.5);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 12.0,
              height: 12.0,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    Path path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
          size.width * 0.25, size.height * 0.55, size.width * 0.5, size.height * 0.65)
      ..quadraticBezierTo(
          size.width * 0.75, size.height * 0.75, size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
