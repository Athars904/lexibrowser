import 'package:flutter/material.dart';
class HomeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget icon;

  const HomeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.lightBlueAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
      ),
      elevation: 4, // Add elevation for shadow effect
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0), // Adjust horizontal padding
        width: 350.0, // Adjust width as needed
        child: Row(
          children: [
            // Icon
            icon,
            const SizedBox(width: 4.0), // Add some space between icon and text
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                    maxLines: 1, // Limit the number of lines to 1
                    overflow: TextOverflow.ellipsis, // Handle overflow by ellipsis
                  ),
                  const Spacer(), // Add some space between title and subtitle
                  // Subtitle
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                    maxLines: 1, // Limit the number of lines to 1
                    overflow: TextOverflow.ellipsis, // Handle overflow by ellipsis
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
