import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/models/profiles.dart';
import 'package:hydrate_mobile_flutter/src/screens/settings/settings_controller.dart';
import 'package:hydrate_mobile_flutter/src/utils/api.dart';
import 'package:hydrate_mobile_flutter/src/utils/auth.dart';
import 'package:hydrate_mobile_flutter/src/utils/stores.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.settingsController});

  final SettingsController settingsController;

  static const String routeName = "/profile";

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  int currentTab = 0;
  bool isLoading = true;
  String? errorMessage;

  // Contribution data
  UserContributions? userContributions;

  @override
  void initState() {
    super.initState();
    fetchUserContributions();
  }

  Future<void> fetchUserContributions() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final tokenStore = useTokenStore();
      final tokens = await AuthService.checkOrRefreshToken(tokenStore.state);
      if (tokens == null) {
        debugPrint("Unable to fetch user contributions: No valid token");
        throw Exception("No valid token");
      }

      final contributionsResponse = await getOwnUserContributions(tokens.accessToken);
      if (contributionsResponse.statusCode != 200) {
        debugPrint("Unable to fetch user contributions: ${contributionsResponse.body}");
        throw Exception("Failed to fetch contributions: ${contributionsResponse.body}");
      }

      final contributions = UserContributions.fromJson(jsonDecode(contributionsResponse.body));

      setState(() {
        userContributions = contributions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load contributions: $e';
        isLoading = false;
      });
    }
  }

  Widget _buildContributionCard(dynamic item, IconData icon, String type) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(item['name'] ?? 'Unnamed $type'),
        subtitle: Text(item['location'] ?? 'No location information'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item['rating'] != null) ...[
              Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text('${item['rating']}'),
              const SizedBox(width: 8),
            ],
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () {
          // Navigate to detail view
          // Navigator.pushNamed(context, '/details/$type/${item['id']}');
        },
      ),
    );
  }

  Widget _buildContributionList(List<dynamic> items, IconData icon, String type) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Always wrap with RefreshIndicator, even for error and empty states
    return RefreshIndicator(
      onRefresh: fetchUserContributions,
      child: errorMessage != null
          ? ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
                  child: Center(child: Text(errorMessage!)),
                ),
              ],
            )
          : items.isEmpty
              ? ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Center(child: Text('No $type contributions yet')),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return _buildContributionCard(items[index], icon, type);
                  },
                ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: currentTab,
      child: Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: Column(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Stack(alignment: Alignment.bottomRight, children: [
                const CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        AssetImage("assets/images/flutter_logo.png")),
                InkWell(
                  onTap: () {},
                  child: const CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.edit, size: 15, color: Colors.white)),
                )
              ]),
              Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text("Aiden Gonzalez",
                      style: Theme.of(context).textTheme.headlineMedium)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 100,
                    child: Column(children: [
                      Text("${userContributions?.fountains.length ?? 0}",
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 15),
                      Text("Fountains",
                          style: Theme.of(context).textTheme.titleSmall)
                    ]),
                  ),
                  SizedBox(
                    width: 100,
                    child: Column(children: [
                      Text("${userContributions?.bathrooms.length ?? 0}",
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 15),
                      Text("Bathrooms",
                          style: Theme.of(context).textTheme.titleSmall)
                    ]),
                  ),
                  SizedBox(
                    width: 100,
                    child: Column(children: [
                      Text("${userContributions?.ratings.length ?? 0}",
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 15),
                      Text("Ratings",
                          style: Theme.of(context).textTheme.titleSmall)
                    ]),
                  )
                ],
              )
            ]),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: AppBar(
                bottom: TabBar(
                  onTap: (int index) {
                    setState(() {
                      currentTab = index;
                    });
                  },
                  tabs: const [
                    Tab(icon: Icon(Icons.water_drop)),
                    Tab(icon: Icon(Icons.wc)),
                    Tab(icon: Icon(Icons.star))
                  ],
                ),
              ),
            ),

            // TabBarView with contribution lists
            Expanded(
              child: TabBarView(
                children: [
                  _buildContributionList(userContributions?.fountains ?? [], Icons.water_drop, 'fountain'),
                  _buildContributionList(userContributions?.bathrooms ?? [], Icons.wc, 'bathroom'),
                  _buildContributionList(userContributions?.ratings ?? [], Icons.star, 'rating'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
