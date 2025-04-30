import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/models/fobs.dart';
import 'package:hydrate_mobile_flutter/src/models/misc.dart';
import 'package:hydrate_mobile_flutter/src/screens/profile_view.dart';
import 'package:hydrate_mobile_flutter/src/screens/settings/settings_controller.dart';

// Define color constants
const Color skeletonColor = Color(0xFFE0E0E0);
const Color starBackgroundColor = Colors.red;
const Color starIconColor = Colors.blue;
const Color likesBackgroundColor = Colors.amber;
const Color likesIconColor = Colors.red;

class FobDetailView extends StatefulWidget {
  const FobDetailView({super.key, required this.settingsController, required this.fobId});

  final SettingsController settingsController;
  final String fobId;

  @override
  State<FobDetailView> createState() => _FobDetailViewState();
}

class _FobDetailViewState extends State<FobDetailView> {
  late Future<Fob> fobDetailsFuture;
  
  final SizedBox fobPicture = SizedBox(
    width: double.infinity,
    child: Image.asset("assets/images/flutter_logo.png")
  );

  @override
  void initState() {
    super.initState();
    fobDetailsFuture = fetchFobDetails(widget.fobId);
  }

  Future<Fob> fetchFobDetails(String fobId) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return Fountain(
      id: fobId,
      name: "Fountain $fobId",
      userId: "Owner $fobId",
      location: Location(
        lat: 40.429052,
        lng: -86.913124,
      ),
      info: FountainInfo(bottleFiller: true),
      createdAt: (DateTime.now().microsecondsSinceEpoch / 1000).toInt(),
      updatedAt: (DateTime.now().microsecondsSinceEpoch / 1000).toInt()
    );
  }

  Widget buildRatingCard(BuildContext context, {String? user, String? rating, bool isSkeleton = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isSkeleton ? skeletonColor : starBackgroundColor,
                child: isSkeleton
                    ? null
                    : Icon(Icons.star, color: starIconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isSkeleton
                        ? Container(height: 15, width: 100, color: skeletonColor)
                        : Text(user ?? "", style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 5),
                    isSkeleton
                        ? Container(height: 15, width: 50, color: skeletonColor)
                        : Text(rating ?? "", style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 20, width: 150, color: skeletonColor),
        const SizedBox(height: 15),
        Row(
          children: [
            CircleAvatar(radius: 25, backgroundColor: skeletonColor),
            const SizedBox(width: 10),
            Container(height: 20, width: 100, color: skeletonColor),
            const Spacer(),
            Container(height: 20, width: 50, color: skeletonColor),
            const SizedBox(width: 10),
            CircleAvatar(radius: 25, backgroundColor: skeletonColor),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Divider(height: 4),
        ),
        Container(height: 20, width: 100, color: skeletonColor),
        const SizedBox(height: 10),
        Container(height: 50, width: double.infinity, color: skeletonColor),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Divider(height: 4),
        ),
        Container(height: 20, width: 100, color: skeletonColor),
        const SizedBox(height: 10),
        Text("Ratings", style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 10),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 4,
          itemBuilder: (context, index) => buildRatingCard(context, isSkeleton: true),
        ),
      ],
    );
  }

  Widget buildFobDetails(Fob fob) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fob.name, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 15),
        Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileView(settingsController: widget.settingsController),
                  ),
                );
              },
              child: const CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage("assets/images/flutter_logo.png"),
              ),
            ),
            const SizedBox(width: 10),
            Text(fob.userId, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            Text("${fob.averageRating} likes", style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 25,
              backgroundColor: likesBackgroundColor,
              child: Icon(Icons.favorite, color: likesIconColor),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Divider(height: 4),
        ),
        Text("Ratings", style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 10),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: fob.length,
          itemBuilder: (context, index) => buildRatingCard(
            context,
            user: "User ${index + 1}",
            rating: fob["ratings"][index],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fob'),
      ),
      body: Stack(
        children: [
          fobPicture,
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 1.0,
            minChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Theme.of(context).canvasColor,
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: fobDetailsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return buildSkeleton();
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error loading fob details"));
                      } else {
                        return buildFobDetails(snapshot.data!);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
