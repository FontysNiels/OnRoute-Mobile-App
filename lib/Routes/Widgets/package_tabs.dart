import 'package:flutter/material.dart';

import '../material_design_indicator.dart';

class PackageTabs extends StatefulWidget {
  const PackageTabs({super.key});

  @override
  State<PackageTabs> createState() => _PackageTabsState();
}

class _PackageTabsState extends State<PackageTabs>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      print('Tab changed to: ${_tabController.index}');
    }
  }

  final _tabs = [
    Tab(text: 'Beschrijving'),
    Tab(text: 'POIs'),
    Tab(text: 'Routes'),
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
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryAccent =
        Theme.of(context).colorScheme.primary; // Get primaryAccent from theme

    return TabBar(
      controller: _tabController,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: MaterialDesignIndicator(
        indicatorHeight: 4,
        indicatorColor: primaryAccent, // Use primaryAccent color
      ),
      tabs: _tabs,
    );
  }
}
