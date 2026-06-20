// my_addresses_page.dart
import 'package:flutter/material.dart';
import '../widgets/BaseWidget.dart';
import '../locationPage/user_current_location.dart';

class MyAddressesPage extends StatefulWidget {
  const MyAddressesPage({super.key});

  @override
  State<MyAddressesPage> createState() => _MyAddressesPageState();
}

class _MyAddressesPageState extends State<MyAddressesPage> {
  final List<String> _addresses = [
    "Home: 123 Main St, Chennai, Tamil Nadu",
    "Work: 456 Office Rd, Bangalore, Karnataka"
  ];

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Addresses"),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        ),
        body: Column(
          children: [
            // Add New Address Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_location),
                label: const Text("Add New Address"),
                onPressed: () async {
                  // Navigate to UserCurrentLocation to select a new address
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserCurrentLocation(),
                    ),
                  );

                  if (result != null && result is String) {
                    setState(() {
                      _addresses.add("New: $result");
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Address added: $result")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // List of Addresses
            Expanded(
              child: ListView.builder(
                itemCount: _addresses.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        index == 0 ? Icons.home : Icons.work,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(_addresses[index]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editAddress(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteAddress(index),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Set this as default address or show details
                        _setAsDefault(index);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editAddress(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserCurrentLocation(),
      ),
    );

    if (result != null && result is String) {
      setState(() {
        final prefix = _addresses[index].split(':')[0];
        _addresses[index] = "$prefix: $result";
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Address updated")),
      );
    }
  }

  void _deleteAddress(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Address"),
        content: const Text("Are you sure you want to delete this address?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _addresses.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Address deleted")),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _setAsDefault(int index) {
    if (index != 0) {
      setState(() {
        final address = _addresses.removeAt(index);
        _addresses.insert(0, address);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Set as default address")),
      );
    }
  }
}