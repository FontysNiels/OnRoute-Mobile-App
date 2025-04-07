import 'package:flutter/material.dart';

import '../../Tabs/material_design_indicator.dart';

class PackageTabs extends StatefulWidget {
  final Function setIndex;
  final bool isPackage;
  const PackageTabs({
    super.key,
    required this.setIndex,
    required this.isPackage,
  });

  @override
  State<PackageTabs> createState() => _PackageTabsState();
}

class _PackageTabsState extends State<PackageTabs>
    with TickerProviderStateMixin {
  late TabController _tabController;

  void _handleTabSelection() {
    widget.setIndex(_tabController.index);
  }

  late final List<Tab> _tabs = widget.isPackage
      ? [
          Tab(text: 'Beschrijving'),
          Tab(text: 'POIs'),
          Tab(text: 'Routes'),
        ]
      : [
          Tab(text: 'Beschrijving'),
          Tab(text: 'POIs'),
        ];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    widget.setIndex(0);
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryAccent =
        Theme.of(context).colorScheme.primary; // Get primaryAccent from theme

    return DecoratedBox(
      decoration: BoxDecoration(
        //This is for bottom border that is needed
        border: Border(bottom: BorderSide(color: Colors.black, width: 1.6)),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: MaterialDesignIndicator(
          indicatorHeight: 4,
          indicatorColor: primaryAccent, // Use primaryAccent color
        ),
        tabs: _tabs,
      ),
    );
  }
}
