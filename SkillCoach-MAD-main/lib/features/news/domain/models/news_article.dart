import 'package:flutter/material.dart';

class NewsArticle {
  final String title;
  final String category;
  final String description;
  final IconData icon;
  final Color color;
  final String date;
  final String readTime;
  final String url;

  const NewsArticle({
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
    required this.color,
    required this.date,
    required this.readTime,
    required this.url,
  });
}
