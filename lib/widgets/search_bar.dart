import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String) onChanged;
  final EdgeInsetsGeometry? margin;

  const CustomSearchBar({
    Key? key,
    required this.hintText,
    required this.onChanged,
    this.margin,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.indigo),
      ),
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          setState(() {});
          widget.onChanged(value);
        },
        style: GoogleFonts.poppins(
          fontSize: 15,
          color: Colors.indigo[800],
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.grey[400],
            height: 1.5,
          ),
          prefixIcon: Container(
            padding: EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              color: Colors.indigo,
              size: 22,
            ),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: _clearSearch,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
        ),
      ),
    );
  }
}
