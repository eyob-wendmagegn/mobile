import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waste_management_app/models/waste_collection.dart';
import 'package:waste_management_app/providers/auth_provider.dart';
import 'package:waste_management_app/providers/profile_provider.dart';
import 'package:waste_management_app/services/api_service.dart';
import 'package:waste_management_app/widgets/stats_card.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({Key? key}) : super(key: key);

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  late Future<List<WasteCollection>> _collectionsFuture;
  int _totalUsers = 0;
  int _totalCollections = 0;
  double _totalWaste = 0;
  int _pendingCollections = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _collectionsFuture = ApiService.getAllCollections();
    _collectionsFuture.then((collections) {
      _calculateStats(collections);
    });

    ApiService.getAllUsers().then((users) {
      setState(() {
        _totalUsers = users.length;
      });
    });
  }

  void _calculateStats(List<WasteCollection> collections) {
    int total = collections.length;
    double waste = 0;
    int pending = 0;

    for (var collection in collections) {
      waste += collection.kilograms;
      if (collection.status == 'pending') {
        pending++;
      }
    }

    setState(() {
      _totalCollections = total;
      _totalWaste = waste;
      _pendingCollections = pending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user = authProvider.currentUser;

    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
        if (user != null) {
          await profileProvider.loadProfileImage();
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section with Profile Image
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        backgroundImage: profileProvider.profileImage,
                        child: profileProvider.isLoading
                            ? const CircularProgressIndicator()
                            : (profileProvider.profileImage == null
                                ? Icon(
                                    Icons.admin_panel_settings,
                                    size: 30,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  )
                                : null),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome,',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              user?.name ?? 'Manager',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stats Section
              Text(
                'Dashboard Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatsCard(
                    icon: Icons.recycling,
                    title: 'Total Collections',
                    value: '$_totalCollections',
                    color: Colors.green,
                  ),
                  StatsCard(
                    icon: Icons.people,
                    title: 'Active Users',
                    value: '$_totalUsers',
                    color: Colors.blue,
                  ),
                  StatsCard(
                    icon: Icons.delete,
                    title: 'Waste Collected',
                    value: '${(_totalWaste / 1000).toStringAsFixed(1)} tons',
                    color: Colors.orange,
                  ),
                  StatsCard(
                    icon: Icons.location_on,
                    title: 'Recycling Centers',
                    value: '8',
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Activity
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              // Activity List
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade400,
                    child: const Icon(Icons.recycling, color: Colors.white),
                  ),
                  title: const Text('New collection scheduled'),
                  subtitle: const Text('12:45 - 18/5'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),

              Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.pink,
                    child: const Icon(Icons.person_add, color: Colors.white),
                  ),
                  title: const Text('New user registered'),
                  subtitle: const Text('9:45 - 18/5'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),

              Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: const Icon(Icons.location_on, color: Colors.white),
                  ),
                  title: const Text('New recycling center added'),
                  subtitle: const Text('6:45 - 18/5'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),

              Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  title: const Text('Collection completed'),
                  subtitle: const Text('3:45 - 18/5'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),

              Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade700,
                    child: const Icon(Icons.star, color: Colors.white),
                  ),
                  title: const Text('User feedback received'),
                  subtitle: const Text('0:45 - 18/5'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
