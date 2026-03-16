import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../appTheme.dart';
import '../../services/authService.dart';
import '../../widgets/errorBanner.dart';
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}
class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  int _step = 0;
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  String? _success;
  Future<void> _sendCode() async {
    if (!_emailCtrl.text.contains('@')) { setState(() => _error = 'Enter A Valid Email!'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.forgotPassword(_emailCtrl.text.trim());
      setState(() => _step = 1);
    } catch (e) {
      setState(() => _error = AuthService.handleError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  Future<void> _resetPassword() async {
    if (_codeCtrl.text.length != 6) { setState(() => _error = 'Enter The 6-Digit Code!'); return; }
    if (_passCtrl.text.length < 6) { setState(() => _error = 'Password Must Be At Least 6 Characters!'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.resetPassword(_emailCtrl.text.trim(), _codeCtrl.text.trim(), _passCtrl.text);
      setState(() { _success = 'Password Reset! You Can Now Sign In!'; _step = 2; });
    } catch (e) {
      setState(() => _error = AuthService.handleError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  @override
  void dispose() { _emailCtrl.dispose(); _codeCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF0A0A0F), Color(0xFF0F0F1A)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textSecondary, size: 20)),
              const SizedBox(height: 24),
              const Text('Reset Password', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text(
                _step == 0 ? 'Enter Your Email To Receive A Reset Code' : _step == 1 ? 'Enter The 6-Digit Code + New Password' : 'All Done!',
                style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 40),
              if (_step == 0) ...[
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted, size: 20)),
                ),
              ] else if (_step == 1) ...[
                TextField(
                  controller: _codeCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: 12),
                  decoration: const InputDecoration(hintText: '000000', counterText: '', prefixIcon: Icon(Icons.pin_outlined, color: AppTheme.textMuted, size: 20)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outlined, color: AppTheme.textMuted, size: 20),
                    suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textMuted, size: 20), onPressed: () => setState(() => _obscure = !_obscure)),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.success.withValues(alpha: 0.3))),
                  child: Row(children: [const Icon(Icons.check_circle_rounded, color: AppTheme.success), const SizedBox(width: 10), Expanded(child: Text(_success!, style: const TextStyle(color: AppTheme.success, fontSize: 14)))]),
                ),
              ],
              if (_error != null) ...[const SizedBox(height: 16), ErrorBanner(message: _error!)],
              const SizedBox(height: 28),
              if (_step < 2)
                ElevatedButton(
                  onPressed: _loading ? null : (_step == 0 ? _sendCode : _resetPassword),
                  child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_step == 0 ? 'Send Reset Code' : 'Reset Password'),
                )
              else
                ElevatedButton(onPressed: () => context.go('/auth/login'), child: const Text('Back To Sign In')),
            ],
          ),
        ),
      ),
    ),
  );
}