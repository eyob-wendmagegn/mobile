import 'package:flutter/material.dart';
import 'package:waste_management_app/models/recycling_center.dart';
import 'package:waste_management_app/services/api_service.dart';
import 'package:waste_management_app/widgets/center_card.dart';

class CentersScreen extends StatefulWidget {
  const CentersScreen({Key? key}) : super(key: key);

  @override
  State<CentersScreen> createState() => _CentersScreenState();
}

class _CentersScreenState extends State<CentersScreen> {
  late Future<List<RecyclingCenter>> _centersFuture;
  String _searchQuery = '';
  String _selectedWasteType = 'All';

  final List<String> _wasteTypes = [
    'All',
    'Plastic',
    'Paper',
    'Glass',
    'Metal',
    'Electronic',
    'Organic',
  ];

  @override
  void initState() {
    super.initState();
    _loadCenters();
  }

  void _loadCenters() {
    _centersFuture = ApiService.getRecyclingCenters();
  }

  List<RecyclingCenter> _filterCenters(List<RecyclingCenter> centers) {
    return centers.where((center) {
      // Filter by search query
      final matchesSearch =
          _searchQuery.isEmpty ||
          center.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          center.address.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter by waste type
      final matchesWasteType =
          _selectedWasteType == 'All' ||
          center.acceptedWasteTypes.contains(_selectedWasteType);

      return matchesSearch && matchesWasteType;
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
                    hintText: 'Search recycling centers',
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

                // Waste Type Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _wasteTypes.map((type) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(type),
                              selected: _selectedWasteType == type,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedWasteType = selected ? type : 'All';
                                });
                              },
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Centers List
          Expanded(
            child: FutureBuilder<List<RecyclingCenter>>(
              future: _centersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No recycling centers found.'),
                  );
                } else {
                  final filteredCenters = _filterCenters(snapshot.data!);

                  if (filteredCenters.isEmpty) {
                    return const Center(
                      child: Text('No centers match your filters.'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadCenters();
                      setState(() {});
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredCenters.length,
                      itemBuilder: (context, index) {
                        return CenterCard(center: filteredCenters[index]);
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
