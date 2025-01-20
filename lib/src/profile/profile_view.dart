import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/settings/settings_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key, required this.settingsController});

  static const routeName = "/profile";

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
                      Text("32",
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 15),
                      Text("Fountains",
                          style: Theme.of(context).textTheme.titleSmall)
                    ]),
                  ),
                  SizedBox(
                    width: 100,
                    child: Column(children: [
                      Text("32",
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 15),
                      Text("Bathrooms",
                          style: Theme.of(context).textTheme.titleSmall)
                    ]),
                  ),
                  SizedBox(
                    width: 100,
                    child: Column(children: [
                      Text("32",
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
                  tabs: [
                    Tab(
                      icon: Icon(Icons.water_drop),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.wc,
                      ),
                    ),
                    Tab(icon: Icon(Icons.star))
                  ],
                ),
              ),
            ),

            // create widgets for each tab bar here
            Expanded(
                child: TabBarView(
              children: [
                Icon(Icons.water_drop),
                Icon(Icons.wc),
                Icon(Icons.star),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
