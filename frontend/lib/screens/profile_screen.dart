import 'package:flutter/material.dart';
import 'package:mindsport/models/user_model.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';
import '../services/auth_service.dart';
import 'package:mindsport/main.dart'; // Import theme

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _sportController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String? _selectedGender;

  bool _isDirty = false;
  bool _isLoading = false;

  // --- ANIMATION ---
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;

    // Initialize all controllers
    _nameController = TextEditingController(text: user?.name ?? '');
    _sportController = TextEditingController(text: user?.sport ?? '');
    _ageController = TextEditingController(text: user?.age?.toString() ?? '');
    _heightController = TextEditingController(text: user?.height?.toString() ?? '');
    _weightController = TextEditingController(text: user?.weight?.toString() ?? '');
    _selectedGender = user?.gender;

    // Add listeners
    _nameController.addListener(_onChanged);
    _sportController.addListener(_onChanged);
    _ageController.addListener(_onChanged);
    _heightController.addListener(_onChanged);
    _weightController.addListener(_onChanged);

    // --- ANIMATION SETUP ---
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    );
    _animationController.forward();
  }

  void _onChanged() {
    if (!_isDirty) {
      setState(() {
        _isDirty = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sportController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    final updates = <String, dynamic>{
      'name': _nameController.text.trim(),
      'sport': _sportController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()),
      'height': int.tryParse(_heightController.text.trim()),
      'weight': int.tryParse(_weightController.text.trim()),
      'gender': _selectedGender,
    };

    updates.removeWhere((key, value) => value == null || (value is String && value.isEmpty));

    final success = await _authService.updateUserProfile(updates);

    if (mounted) {
      await Provider.of<UserProvider>(context, listen: false).fetchUserData();

      setState(() {
        _isLoading = false;
        _isDirty = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Profile saved!" : "Failed to save profile."),
          backgroundColor: success ? MindSportTheme.primaryGreen : Colors.red,
        ),
      );
    }
  }

  // Placeholder function for image picking
  void _pickImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image picker would open here (Requires image_picker package)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      extendBodyBehindAppBar: true, // Let background show through app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Profile'),
        iconTheme: const IconThemeData(color: MindSportTheme.darkText),
      ),
      body: Stack(
        children: [
          // --- 1. ABSTRACT BACKGROUND ---
          CustomPaint(
            painter: _BackgroundPainter(),
            size: Size.infinite,
          ),

          // --- 2. CONTENT ---
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 40), // Top padding for AppBar
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // --- PROFILE PICTURE SECTION ---
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.0,
                    child: Center(
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4), // Border width
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white, // Border color
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: MindSportTheme.softLavender,
                              // If we had a photo URL, we'd use NetworkImage here
                              // backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                              child: Text(
                                user?.name.substring(0, 1).toUpperCase() ?? 'A',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: MindSportTheme.primaryGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- PERSONAL DETAILS CARD ---
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.1,
                    child: _buildInfoCard(
                        title: 'Personal Details',
                        icon: Icons.person_outline,
                        color: MindSportTheme.softPeach,
                        children: [
                          _buildTextField(_nameController, 'Name'),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildTextField(_ageController, 'Age', isNumber: true)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildGenderDropdown()),
                            ],
                          ),
                        ]
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- ATHLETIC DETAILS CARD ---
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.2,
                    child: _buildInfoCard(
                        title: 'Athletic Stats',
                        icon: Icons.fitness_center_outlined,
                        color: MindSportTheme.softGreen,
                        children: [
                          _buildTextField(_sportController, 'Primary Sport'),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _buildTextField(_heightController, 'Height (cm)', isNumber: true)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField(_weightController, 'Weight (kg)', isNumber: true)),
                            ],
                          ),
                        ]
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- SAVE BUTTON ---
                  _FadeInSlide(
                    animation: _fadeAnimation,
                    delay: 0.3,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _isDirty ? 1.0 : 0.0, // Hide if nothing changed
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MindSportTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 4,
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Save Changes'),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildInfoCard({required String title, required IconData icon, required Color color, required List<Widget> children}) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.85), // Translucent theme color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: MindSportTheme.darkText, size: 22),
                const SizedBox(width: 12),
                Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MindSportTheme.darkText
                    )
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        fillColor: Colors.white.withOpacity(0.6), // Slightly transparent white input
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (label == 'Name' && (value == null || value.isEmpty)) return 'Required';
        return null;
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      isExpanded: true,
      hint: const Text('Gender'),
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: const TextStyle(color: Colors.black54),
        fillColor: Colors.white.withOpacity(0.6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: ["Male", "Female", "Other", "Prefer not to say"]
          .map((label) => DropdownMenuItem(
        value: label,
        child: Text(label, overflow: TextOverflow.ellipsis),
      )).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedGender = value;
            _onChanged();
          });
        }
      },
    );
  }
}

// --- Background Painter (Reused) ---
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double blurSigma = 45.0;
    final paint1 = Paint()..color = MindSportTheme.softPeach.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);
    final paint2 = Paint()..color = MindSportTheme.softLavender.withOpacity(0.6)..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);
    final paint3 = Paint()..color = MindSportTheme.softGreen.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, blurSigma);

    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.1), 150, paint1);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.3), 200, paint2);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 180, paint3);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- Animation Widget (Reused) ---
class _FadeInSlide extends StatelessWidget {
  final Animation<double> animation;
  final double delay;
  final Widget child;

  const _FadeInSlide({required this.animation, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(delay, (delay + 0.5).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1.0 - curvedAnimation.value) * 30),
          child: Opacity(opacity: curvedAnimation.value, child: child),
        );
      },
      child: child,
    );
  }
}