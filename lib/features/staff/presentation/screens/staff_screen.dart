import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDepartment = 'All';
  final List<String> _departments = ['All', 'Sales', 'Support', 'Admin', 'Warehouse'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Inactive'),
            Tab(text: 'Roles'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleMenuAction(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.upload_file, size: 20),
                    SizedBox(width: 8),
                    Text('Import Staff'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Export List'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStaffList(true),
          _buildStaffList(false),
          _buildRolesTab(),
        ],
      ),
      floatingActionButton: _tabController.index != 2
          ? FloatingActionButton(
              onPressed: _addNewStaff,
              child: const Icon(Icons.person_add),
            )
          : FloatingActionButton(
              onPressed: _addNewRole,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildStaffList(bool isActive) {
    return Column(
      children: [
        // Department Filter
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _departments.length,
            itemBuilder: (context, index) {
              final department = _departments[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(department),
                  selected: _selectedDepartment == department,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDepartment = department;
                    });
                  },
                ),
              );
            },
          ),
        ),
        
        // Staff Grid/List
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: isActive ? 12 : 5,
            itemBuilder: (context, index) {
              return Card(
                child: InkWell(
                  onTap: () => _showStaffDetails(context, index, isActive),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: _getDepartmentColor(index % 4),
                          child: Text(
                            _getInitials(index),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Flexible(
                          child: Text(
                            'Staff ${index + 1}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Flexible(
                          child: Text(
                            _getDepartmentName(index % 4),
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Flexible(
                          child: Chip(
                            label: Text(
                              _getRole(index % 3),
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.phone, size: 20),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Calling staff member...'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.email, size: 20),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Opening email...'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                isActive ? Icons.block : Icons.check_circle,
                                size: 20,
                                color: isActive ? Colors.red : Colors.green,
                              ),
                              onPressed: () {
                                _toggleStaffStatus(index, isActive);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRolesTab() {
    final roles = [
      {'name': 'Administrator', 'permissions': 15, 'users': 2},
      {'name': 'Manager', 'permissions': 12, 'users': 3},
      {'name': 'Sales Rep', 'permissions': 8, 'users': 5},
      {'name': 'Support Agent', 'permissions': 6, 'users': 4},
      {'name': 'Warehouse Staff', 'permissions': 4, 'users': 3},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.security,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              role['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${role['permissions']} permissions',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  '${role['users']} users assigned',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editRole(role['name'] as String),
            ),
            onTap: () => _showRoleDetails(context, role),
          ),
        );
      },
    );
  }

  String _getInitials(int index) {
    final names = ['JD', 'AS', 'MK', 'RT', 'LP', 'CD', 'BW', 'KM', 'TH', 'SG', 'NP', 'EL'];
    return names[index % names.length];
  }

  String _getDepartmentName(int index) {
    switch (index) {
      case 0:
        return 'Sales';
      case 1:
        return 'Support';
      case 2:
        return 'Admin';
      case 3:
        return 'Warehouse';
      default:
        return 'General';
    }
  }

  Color _getDepartmentColor(int index) {
    switch (index) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getRole(int index) {
    switch (index) {
      case 0:
        return 'Manager';
      case 1:
        return 'Representative';
      case 2:
        return 'Assistant';
      default:
        return 'Staff';
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Staff'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter name or email',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Searching...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'import':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Import staff from file'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export staff list'),
            duration: Duration(seconds: 1),
          ),
        );
        break;
    }
  }

  void _addNewStaff() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Staff',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Department',
                prefixIcon: Icon(Icons.business),
              ),
              items: _departments
                  .where((dept) => dept != 'All')
                  .map((dept) => DropdownMenuItem(
                        value: dept,
                        child: Text(dept),
                      ))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Role',
                prefixIcon: Icon(Icons.security),
              ),
              items: ['Manager', 'Representative', 'Assistant']
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Staff member added'),
                        ),
                      );
                    },
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _addNewRole() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Role Name',
                hintText: 'e.g., Supervisor',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Brief description of the role',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Role created'),
                ),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showStaffDetails(BuildContext context, int index, bool isActive) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: _getDepartmentColor(index % 4),
              child: Text(
                _getInitials(index),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Staff ${index + 1}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(isActive ? 'Active' : 'Inactive'),
              backgroundColor: isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(
                'staff${index + 1}@company.com',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone'),
              subtitle: Text(
                '+1 234 567 89${index.toString().padLeft(2, '0')}',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Department'),
              subtitle: Text(
                _getDepartmentName(index % 4),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('Role'),
              subtitle: Text(
                _getRole(index % 3),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Joined'),
              subtitle: Text(
                DateTime.now().subtract(Duration(days: index * 30)).toString().split(' ')[0],
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _toggleStaffStatus(index, isActive);
                  },
                  icon: Icon(
                    isActive ? Icons.block : Icons.check_circle,
                    color: isActive ? Colors.red : Colors.green,
                  ),
                  label: Text(
                    isActive ? 'Deactivate' : 'Activate',
                    style: TextStyle(
                      color: isActive ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleDetails(BuildContext context, Map<String, dynamic> role) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              role['name'] as String,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Permissions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'View Invoices',
                'Create Invoices',
                'Edit Customers',
                'View Reports',
                'Manage Inventory',
              ]
                  .map((permission) => Chip(
                        label: Text(
                          permission, 
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Assigned Users'),
              subtitle: Text(
                '${role['users']} users',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _editRole(role['name'] as String);
                    },
                    child: const Text('Edit Role'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleStaffStatus(int index, bool currentlyActive) {
    final action = currentlyActive ? 'deactivated' : 'activated';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Staff member $action'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _editRole(String roleName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit role: $roleName'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}