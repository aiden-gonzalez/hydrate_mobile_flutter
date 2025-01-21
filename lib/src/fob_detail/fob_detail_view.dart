import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/profile/profile_view.dart';
import 'package:hydrate_mobile_flutter/src/settings/settings_controller.dart';

class FobDetailView extends StatelessWidget {
  FobDetailView({super.key, required this.settingsController, required this.fobId});

  final SettingsController settingsController;

  final String fobId;

  final SizedBox fobPicture = SizedBox(
    width: double.infinity,
    child: Image.asset("assets/images/flutter_logo.png")
  );

  subDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: Colors.red,
            child: Icon(
              Icons.star,
              size: 15,
              color: Colors.blue
            )
          ),
          const SizedBox(
            width: 10
          ),
          Text(
            "Rating",
            style: Theme.of(context).textTheme.bodyMedium
          )
        ],
      )
    );
  }

  fobDetails() {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 1.0,
      minChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20)
            ),
            color: Theme.of(context).canvasColor
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 25
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 5,
                        width: 35,
                        color: Colors.black
                      )
                    ],
                  ),
                ),
                Text(
                  "Name",
                  style: Theme.of(context).textTheme.headlineMedium
                ),
                const SizedBox(
                  height: 15
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfileView(settingsController: settingsController)),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage("assets/images/flutter_logo.png")
                      )
                    ),
                    const SizedBox(
                      width: 5
                    ),
                    Text(
                      "Aiden Gonzalez",
                      style: Theme.of(context).textTheme.bodyLarge
                    ),
                    Spacer(),
                    Text(
                      "250 likes",
                      style: Theme.of(context).textTheme.bodyLarge
                    ),
                    const SizedBox(
                      width: 5
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.amber,
                      child: Icon(
                        Icons.favorite,
                        color: Colors.red
                      )
                    )                    
                  ]
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 15
                  ),
                  child: Divider(
                    height: 4
                  ),
                ),
                Text(
                  "Description",
                  style: Theme.of(context).textTheme.headlineLarge
                ),
                const SizedBox(
                  height: 10
                ),
                Text(
                  "Here is a description of the fob",
                  style: Theme.of(context).textTheme.bodyMedium
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(
                    height: 4
                  )
                ),
                Text(
                  "Ratings",
                  style: Theme.of(context).textTheme.headlineLarge
                ),
                const SizedBox(
                  height: 10
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 4,
                  itemBuilder: (context, index) => subDetails(context)
                )
              ]
            ),
          )
        );
      }
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
          fobDetails()
        ],
      )
    );
  }
}
