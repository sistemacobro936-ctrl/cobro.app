import 'package:flutter/material.dart';
import 'package:personal/src/common/theme/theme.dart';
import 'package:personal/src/ui/widgets/widgets.dart';

/// Formulario de cambio de contraseña, compartido por "Mi perfil" (cambiar
/// la propia) y "Editar cobrador" (un admin cambiando la de un cobrador de
/// su negocio). Quien llama resuelve el envío: PATCH /credencial/cambiar-password.
void mostrarDialogoCambiarPassword(
  BuildContext context, {
  required String titulo,
  required String subtitulo,
  required void Function(String nuevaPassword) onConfirmar,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FormularioCambiarPassword(
      titulo: titulo,
      subtitulo: subtitulo,
      onConfirmar: onConfirmar,
    ),
  );
}

class _FormularioCambiarPassword extends StatefulWidget {
  final String titulo;
  final String subtitulo;
  final void Function(String nuevaPassword) onConfirmar;

  const _FormularioCambiarPassword({
    required this.titulo,
    required this.subtitulo,
    required this.onConfirmar,
  });

  @override
  State<_FormularioCambiarPassword> createState() =>
      _FormularioCambiarPasswordState();
}

class _FormularioCambiarPasswordState
    extends State<_FormularioCambiarPassword> {
  final _passwordController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _verPassword = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  void _confirmar() {
    final password = _passwordController.text;

    if (password.length < 8) {
      setState(() => _error = 'Debe tener mínimo 8 caracteres');
      return;
    }
    if (password != _confirmarController.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }

    Navigator.pop(context);
    widget.onConfirmar(password);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.titulo,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.subtitulo,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF929BAB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              InputWidget.input(
                label: 'Nueva contraseña',
                hintText: 'Mínimo 8 caracteres',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _passwordController,
                obscureText: !_verPassword,
                suffixIcon: _verPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                onSuffixPressed: () =>
                    setState(() => _verPassword = !_verPassword),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),
              const SizedBox(height: 14),

              InputWidget.input(
                label: 'Confirmar contraseña',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _confirmarController,
                obscureText: !_verPassword,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
              ),

              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ],

              const SizedBox(height: 22),

              BtnWidget.btn(
                text: 'Cambiar contraseña',
                icon: Icons.check_rounded,
                onPressed: _confirmar,
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
