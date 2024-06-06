import 'package:flutter/material.dart';

import '../../resource/resource_state.dart';

class MultiResourceStateBuilder extends StatelessWidget {
  final List<ResourceState> listeners;
  final Widget Function(BuildContext context) builder;

  const MultiResourceStateBuilder({
    required this.listeners,
    required this.builder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        for (final listenable in listeners) {
          return ListenableBuilder(
            listenable: listenable,
            builder: (context, _) => builder(context),
          );
        }
        return builder(context);
      },
    );
  }
}
