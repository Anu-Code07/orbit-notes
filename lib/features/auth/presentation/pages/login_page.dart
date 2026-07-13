import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:orbit_notes/core/di/injection.dart';
import 'package:orbit_notes/core/prefs/app_prefs.dart';
import 'package:orbit_notes/core/theme/app_colors.dart';
import 'package:orbit_notes/core/theme/app_spacing.dart';
import 'package:orbit_notes/core/widgets/orbit_button.dart';
import 'package:orbit_notes/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:orbit_notes/features/auth/presentation/widgets/auth_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter email and password.')),
      );
      return;
    }
    context.read<AuthBloc>().add(
          AuthSignInWithEmailRequested(email: email, password: password),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is AuthAuthenticated) {
          await getIt<AppPrefs>().markAuthGateCompleted();
          if (context.mounted) context.go('/');
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;

        return AuthScaffold(
          accent: AuthAccent.coral,
          heroMark: '01',
          headline: 'Welcome back',
          subcopy:
              'Pick up where the last trip left off. Your days stay on this device — the cloud just keeps them close.',
          form: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                ),
                SizedBox(height: spacing.md),
                AuthField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => _submit(),
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: colors.muted,
                    ),
                  ),
                ),
                SizedBox(height: spacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: OrbitButton(
                    label: 'Sign in',
                    expand: true,
                    onPressed: loading ? null : _submit,
                    isLoading: loading,
                  ),
                ),
                SizedBox(height: spacing.md),
                const AuthDivider(),
                SizedBox(height: spacing.md),
                SizedBox(
                  width: double.infinity,
                  child: OrbitButton(
                    label: 'Continue with Google',
                    expand: true,
                    variant: OrbitButtonVariant.secondary,
                    icon: Icons.north_east_rounded,
                    onPressed: loading
                        ? null
                        : () => context.read<AuthBloc>().add(
                              const AuthSignInWithGoogleRequested(),
                            ),
                  ),
                ),
              ],
            ),
          ),
          footer: Column(
            children: [
              Text.rich(
                TextSpan(
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: colors.body,
                  ),
                  children: [
                    const TextSpan(text: 'New here? '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: GestureDetector(
                        onTap: loading ? null : () => context.go('/signup'),
                        child: Text(
                          'Create an account',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.ink,
                            decoration: TextDecoration.underline,
                            decorationColor:
                                colors.ink.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing.sm),
              TextButton(
                onPressed: loading
                    ? null
                    : () async {
                        await getIt<AppPrefs>().markAuthGateCompleted();
                        if (context.mounted) context.go('/');
                      },
                child: Text(
                  'Continue offline',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: colors.muted,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
