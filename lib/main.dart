import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AfyaHive Login',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E1A64)),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = true;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Subtle Watermark Icons
            ..._buildBackgroundWatermarks(),

            // Main Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Container(
                  width: 380,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1A64), // Deep Purple
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Upper Rounded Section (Dark Purple Content)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Logo and Brand
                            Row(
                              children: [
                                // Logo Placeholder Shape
                                Container(
                                  width: 69,
                                  height: 69,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'images/afyahive_logo.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'afyahive',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      'The ecosystem of smart health',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 15,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Hero Image Placeholder
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: double.infinity,
                                height: 160,
                                color: const Color(
                                  0xFFEADBCE,
                                ), // Adaptive placeholder color
                                child: Image.asset(
                                  'images/login_illustration.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 40,
                                        color: Color.fromARGB(255, 135, 32, 32),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Email Field
                            const Text(
                              'Email Address',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Enter your email',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: Color(0xFF1E1A64),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            const Text(
                              'Password',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: '***************',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFF1E1A64),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: const Color(0xFF1E1A64),
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Lower White Canvas Section inside Card
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: Column(
                          children: [
                            // Remember Me & Forgot Password Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: const Color(0xFF1E1A64),
                                        onChanged: (val) => setState(
                                          () => _rememberMe = val ?? false,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Remember me',
                                      style: TextStyle(
                                        color: Color(0xFF1E1A64),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Color(0xFF1E1A64),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                    0xFFF38200,
                                  ), // Vibrant Orange
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  '[ Login ]',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Divider Row
                            Row(
                              children: [
                                const Expanded(
                                  child: Divider(
                                    color: Colors.grey,
                                    thickness: 0.8,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Divider(
                                    color: Colors.grey,
                                    thickness: 0.8,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Google Button
                            _buildSocialButton(
                              icon: Icons.g_mobiledata_rounded,
                              text: 'Continue with Google',
                              iconColor: const Color.fromARGB(
                                255,
                                244,
                                146,
                                54,
                              ),
                            ),
                            const SizedBox(height: 26),

                            // Apple Button
                            _buildSocialButton(
                              icon: Icons.apple,
                              text: 'Continue with Apple (iOS)',
                              iconColor: Colors.black,
                            ),
                            const SizedBox(height: 24),

                            // Bottom Hint Text
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      color: Color(0xFF1E1A64),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required Color iconColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade300, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: iconColor),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundWatermarks() {
    return [
      Positioned(
        top: 60,
        left: 40,
        child: Icon(
          Icons.healing_outlined,
          size: 64,
          color: Colors.blueGrey.withOpacity(0.04),
        ),
      ),
      Positioned(
        top: 240,
        left: 20,
        child: Icon(
          Icons.biotech_outlined,
          size: 72,
          color: Colors.blueGrey.withOpacity(0.04),
        ),
      ),
      Positioned(
        bottom: 120,
        left: 40,
        child: Icon(
          Icons.science_outlined,
          size: 60,
          color: Colors.blueGrey.withOpacity(0.04),
        ),
      ),
      Positioned(
        top: 140,
        right: 30,
        child: Icon(
          Icons.monitor_heart_outlined,
          size: 68,
          color: Colors.blueGrey.withOpacity(0.04),
        ),
      ),
      Positioned(
        bottom: 260,
        right: 25,
        child: Icon(
          Icons.vaccines_outlined,
          size: 74,
          color: Colors.blueGrey.withOpacity(0.04),
        ),
      ),
    ];
  }
}
