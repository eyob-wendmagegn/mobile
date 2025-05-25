import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:waste_management_app/models/waste_collection.dart';
import 'package:waste_management_app/providers/auth_provider.dart';
import 'package:waste_management_app/services/api_service.dart';
import 'package:waste_management_app/widgets/custom_button.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wasteTypeController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _kilogramsController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;
  String _error = '';
  int _calculatedRewards = 0;

  final List<String> _wasteTypes = [
    'Plastic',
    'Paper',
    'Glass',
    'Metal',
    'Electronic',
    'Organic',
    'Other',
  ];

  final List<String> _locations = [
    'Addis Ababa',
    'Adama',
    'Bahir Dar',
    'Hawassa',
    'Mekelle',
    'Dire Dawa',
    'Gondar',
    'Jimma',
    'Other',
  ];

  @override
  void dispose() {
    _wasteTypeController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _kilogramsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _calculateRewards() {
    if (_wasteTypeController.text.isEmpty ||
        _kilogramsController.text.isEmpty) {
      return;
    }

    final wasteType = _wasteTypeController.text;
    final kilograms = double.tryParse(_kilogramsController.text) ?? 0;

    // Calculate rewards based on waste type and kilograms
    int rewardPoints = 0;

    switch (wasteType) {
      case 'Plastic':
        rewardPoints = (kilograms * 5).round();
        break;
      case 'Paper':
        rewardPoints = (kilograms * 3).round();
        break;
      case 'Glass':
        rewardPoints = (kilograms * 4).round();
        break;
      case 'Metal':
        rewardPoints = (kilograms * 6).round();
        break;
      case 'Electronic':
        rewardPoints = (kilograms * 8).round();
        break;
      case 'Organic':
        rewardPoints = (kilograms * 2).round();
        break;
      default:
        rewardPoints = (kilograms * 1).round();
    }

    setState(() {
      _calculatedRewards = rewardPoints;
    });
  }

  Future<void> _submitSchedule() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.currentUser;

        if (user == null) {
          setState(() {
            _error = 'User not authenticated';
            _isLoading = false;
          });
          return;
        }

        final dateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        final kilograms = double.parse(_kilogramsController.text);

        // Create a new waste collection
        final collection = WasteCollection(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user.id,
          userName: user.name,
          wasteType: _wasteTypeController.text,
          location: _locationController.text,
          address: _addressController.text,
          dateTime: dateTime,
          kilograms: kilograms,
          rewardPoints: _calculatedRewards,
          createdAt: DateTime.now(),
        );

        final response = await ApiService.createWasteCollection(collection);

        if (response['success']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Schedule sent successfully! You earned $_calculatedRewards points.'),
                backgroundColor: Colors.green,
              ),
            );

            // Reset form
            _formKey.currentState!.reset();
            _wasteTypeController.clear();
            _locationController.clear();
            _addressController.clear();
            _kilogramsController.clear();
            setState(() {
              _selectedDate = DateTime.now().add(const Duration(days: 1));
              _selectedTime = TimeOfDay.now();
              _calculatedRewards = 0;
            });
          }
        } else {
          setState(() {
            _error = response['message'] ?? 'Failed to send schedule';
          });
        }
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Schedule Waste Collection',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in the details to schedule a waste collection',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Waste Type Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Waste Type',
                  prefixIcon: Icon(Icons.delete_outline),
                ),
                items: _wasteTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _wasteTypeController.text = newValue;
                      _calculateRewards();
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a waste type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_city),
                ),
                items: _locations.map((String location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _locationController.text = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Specific Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Specific Address',
                  prefixIcon: Icon(Icons.home),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your specific address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _selectedTime.format(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Kilograms
              TextFormField(
                controller: _kilogramsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  prefixIcon: Icon(Icons.scale),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Weight must be greater than 0';
                  }
                  return null;
                },
                onChanged: (value) {
                  _calculateRewards();
                },
              ),
              const SizedBox(height: 24),

              // Rewards Preview
              if (_calculatedRewards > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 40,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Rewards',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '$_calculatedRewards points',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (_calculatedRewards > 0) const SizedBox(height: 24),

              // Error Message
              if (_error.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error,
                    style: TextStyle(color: Colors.red.shade800),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_error.isNotEmpty) const SizedBox(height: 16),

              // Submit Button
              CustomButton(
                text: 'Send Schedule',
                isLoading: _isLoading,
                onPressed: _submitSchedule,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
