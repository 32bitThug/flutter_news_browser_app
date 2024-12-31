import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategoryTap;
  const NavBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryTap,
  });

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  void didUpdateWidget(NavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategory != oldWidget.selectedCategory) {
      build(context);
    }
  }

  String capitalize(String text) {
    if (text.isEmpty) {
      return text;
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    //  debugPrint('cat${widget.selectedCategory.toString()}');
    return Expanded(
      child: Container(
        color: Colors.white, // Light blue shade color
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.categories.map((category) {
              final isSelected = category == widget.selectedCategory ||
                  (widget.selectedCategory.isEmpty && category == "Home Feeds");

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => widget.onCategoryTap(category),
                  child: Text(
                    capitalize(category),
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.blue : Colors.black,
                      decoration: isSelected ? TextDecoration.underline : null,
                      decorationColor: isSelected ? Colors.blue : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
