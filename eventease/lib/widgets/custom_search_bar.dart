import 'package:flutter/material.dart';
import 'package:eventease/theme/app_theme.dart';
import 'package:eventease/utils/animations.dart';
import 'package:eventease/widgets/shimmer_loading.dart';

class CustomSearchBar extends StatefulWidget {
  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final List<String> suggestions;
  final ValueChanged<String>? onSuggestionSelected;
  final bool showSuggestions;
  final bool autoFocus;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool showLeading;
  final Widget? leading;
  final Widget? trailing;
  final bool animated;
  final SearchBarStyle style;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final double elevation;

  const CustomSearchBar({
    super.key,
    this.hint = 'Search',
    this.onChanged,
    this.onClear,
    this.suggestions = const [],
    this.onSuggestionSelected,
    this.showSuggestions = true,
    this.autoFocus = false,
    this.controller,
    this.focusNode,
    this.showLeading = true,
    this.leading,
    this.trailing,
    this.animated = true,
    this.style = SearchBarStyle.outlined,
    this.backgroundColor,
    this.padding,
    this.elevation = 0,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showClear = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _controller.addListener(_handleTextChange);
    _focusNode.addListener(_handleFocusChange);

    if (widget.autoFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (_showClear != hasText) {
      setState(() => _showClear = hasText);
    }
    widget.onChanged?.call(_controller.text);
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    Widget searchBar = Container(
      padding: widget.padding ?? const EdgeInsets.all(8),
      decoration: _getDecoration(),
      child: Row(
        children: [
          if (widget.showLeading)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: widget.leading ??
                  Icon(
                    Icons.search_rounded,
                    color: _isFocused ? AppTheme.primaryColor : Colors.grey[600],
                  ),
            ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: widget.hint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          if (_showClear)
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: _handleClear,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              iconSize: 20,
              color: Colors.grey[600],
            )
          else if (widget.trailing != null)
            widget.trailing!,
        ],
      ),
    );

    if (widget.animated) {
      searchBar = AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: searchBar,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        searchBar,
        if (widget.showSuggestions && _isFocused && _showClear)
          _buildSuggestions(),
      ],
    );
  }

  Widget _buildSuggestions() {
    if (widget.suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedWidget(
      fadeIn: true,
      slide: true,
      slideOffset: const Offset(0, -0.1),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: widget.suggestions.length,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final suggestion = widget.suggestions[index];
            return InkWell(
              onTap: () {
                _controller.text = suggestion;
                _focusNode.unfocus();
                widget.onSuggestionSelected?.call(suggestion);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    switch (widget.style) {
      case SearchBarStyle.outlined:
        return BoxDecoration(
          color: widget.backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isFocused
                ? AppTheme.primaryColor
                : Colors.grey.withOpacity(0.3),
            width: 1.5,
          ),
        );
      case SearchBarStyle.filled:
        return BoxDecoration(
          color: widget.backgroundColor ?? Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        );
      case SearchBarStyle.material:
        return BoxDecoration(
          color: widget.backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: widget.elevation * 2,
              offset: Offset(0, widget.elevation),
            ),
          ],
        );
    }
  }
}

enum SearchBarStyle {
  outlined,
  filled,
  material,
}

// Searchable List
class SearchableList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final String Function(T item) searchQuery;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final bool showSearchBar;
  final String? searchHint;
  final bool animated;

  const SearchableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.searchQuery,
    this.emptyWidget,
    this.loadingWidget,
    this.showSearchBar = true,
    this.searchHint,
    this.animated = true,
  });

  @override
  State<SearchableList<T>> createState() => _SearchableListState<T>();
}

class _SearchableListState<T> extends State<SearchableList<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) {
        return widget.searchQuery(item).toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showSearchBar)
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomSearchBar(
              controller: _searchController,
              hint: widget.searchHint ?? 'Search',
              style: SearchBarStyle.filled,
              animated: widget.animated,
            ),
          ),
        Expanded(
          child: _filteredItems.isEmpty
              ? widget.emptyWidget ??
                  const Center(
                    child: Text('No items found'),
                  )
              : ListView.builder(
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    Widget itemWidget = widget.itemBuilder(item);

                    if (widget.animated) {
                      itemWidget = AnimatedWidget(
                        fadeIn: true,
                        slide: true,
                        slideOffset: const Offset(0, 0.1),
                        delay: Duration(milliseconds: index * 50),
                        child: itemWidget,
                      );
                    }

                    return itemWidget;
                  },
                ),
        ),
      ],
    );
  }
}
