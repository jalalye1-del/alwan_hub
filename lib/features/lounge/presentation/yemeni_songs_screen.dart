import 'package:flutter/material.dart';

import 'package:alwan_hub/features/lounge/presentation/category_details_screen.dart';

class YemeniSongsScreen extends StatelessWidget {
  const YemeniSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryDetailsScreen(categoryId: 'yemeni-songs');
  }
}
