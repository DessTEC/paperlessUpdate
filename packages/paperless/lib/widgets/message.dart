import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomMessageWidget extends ConsumerStatefulWidget {
  const CustomMessageWidget({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.icon,
  }) : super(key: key);

  final String title;
  final String subTitle;
  final Icon icon;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CustomMessageWidgetState();
}

class _CustomMessageWidgetState extends ConsumerState<CustomMessageWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListTile(
              title: Text(widget.title),
              subtitle: Text(
                widget.subTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: widget.icon,
            ),
          ),
        ),
      ),
    );
  }
}
