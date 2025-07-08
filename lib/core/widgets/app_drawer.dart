import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/subscriptions/presentation/providers/subscription_provider.dart';
import '../../features/subscriptions/data/models/subscription_status_model.dart';
import '../themes/app_theme.dart';
import '../providers/theme_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final subscriptionState = ref.watch(subscriptionStatusProvider);
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context, authState, subscriptionState),
          _buildProfileSection(context),
          const Divider(),
          _buildSalesSection(context),
          const Divider(),
          _buildManagementSection(context),
          const Divider(),
          _buildReportsSection(context),
          const Divider(),
          _buildSettingsSection(context),
          const Divider(),
          _buildSupportSection(context),
          const SizedBox(height: 20),
          _buildLogoutTile(context, ref),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, AuthState authState, AsyncValue<SubscriptionStatusModel?> subscriptionStatusAsync) {
    final user = authState.user;
    final isGuest = !authState.isAuthenticated;
    
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  isGuest ? Icons.person_outline : Icons.person,
                  size: 35,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final themeMode = ref.watch(themeModeProvider);
                  return IconButton(
                    icon: Icon(
                      themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                    tooltip: themeMode == ThemeMode.dark ? 'Switch to light mode' : 'Switch to dark mode',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isGuest ? 'Guest User' : (user?.name ?? 'User'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!isGuest) ...[
            Text(
              user?.businessName ?? '',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                subscriptionStatusAsync.when(
                  data: (status) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getSubscriptionColor(status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getSubscriptionLabel(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getSubscriptionColor(SubscriptionStatusModel? status) {
    if (status == null) return Colors.grey;
    if (status.hasActiveSubscription) {
      if (status.subscription?.planCode == 'trial') return Colors.orange;
      return Colors.green;
    }
    return Colors.red;
  }

  String _getSubscriptionLabel(SubscriptionStatusModel? status) {
    if (status == null) return 'Loading...';
    if (!status.hasActiveSubscription) return 'Expired';
    if (status.subscription?.planCode == 'trial') return 'Trial';
    return 'Premium';
  }

  Widget _buildProfileSection(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile'),
          subtitle: const Text('Manage your account'),
          onTap: () {
            context.go('/profile');
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildSalesSection(BuildContext context) {
    return Column(
      children: [
        _buildSectionTitle('Sales & Billing'),
        ListTile(
          leading: const Icon(Icons.point_of_sale),
          title: const Text('New Sale'),
          onTap: () {
            context.go('/billing');
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Bills History'),
          trailing: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '12',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          onTap: () {
            context.go('/bills-history');
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.request_quote),
          title: const Text('Quotations'),
          onTap: () {
            context.go('/quotations');
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.assignment_return),
          title: const Text('Credit Notes'),
          onTap: () {
            context.go('/credit-notes');
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.account_balance_wallet),
          title: const Text('Daily Closing'),
          subtitle: const Text('End of day cash reconciliation'),
          onTap: () {
            context.go('/daily-closing');
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildManagementSection(BuildContext context) {
    return Column(
      children: [
        _buildSectionTitle('Management'),
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Customers'),
          onTap: () {
            context.go('/customers');
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.inventory_2),
          title: const Text('Inventory'),
          onTap: () {
            context.go('/inventory');
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.money_off),
          title: const Text('Expenses'),
          onTap: () {
            context.go('/expenses');
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.badge),
          title: const Text('Staff'),
          onTap: () {
            context.go('/staff');
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildReportsSection(BuildContext context) {
    return Column(
      children: [
        _buildSectionTitle('Analytics'),
        ListTile(
          leading: const Icon(Icons.analytics),
          title: const Text('Reports'),
          subtitle: const Text('Sales, inventory & financial'),
          onTap: () {
            context.go('/reports');
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      children: [
        _buildSectionTitle('Configuration'),
        ListTile(
          leading: const Icon(Icons.print),
          title: const Text('Printer Settings'),
          onTap: () {
            context.go('/settings/printer');
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.receipt),
          title: const Text('Invoice Settings'),
          onTap: () {
            context.go('/settings/invoice');
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('App Settings'),
          onTap: () {
            context.go('/settings');
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.diamond),
          title: const Text('Subscription'),
          trailing: const Icon(Icons.new_releases, color: Colors.orange),
          onTap: () {
            context.go('/subscription');
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Column(
      children: [
        _buildSectionTitle('Support'),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Help & Support'),
          onTap: () {
            context.go('/help');
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          onTap: () {
            context.go('/about');
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildLogoutTile(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    if (!authState.isAuthenticated) {
      return ListTile(
        leading: const Icon(Icons.login),
        title: const Text('Sign In'),
        onTap: () {
          context.go('/login');
          Navigator.pop(context);
        },
      );
    }
    
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text('Logout', style: TextStyle(color: Colors.red)),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/');
                  }
                },
                child: const Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF757575),
        ),
      ),
    );
  }
}