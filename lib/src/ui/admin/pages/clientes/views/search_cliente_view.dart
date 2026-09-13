import 'dart:async';

import 'package:flutter/material.dart';

class SearchClienteView extends StatefulWidget {
  final void Function(String query) onSearch;

  const SearchClienteView({
    super.key,
    required this.onSearch,
  });

  @override
  State<SearchClienteView> createState() => _SearchClienteViewState();
}

class _SearchClienteViewState extends State<SearchClienteView> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
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
      child: TextField(
        onChanged: _onChanged,
        decoration: const InputDecoration(
          hintText: 'Buscar por nombre, documento...',
          hintStyle: TextStyle(
            color: Color(0xFF9AA2AF),
            fontSize: 13,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Color(0xFF6F7888),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: 15,
          ),
        ),
      ),
    );
  }
}