import 'package:flutter/material.dart';
import 'package:hydrate_mobile_flutter/src/models/ratings.dart';
import 'package:hydrate_mobile_flutter/src/utils/strings.dart';

class RatingDetailsWidget extends StatelessWidget {
  const RatingDetailsWidget({super.key, required this.headerText, required this.rating});
  final String headerText;
  final Rating rating;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> ratingDetails = rating.details.toJson();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerText.isNotEmpty
          ? Text(
              headerText,
              style: Theme.of(context).textTheme.bodyLarge,
            )
          : const SizedBox.shrink(),
        headerText.isNotEmpty
          ? const SizedBox(height: 5)
          : const SizedBox.shrink(),
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
    );
  }
}
