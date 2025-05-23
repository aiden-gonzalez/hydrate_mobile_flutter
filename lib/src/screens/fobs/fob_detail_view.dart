import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/models/fobs.dart';
import 'package:hydrate_mobile_flutter/src/models/misc.dart';
import 'package:hydrate_mobile_flutter/src/models/ratings.dart';
import 'package:hydrate_mobile_flutter/src/screens/fobs/fob_rating_create_view.dart';
import 'package:hydrate_mobile_flutter/src/screens/profile_view.dart';
import 'package:hydrate_mobile_flutter/src/screens/settings/settings_controller.dart';
import 'package:hydrate_mobile_flutter/src/utils/api.dart';
import 'package:hydrate_mobile_flutter/src/utils/auth.dart';
import 'package:hydrate_mobile_flutter/src/utils/constants.dart' as constants;
import 'package:hydrate_mobile_flutter/src/utils/stores.dart';
import 'package:hydrate_mobile_flutter/src/utils/strings.dart';

// Define color constants
const Color skeletonColor = Color(0xFFE0E0E0);
const Color starBackgroundColor = Colors.red;
const Color starIconColor = Colors.blue;
const Color likesBackgroundColor = Colors.amber;
const Color likesIconColor = Colors.red;

class FobDetailView extends StatefulWidget {
  const FobDetailView({super.key, required this.settingsController, required this.camera, required this.fobId});

  final SettingsController settingsController;
  final CameraDescription camera;
  final String fobId;

  @override
  State<FobDetailView> createState() => _FobDetailViewState();
}

class _FobDetailViewState extends State<FobDetailView> {
  late Future<FobWithDetails> fobDetailsFuture;
  int _currentImageIndex = 0;
  
  final SizedBox skeletonFobPicture = SizedBox(
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

  Widget buildSkeletonRatingCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: skeletonColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 15, width: 100, color: skeletonColor),
                    const SizedBox(height: 5),
                    Container(height: 15, width: 50, color: skeletonColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRatingCard(BuildContext context, {required RatingWithDetails ratingWithDetails}) {
    Map<String, dynamic> ratingDetails = ratingWithDetails.rating.details.toJson();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: starBackgroundColor,
                child: Icon(Icons.star, color: starIconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ratingWithDetails.user.username,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 5),
                    for (var property in ratingDetails.entries)
                      Row(
                        children: [
                          ...[
                            Text(
                              "${property.key.capitalize()}: ",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                            )
                          ],
                          ...List.generate(5, (index) {
                            return Icon(
                              index < (property.value ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                        ],
                      )
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
          itemBuilder: (context, index) => buildSkeletonRatingCard(context),
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
            Expanded(
              child: Text(
                fobWithDetails.user.username,
                style: Theme.of(context).textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 10), // Replace Spacer with SizedBox for consistent spacing
            Text(
              "${fobWithDetails.fob.averageRating?.toStringAsFixed(1) ?? "No"} stars",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 25,
              backgroundColor: likesBackgroundColor,
              child: Icon(Icons.star, color: likesIconColor),
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
          itemCount: fobWithDetails.ratingsWithDetails.isEmpty ? 1 : fobWithDetails.ratingsWithDetails.length,
          itemBuilder: (context, index) {
            if (fobWithDetails.ratingsWithDetails.isEmpty) {
              return Center(
                child: Text(
                  "No ratings available",
                  style: Theme.of(context).textTheme.bodyLarge,
                )
              );
            }
            return buildRatingCard(
              context,
              ratingWithDetails: fobWithDetails.ratingsWithDetails[index]
            );
          },
        ),
      ],
    );
  }

  Widget buildImageScroll(List<Picture> pictures) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          itemCount: pictures.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return Image.network(
              pictures[index].url,
              fit: BoxFit.fitHeight,
              width: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) => 
                Center(child: Icon(Icons.error, size: 50)),
            );
          },
        ),
        Positioned(
          bottom: 20,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                pictures.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index 
                        ? Colors.white 
                        : Colors.white38,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPageStack() {
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate the height of the image based on the screen size
            double imageHeight = constraints.maxHeight * 0.4;

            return SizedBox(
              height: imageHeight,
              child: FutureBuilder<FobWithDetails>(
                future: fobDetailsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return skeletonFobPicture;
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error loading fob pictures"));
                  } else {
                    // Check if the pictures list is empty
                    if (snapshot.data!.pictures.isEmpty) {
                      return skeletonFobPicture;
                    }
                    return buildImageScroll(snapshot.data!.pictures);
                  }
                }
              )
            );
          }
        ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fobId.startsWith(constants.fountainIdPrefix) ? "Fountain" : "Bathroom"),
      ),
      body: buildPageStack(),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Add Rating"),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FobRatingCreateView(
                camera: widget.camera,
                fobId: widget.fobId
              )
            )
          );
          // Refresh the ratings list after returning from the rating creation page
          setState(() {
            final tokenStore = useTokenStore();
            fobDetailsFuture = AuthService.checkOrRefreshToken(tokenStore.state).then((tokens) {
              if (tokens == null) {
                debugPrint("Unable to fetch fob details: No valid token");
                return Future.error("No valid token");
              }
              return getFobWithDetails(tokens.accessToken, widget.fobId);
            });
          });
        },
        tooltip: 'Add Rating',
        icon: const Icon(Icons.add),
      ),
    );
  }
}
