import 'package:material_ui/material_ui.dart';

typedef AuthSubmit = void Function({required String email, String? name});

// Shared layout for sign in and sign up. Any email and a 6+ character password works.
class AuthForm extends StatefulWidget {
  const AuthForm({
    required this.title,
    required this.message,
    required this.submitLabel,
    required this.onSubmit,
    this.askName = false,
    this.initialEmail = '',
    this.initialPassword = '',
    this.footer,
    super.key,
  });

  final String title;
  final String message;
  final String submitLabel;
  final AuthSubmit onSubmit;
  final bool askName;
  final String initialEmail;
  final String initialPassword;
  final Widget? footer;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  late final _email = TextEditingController(text: widget.initialEmail);
  late final _password = TextEditingController(text: widget.initialPassword);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    widget.onSubmit(email: _email.text, name: widget.askName ? _name.text : null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Icon(Icons.graphic_eq_rounded, size: 44, color: theme.colorScheme.primary),
              const SizedBox(height: 20),
              Text(widget.title, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                widget.message,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              if (widget.askName) ...[
                TextFormField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                ),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _password,
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                decoration: const InputDecoration(labelText: 'Password'),
                onFieldSubmitted: (_) => _submit(),
                validator: (v) => (v == null || v.length < 6) ? 'Use at least 6 characters' : null,
              ),
              const SizedBox(height: 28),
              FilledButton(onPressed: _submit, child: Text(widget.submitLabel)),
              if (widget.footer != null) ...[const SizedBox(height: 12), Center(child: widget.footer)],
            ],
          ),
        ),
      ),
    );
  }
}
