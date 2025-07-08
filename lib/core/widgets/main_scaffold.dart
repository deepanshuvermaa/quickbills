import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_drawer.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  
  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  
  final List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      icon: Icons.point_of_sale,
      label: 'Billing',
      route: '/billing',
    ),
    _NavigationItem(
      icon: Icons.inventory_2,
      label: 'Inventory',
      route: '/inventory',
    ),
    _NavigationItem(
      icon: Icons.people,
      label: 'Customers',
      route: '/customers',
    ),
    _NavigationItem(
      icon: Icons.analytics,
      label: 'Reports',
      route: '/reports',
    ),
    _NavigationItem(
      icon: Icons.settings,
      label: 'Settings',
      route: '/settings',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String location = GoRouterState.of(context).uri.path;
    _selectedIndex = _navigationItems.indexWhere(
      (item) => location.startsWith(item.route),
    );
    if (_selectedIndex == -1) _selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    if (isTablet) {
      return Scaffold(
        drawer: const AppDrawer(),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
                context.go(_navigationItems[index].route);
              },
              labelType: NavigationRailLabelType.all,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              destinations: _navigationItems
                  .map((item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.icon, color: Theme.of(context).primaryColor),
                        label: Text(item.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: widget.child),
          ],
        ),
      );
    }
    
    return Scaffold(
      drawer: const AppDrawer(),
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          context.go(_navigationItems[index].route);
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 60,
        destinations: _navigationItems
            .map((item) => NavigationDestination(
                  icon: Icon(item.icon, size: 20),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;
  final String route;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}