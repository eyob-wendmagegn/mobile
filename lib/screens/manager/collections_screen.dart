import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waste_management_app/models/waste_collection.dart';
import 'package:waste_management_app/services/api_service.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({Key? key}) : super(key: key);

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  late Future<List<WasteCollection>> _collectionsFuture;
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _wasteTypeFilter = 'All';

  final List<String> _statusOptions = [
    'All',
    'Pending',
    'Completed',
    'Cancelled',
  ];
  final List<String> _wasteTypeOptions = [
    'All',
    'Plastic',
    'Paper',
    'Glass',
    'Metal',
    'Electronic',
    'Organic',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  void _loadCollections() {
    _collectionsFuture = ApiService.getAllCollections();
  }

  List<WasteCollection> _filterCollections(List<WasteCollection> collections) {
    return collections.where((collection) {
      // Filter by search query
      final matchesSearch =
          _searchQuery.isEmpty ||
          collection.userName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          collection.location.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          collection.wasteType.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      // Filter by status
      final matchesStatus =
          _statusFilter == 'All' ||
          collection.status.toLowerCase() == _statusFilter.toLowerCase();

      // Filter by waste type
      final matchesWasteType =
          _wasteTypeFilter == 'All' || collection.wasteType == _wasteTypeFilter;

      return matchesSearch && matchesStatus && matchesWasteType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search collections',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        value: _statusFilter,
                        items:
                            _statusOptions.map((String status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _statusFilter = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Waste Type',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        value: _wasteTypeFilter,
                        items:
                            _wasteTypeOptions.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _wasteTypeFilter = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Collections List
          Expanded(
            child: FutureBuilder<List<WasteCollection>>(
              future: _collectionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No collections found.'));
                } else {
                  final filteredCollections = _filterCollections(
                    snapshot.data!,
                  );

                  if (filteredCollections.isEmpty) {
                    return const Center(
                      child: Text('No collections match your filters.'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadCollections();
                      setState(() {});
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredCollections.length,
                      itemBuilder: (context, index) {
                        final collection = filteredCollections[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        collection.userName,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Chip(
                                      label: Text(collection.status),
                                      backgroundColor:
                                          collection.status == 'pending'
                                              ? Colors.orange.withOpacity(0.2)
                                              : collection.status == 'completed'
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.red.withOpacity(0.2),
                                      labelStyle: TextStyle(
                                        color:
                                            collection.status == 'pending'
                                                ? Colors.orange
                                                : collection.status ==
                                                    'completed'
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${collection.wasteType} - ${collection.kilograms.toStringAsFixed(1)} kg',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${collection.location}, ${collection.address}',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat(
                                        'MMM dd, yyyy - hh:mm a',
                                      ).format(collection.dateTime),
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (collection.status == 'pending')
                                      OutlinedButton(
                                        onPressed: () {
                                          // Mark as completed logic
                                          // This would update the collection status in the backend
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Collection marked as completed',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        },
                                        child: const Text('Mark as Completed'),
                                      ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        // View details logic
                                        // This would navigate to a detailed view of the collection
                                      },
                                      child: const Text('View Details'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
