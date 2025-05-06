import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/models/fobs.dart';
import 'package:hydrate_mobile_flutter/src/screens/profile_view.dart';
import 'package:hydrate_mobile_flutter/src/screens/settings/settings_controller.dart';
import 'package:hydrate_mobile_flutter/src/utils/api.dart';
import 'package:hydrate_mobile_flutter/src/utils/auth.dart';
import 'package:hydrate_mobile_flutter/src/utils/stores.dart';

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
  late Future<FobWithDetails> fobDetailsFuture;
  
  final SizedBox fobPicture = SizedBox(
    width: double.infinity,
    child: Image.asset("assets/images/flutter_logo.png")
  );

  @override
  void initState() {
    super.initState();
    // Get access token
    final tokenStore = useTokenStore();
    fobDetailsFuture = AuthService.checkOrRefreshToken(tokenStore.state).then((tokens) {
      if (tokens == null) {
        debugPrint("Unable to fetch fob details: No valid token");
        return Future.error("No valid token");
      }
      return getFobWithDetails(tokens.accessToken, widget.fobId);
    });
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

  Widget buildFobDetails(FobWithDetails fobWithDetails) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(fobWithDetails.fob.name, style: Theme.of(context).textTheme.headlineMedium),
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
            Text(fobWithDetails.fob.userId, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            Text("${fobWithDetails.fob.averageRating} stars", style: Theme.of(context).textTheme.bodyLarge),
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
          itemCount: fobWithDetails.ratingsWithDetails.length,
          itemBuilder: (context, index) => buildRatingCard(
            context,
            user: fobWithDetails.ratingsWithDetails[index].user.username,
            rating: fobWithDetails.ratingsWithDetails[index].rating.details.toString(),
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
                  child: FutureBuilder<FobWithDetails>(
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
