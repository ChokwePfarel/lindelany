import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../signIn&out/logIn.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedUserType = 'Student';
  bool _confirmDelete = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSuccess = false;

  final List<String> _userTypes = ['Student', 'LandLord', 'Transportation'];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Future<void> _deleteLandlordData(String userId) async {
    final accSnap = await _db
        .collection('Accommodation')
        .where('userId', isEqualTo: userId)
        .get();

    for (final accDoc in accSnap.docs) {
      final imgSnap =
      await _db.collection('Accommodation').doc(accDoc.id).collection('images').get();

      for (final img in imgSnap.docs) {
        await img.reference.delete();
        try {
          await _storage.ref('accommodations/${accDoc.id}/${img.id}').delete();
        } catch (_) {
          debugPrint('Storage file not found, skipping.');
        }
      }
      await accDoc.reference.delete();
    }

    await _db.collection('Users').doc(userId).delete();
  }

  Future<void> _deleteStudentData(String userId) async {
    final sfSnap = await _db
        .collection('StudentForm')
        .where('userId', isEqualTo: userId)
        .get();
    for (final doc in sfSnap.docs) {
      await doc.reference.delete();
    }

    final prodSnap = await _db
        .collection('products')
        .where('userId', isEqualTo: userId)
        .get();
    for (final prod in prodSnap.docs) {
      try {
        final ref = _storage.ref('products/${prod.id}');
        final files = await ref.listAll();
        for (final file in files.items) {
          await file.delete();
        }
      } catch (_) {
        debugPrint('No storage files for product, skipping.');
      }
      await prod.reference.delete();
    }

    await _db.collection('Users').doc(userId).delete();
  }

  Future<void> _deleteTransportationData(String userId) async {
    final vSnap = await _db
        .collection('Vehicle')
        .where('userId', isEqualTo: userId)
        .get();
    for (final doc in vSnap.docs) {
      await doc.reference.delete();
    }

    await _db.collection('Users').doc(userId).delete();
  }


  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_confirmDelete) return;

    setState(() => _isLoading = true);

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = credential.user!;
      final userId = user.uid;

      switch (_selectedUserType) {
        case 'LandLord':
          await _deleteLandlordData(userId);
          break;
        case 'Student':
          await _deleteStudentData(userId);
          break;
        case 'Transportation':
          await _deleteTransportationData(userId);
          break;
      }

      await user.delete();

      if (mounted) setState(() => _isSuccess = true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'wrong-password' || 'invalid-credential' => 'Incorrect password. Please try again.',
        'user-not-found' => 'No account found with this email.',
        'invalid-email' => 'Invalid email address.',
        'too-many-requests' => 'Too many failed attempts. Please try again later.',
        'requires-recent-login' =>
        'For security reasons, please log out and log back in before deleting your account.',
        _ => e.message ?? 'Failed to delete account. Please try again.',
      };
      _showError(message);
    } catch (e) {
      if (!mounted) return;
      _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Delete Account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _isSuccess ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This action is permanent and cannot be undone. '
                        'All your data will be deleted.',
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),


          Text(
            'Account type',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedUserType,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: _userTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _selectedUserType = v!),
          ),
          const SizedBox(height: 20),


          Text(
            'Email address',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'you@example.com',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 20),


          Text(
            'Password',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Your password',
              border: const OutlineInputBorder(),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Confirmation checkbox
          CheckboxListTile(
            value: _confirmDelete,
            onChanged: (v) => setState(() => _confirmDelete = v ?? false),
            title: const Text(
              'I understand this action is permanent and all my data will be permanently deleted.',
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),

          // Delete button
          ElevatedButton(
            onPressed: (_confirmDelete && !_isLoading) ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.red.shade200,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text(
              'Delete My Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),

          //Cancel button
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Icon(Icons.check_circle_outline,
            size: 80, color: Colors.green.shade600),
        const SizedBox(height: 24),
        Text(
          'Account Deleted',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Your account and all associated data have been permanently deleted.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false, );
          },
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}