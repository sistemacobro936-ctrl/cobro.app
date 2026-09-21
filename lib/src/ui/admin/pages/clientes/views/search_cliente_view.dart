import 'dart:async';

import 'package:flutter/material.dart';

class SearchClienteView extends StatefulWidget {
  final void Function(String query) onSearch;

  /// Controla el texto desde fuera (por ejemplo para limpiarlo)
  final TextEditingController? controller;

  /// Se llama al tocar la X del campo
  final VoidCallback? onClear;

  const SearchClienteView({
    super.key,
    required this.onSearch,
    this.controller,
    this.onClear,
  });

  @override
  State<SearchClienteView> createState() => _SearchClienteViewState();
}

class _SearchClienteViewState extends State<SearchClienteView> {
  Timer? _debounce;
  late final TextEditingController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () {
        widget.onSearch(value);
      },
    );
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.black.withValues(alpha: .05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller,
        builder: (context, value, _) {
          return TextField(
            controller: _controller,
            onChanged: _onChanged,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, documento...',
              hintStyle: const TextStyle(
                color: Color(0xFF9AA2AF),
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF6F7888),
              ),
              // La X solo aparece cuando hay texto
              suffixIcon: value.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clear,
                      tooltip: 'Limpiar búsqueda',
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Color(0xFF6F7888),
                      ),
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          );
        },
      ),
    );
  }
}
