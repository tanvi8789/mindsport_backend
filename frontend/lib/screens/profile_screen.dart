import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';
import '../services/auth_service.dart'; // We use this for saving

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService(); // Keep instance for saving

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _sportController;
  late TextEditingController _ageController;
  late TextEditingController _heightController; // Was late
  late TextEditingController _weightController; // Was late
  String? _selectedGender;

  bool _isDirty = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Get the initial user data from the provider
    final user = Provider.of<UserProvider>(context, listen: false).user;

    // Initialize all controllers
    _nameController = TextEditingController(text: user?.name ?? '');
    _sportController = TextEditingController(text: user?.sport ?? '');
    _ageController = TextEditingController(text: user?.age?.toString() ?? '');
    // --- THIS IS THE FIX ---
    // Uncomment these lines to initialize the controllers
    _heightController = TextEditingController(text: user?.height?.toString() ?? '');
    _weightController = TextEditingController(text: user?.weight?.toString() ?? '');
    // --- END OF FIX ---
    _selectedGender = user?.gender;

    // Add listeners AFTER initialization
    _nameController.addListener(_onChanged);
    _sportController.addListener(_onChanged);
    _ageController.addListener(_onChanged);
    _heightController.addListener(_onChanged);
    _weightController.addListener(_onChanged);
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
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // Basic validation before saving
    if (!_formKey.currentState!.validate()) {
      return; // Don't proceed if form is invalid
    }

    setState(() { _isLoading = true; });

    // Prepare the update data payload
    final updates = <String, dynamic>{
      'name': _nameController.text.trim(),
      'sport': _sportController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()),
      'height': int.tryParse(_heightController.text.trim()), // Now included
      'weight': int.tryParse(_weightController.text.trim()), // Now included
      'gender': _selectedGender,
    };

    // Remove null/empty values so we only send actual changes
    updates.removeWhere((key, value) => value == null || (value is String && value.isEmpty));

    // Call the AuthService to update the profile via API
    final success = await _authService.updateUserProfile(updates);

    if (mounted) {
      // Refresh user data in the provider AFTER saving
      await Provider.of<UserProvider>(context, listen: false).fetchUserData();

      setState(() {
        _isLoading = false;
        _isDirty = false; // Reset dirty flag after successful save
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? "Profile saved!" : "Failed to save profile."),
          backgroundColor: success ? const Color(0xFFD5DABA) : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // You can optionally wrap this Scaffold with Consumer<UserProvider>
    // if you want parts of the UI to update automatically when data changes.
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0EC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFBAC0DA), // Lavender-ish
            pinned: true,
            expandedHeight: 150.0,
            iconTheme: const IconThemeData(color: Colors.black54), // Darker icon for contrast
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('My Profile', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFBAC0DA), Color(0xFFD0E7E7)], // Lavender to light turquoise
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInfoCard(
                        title: 'Personal Details',
                        icon: Icons.person_search,
                        color: const Color(0xFFF3CEB3), // Orange-ish
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
                    const SizedBox(height: 24),
                    _buildInfoCard(
                        title: 'Athletic Details',
                        icon: Icons.fitness_center,
                        color: const Color(0xFFDABABA), // Solkadi color
                        children: [
                          _buildTextField(_sportController, 'Primary Sport'),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // These fields are now connected
                              Expanded(child: _buildTextField(_heightController, 'Height (cm)', isNumber: true)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField(_weightController, 'Weight (kg)', isNumber: true)),
                            ],
                          ),
                        ]
                    ),
                    const SizedBox(height: 30),
                    // Show save button only if changes were made
                    if (_isDirty)
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD5DABA), // Sage green
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 4,
                          shadowColor: Colors.black38,
                        ),
                        child: const Text('Save Changes', style: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold)),
                      )
                  ],
                ),
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
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.4), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.black54),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
                ],
              ),
              const Divider(height: 24, thickness: 0.5),
              ...children,
            ],
          ),
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
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (label == 'Name' && (value == null || value.isEmpty)) {
          return 'Name cannot be empty';
        }
        // Optional: Add validation for number fields if needed
        if (isNumber && value != null && value.isNotEmpty && int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
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
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
      items: ["Male", "Female", "Other", "Prefer not to say"]
          .map((label) => DropdownMenuItem(
        child: Text(label, overflow: TextOverflow.ellipsis),
        value: label,
      ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedGender = value;
            _onChanged(); // Mark form as dirty when gender changes
          });
        }
      },
    );
  }
}
