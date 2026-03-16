import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../appTheme.dart';
import '../../providers/authProvider.dart';
import '../../services/authService.dart';
import '../../widgets/errorBanner.dart';
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});
  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}
class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _loading = false;
  bool _codeSent = false;
  String? _error;
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authProvider.notifier).register(_emailCtrl.text.trim(), _passCtrl.text);
      setState(() => _codeSent = true);
    } catch (e) {
      setState(() => _error = AuthService.handleError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  Future<void> _verify() async {
    if (_codeCtrl.text.length != 6) { setState(() => _error = 'Enter The 6-Digit Code!'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authProvider.notifier).verifyEmail(_emailCtrl.text.trim(), _codeCtrl.text.trim());
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = AuthService.handleError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); _codeCtrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF0A0A0F), Color(0xFF0A0F1A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textSecondary, size: 20),
                ),
                const SizedBox(height: 24),
                const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                const Text('Start Your Kanji Learning Journey', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                const SizedBox(height: 40),
                if (!_codeSent) ...[
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted, size: 20)),
                    validator: (v) => v == null || !v.contains('@') ? 'Enter A Valid Email' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Password (Min 6 Chars)',
                      prefixIcon: const Icon(Icons.lock_outlined, color: AppTheme.textMuted, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textMuted, size: 20),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => v == null || v.length < 6 ? 'Min 6 Characters' : null,
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.email_rounded, color: AppTheme.success, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text('Code Sent To ${_emailCtrl.text}', style: const TextStyle(color: AppTheme.success, fontSize: 14))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: 12),
                    decoration: const InputDecoration(hintText: '000000', counterText: '', prefixIcon: Icon(Icons.pin_outlined, color: AppTheme.textMuted, size: 20)),
                  ),
                ],
                if (_error != null) ...[const SizedBox(height: 16), ErrorBanner(message: _error!)],
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _loading ? null : (_codeSent ? _verify : _register),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_codeSent ? 'Verify Code' : 'Create Account'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already Have An Account? ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    GestureDetector(onTap: () => context.pop(), child: const Text('Sign In', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600, fontSize: 14))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}