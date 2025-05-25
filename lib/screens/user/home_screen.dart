import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waste_management_app/models/waste_collection.dart';
import 'package:waste_management_app/providers/auth_provider.dart';
import 'package:waste_management_app/providers/profile_provider.dart';
import 'package:waste_management_app/services/api_service.dart';
import 'package:waste_management_app/widgets/collection_card.dart';
import 'package:waste_management_app/widgets/stats_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<WasteCollection>> _collectionsFuture;
  int _totalRewards = 0;
  double _totalKilograms = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initProfileProvider();
  }

  void _initProfileProvider() {
    // Initialize the profile provider with the current user ID
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      profileProvider.setUserId(authProvider.currentUser!.id);
    }
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      _collectionsFuture =
          ApiService.getUserCollections(authProvider.currentUser!.id);
      _collectionsFuture.then((collections) {
        _calculateStats(collections);
      });
    }
  }

  void _calculateStats(List<WasteCollection> collections) {
    int rewards = 0;
    double kilograms = 0;

    for (var collection in collections) {
      rewards += collection.rewardPoints;
      kilograms += collection.kilograms;
    }

    setState(() {
      _totalRewards = rewards;
      _totalKilograms = kilograms;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Center(child: Text('Please login to continue'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
        await profileProvider.loadProfileImage();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          profileProvider.isLoading
                              ? const SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              : CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.2),
                                  backgroundImage:
                                      profileProvider.hasProfileImage()
                                          ? profileProvider.getProfileImage()
                                          : null,
                                  child: !profileProvider.hasProfileImage()
                                      ? Icon(
                                          Icons.person,
                                          size: 30,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        )
                                      : null,
                                ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  user.name,
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stats Section
              Text(
                'Your Impact',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      icon: Icons.eco,
                      title: 'Total Waste',
                      value: '${_totalKilograms.toStringAsFixed(1)} kg',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatsCard(
                      icon: Icons.star,
                      title: 'Rewards',
                      value: '$_totalRewards pts',
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Collections
              Text(
                'Recent Collections',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<WasteCollection>>(
                future: _collectionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                          'No collections found. Schedule your first collection!'),
                    );
                  } else {
                    final collections = snapshot.data!;
                    collections
                        .sort((a, b) => b.dateTime.compareTo(a.dateTime));
                    final recentCollections = collections.take(5).toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentCollections.length,
                      itemBuilder: (context, index) {
                        return CollectionCard(
                            collection: recentCollections[index]);
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
