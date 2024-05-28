import 'package:flutter/material.dart';

class RendererContainer extends StatelessWidget {
  const RendererContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.6;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: width,
        height: width,
        child: child,
      ),
    );
  }
}
