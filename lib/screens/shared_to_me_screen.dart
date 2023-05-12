import 'package:diet_designer/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:provider/provider.dart';

class SharedToMeScreen extends StatefulWidget {
  const SharedToMeScreen({super.key});

  @override
  State<SharedToMeScreen> createState() => _SharedToMeScreenState();
}

class _SharedToMeScreenState extends State<SharedToMeScreen> {
  final bool _isLoading = false;
  int _selectedOption = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().uid!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared to me'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNavigationRow(context),
              // _isLoading
              //     ? const Center(child: CircularProgressIndicator())
              //     : _selectedOption == 0
              //         ? _buildSharedPlansList(uid)
              //         : _buildSharedMealsList(uid)
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildNavigationRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedOption == 0 ? "Plans" : "Meals",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.touch_app, color: Colors.grey, size: 12),
                      Text(
                        _selectedOption == 0 ? "  Tap to unfold" : "  Tap for details",
                        style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              FlutterToggleTab(
                width: 30,
                height: 42,
                borderRadius: 50,
                marginSelected: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                selectedTextStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
                unSelectedTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w400),
                unSelectedBackgroundColors: [Theme.of(context).colorScheme.secondaryContainer],
                labels: const ['', ''],
                icons: const [Icons.event_note, Icons.fastfood],
                iconSize: 22,
                selectedIndex: _selectedOption,
                selectedLabelIndex: (index) {
                  setState(() {
                    if (index == _selectedOption) return;
                    _selectedOption = index;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  _buildSharedPlansList(String uid) {}

  _buildSharedMealsList(String uid) {}
}
