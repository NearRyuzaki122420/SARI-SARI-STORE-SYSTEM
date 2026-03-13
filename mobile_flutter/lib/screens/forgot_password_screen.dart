import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  String message = '';
  String error = '';
  bool isLoading = false;

  Future<void> submit() async {
    setState(() {
      isLoading = true;
      message = '';
      error = '';
    });

    try {
      final res = await ApiService.forgotPassword(emailController.text.trim());
      setState(() {
        message = res['message'] ?? 'Password reset email sent successfully';
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : submit,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Send Reset Link'),
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(message, style: const TextStyle(color: Colors.green)),
            ],
            if (error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(error, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}