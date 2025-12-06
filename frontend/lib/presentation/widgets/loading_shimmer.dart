import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  final int itemCount;
  final double height;

  const LoadingShimmer({
    super.key,
    this.itemCount = 3,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: height,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }
}

class LoadingCardShimmer extends StatelessWidget {
  const LoadingCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        child: ListTile(
          leading: CircleAvatar(backgroundColor: Colors.grey[300]),
          title: Container(
            height: 16,
            color: Colors.grey[300],
          ),
          subtitle: Container(
            height: 12,
            margin: const EdgeInsets.only(top: 8),
            color: Colors.grey[300],
          ),
        ),
      ),
    );
  }
}

