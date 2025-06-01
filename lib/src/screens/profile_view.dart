import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/custom_widgets/rating_details_widget.dart';
import 'package:hydrate_mobile_flutter/src/models/fobs.dart';
import 'package:hydrate_mobile_flutter/src/models/profiles.dart';
import 'package:hydrate_mobile_flutter/src/models/ratings.dart';
import 'package:hydrate_mobile_flutter/src/screens/fobs/fob_detail_view.dart';
import 'package:hydrate_mobile_flutter/src/screens/settings/settings_controller.dart';
import 'package:hydrate_mobile_flutter/src/screens/settings/settings_view.dart';
import 'package:hydrate_mobile_flutter/src/utils/api.dart';
import 'package:hydrate_mobile_flutter/src/utils/auth.dart';
import 'package:hydrate_mobile_flutter/src/utils/stores.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.settingsController, required this.camera});

  final SettingsController settingsController;
  final CameraDescription camera;

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

  Widget _buildFobCard(Fob fob, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(fob.name),
        subtitle: Text(fob.location.toString()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (fob.averageRating != null) ...[
              Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(fob.averageRating!.toStringAsFixed(1)),
              const SizedBox(width: 8),
            ],
            Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: () {
          // Navigate to the detail view for this fob
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FobDetailView(
                settingsController: widget.settingsController,
                camera: widget.camera,
                fobId: fob.id,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingCard(Rating rating, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with icon and title
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rating.fobId,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        rating.createdAt.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Divider between header and details
            const Divider(),
            
            // Rating details with average rating at center-right
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Rating details on the left
                Expanded(
                  child: RatingDetailsWidget(
                    headerText: "",  // Empty header since we already show the ID above
                    rating: rating,
                  ),
                ),
                
                // Average rating indicator on the right
                Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        rating.average.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    if (type == 'rating') {
                      return _buildRatingCard(items[index] as Rating, icon);
                    }
                    return _buildFobCard(items[index] as Fob, icon);
                  }
                ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: currentTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          actions: [
            // Add settings button in the app bar
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SettingsView(
                      settingsControler: widget.settingsController,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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
