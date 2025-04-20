import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test/utils/search_history_helper.dart';

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
  List<String> _searchHistory = [];
  bool _isDropdownOpen = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    setState(() => _isLoading = true);
    try {
      _searchHistory = await SearchHistoryHelper.getSearchHistory();
    } catch (e) {
      print('Error loading search history: $e');
      _searchHistory = [];
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleDropdown() async {
    if (!_isDropdownOpen) {
      await _loadSearchHistory(); // Tải lại lịch sử mỗi khi mở dropdown
    }
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged('');
    setState(() {
      _isDropdownOpen = false;
    });
  }

  void _onSubmitted(String value) async {
    if (value.trim().isNotEmpty) {
      await SearchHistoryHelper.addSearchQuery(value);
      await _loadSearchHistory();
    }
    setState(() {
      _isDropdownOpen = false;
    });
  }

  void _selectHistoryItem(String query) {
    _controller.text = query;
    widget.onChanged(query);
    setState(() {
      _isDropdownOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
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
            onSubmitted: _onSubmitted,
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
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: _toggleDropdown,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        _isDropdownOpen
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: Colors.indigo,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
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
        ),
        if (_isDropdownOpen)
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            margin: widget.margin?.add(EdgeInsets.only(top: 4)),
            constraints: BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: _isLoading
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : _searchHistory.isEmpty
                    ? ListTile(
                        dense: true,
                        title: Text(
                          'Không có lịch sử tìm kiếm',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _searchHistory.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.history,
                              color: Colors.grey[600],
                              size: 18,
                            ),
                            title: Text(
                              _searchHistory[index],
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.close, size: 16),
                              onPressed: () async {
                                await SearchHistoryHelper.removeSearchQuery(
                                    _searchHistory[index]);
                                await _loadSearchHistory();
                              },
                            ),
                            onTap: () =>
                                _selectHistoryItem(_searchHistory[index]),
                          );
                        },
                      ),
          ),
      ],
    );
  }
}
