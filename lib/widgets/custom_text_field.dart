import 'package:flutter/material.dart';

/// CustomTextField - Custom text field widget matching iOS design
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.maxLines,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    // Validate that obscured fields cannot be multiline
    assert(!widget.obscureText || (widget.maxLines == null || widget.maxLines == 1), 
           'Obscured fields cannot be multiline');
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1d1d1e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF7E00),
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText && _isObscured,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        onTap: widget.onTap,
        readOnly: widget.readOnly,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Inter',
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: Colors.white60,
            fontFamily: 'Inter',
            fontSize: 16,
          ),
          prefixIcon: Icon(
            widget.icon,
            color: Colors.white,
            size: 20,
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}