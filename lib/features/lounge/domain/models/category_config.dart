import 'package:flutter/material.dart';

import 'category_item.dart';

class CategoryConfig {
  final String id;

  final String title;

  final String gridTitle;

  final String bannerTitle;

  final String bannerSubtitle;

  final String bannerImage;

  final Color primaryColor;

  final List<CategoryItem> items;

  const CategoryConfig({
    required this.id,
    required this.title,
    required this.gridTitle,
    required this.bannerTitle,
    required this.bannerSubtitle,
    required this.bannerImage,
    required this.primaryColor,
    required this.items,
  });
}