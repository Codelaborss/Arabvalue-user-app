import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class SectionTabBar extends StatefulWidget {
  final List<String> sections;
  final Function(int index) onTabTap;
  final ScrollController scrollController;
  final int initialIndex;

  const SectionTabBar({
    super.key,
    required this.sections,
    required this.onTabTap,
    required this.scrollController,
    this.initialIndex = -1,
  });

  @override
  State<SectionTabBar> createState() => _SectionTabBarState();
}

class _SectionTabBarState extends State<SectionTabBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.only(top: 8, left: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.sections.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                widget.onTabTap(index);
              },
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.sections[index],
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
