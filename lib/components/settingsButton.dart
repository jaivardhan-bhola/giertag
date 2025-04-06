import 'package:flutter/material.dart';

class Settingsbutton extends StatelessWidget {
  final Function onPressed;
  final String title;
  final IconData iconLeading;
  final String? description;
  final Color? iconColor;
  final bool isNewPage;
  const Settingsbutton(
      {super.key,
      required this.onPressed,
      required this.title,
      this.description,
      required this.iconLeading,
      this.iconColor,
      required this.isNewPage,
      });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onPressed as void Function()?,
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(iconLeading,
                color: iconColor ?? Theme.of(context).colorScheme.primary)),
        title: Text(title,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: screenHeight * 0.018,
                fontWeight: FontWeight.normal)),
        subtitle: (description != null)
            ? Text(description!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: screenHeight * 0.013,
                  fontWeight: FontWeight.normal,
                ))
            : null,
        trailing: isNewPage
            ? Icon(Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurfaceVariant)
            : null,
      ),
    );
  }
}
