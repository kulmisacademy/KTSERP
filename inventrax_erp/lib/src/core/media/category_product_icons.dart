import 'package:flutter/material.dart';

/// Retail category icons for product cards when no photo is set.
class CategoryProductIcons {
  CategoryProductIcons._();

  static const choices = <({String id, String label, IconData icon})>[
    (id: 'box', label: 'Box', icon: Icons.inventory_2_outlined),
    (id: 'bag', label: 'Bag', icon: Icons.shopping_bag_outlined),
    (id: 'grocery', label: 'Grocery', icon: Icons.shopping_cart_outlined),
    (id: 'food', label: 'Food', icon: Icons.restaurant_outlined),
    (id: 'bottle', label: 'Drink', icon: Icons.local_drink_outlined),
    (id: 'phone', label: 'Phone', icon: Icons.phone_android_outlined),
    (id: 'laptop', label: 'Laptop', icon: Icons.laptop_outlined),
    (id: 'med', label: 'Pharmacy', icon: Icons.medical_services_outlined),
    (id: 'shirt', label: 'Clothing', icon: Icons.checkroom_outlined),
    (id: 'shoe', label: 'Shoes', icon: Icons.hiking_outlined),
    (id: 'beauty', label: 'Beauty', icon: Icons.spa_outlined),
    (id: 'tools', label: 'Tools', icon: Icons.handyman_outlined),
    (id: 'car', label: 'Auto', icon: Icons.directions_car_outlined),
  ];

  static IconData iconForId(String? id) {
    if (id == null || id.isEmpty) return Icons.inventory_2_outlined;
    for (final c in choices) {
      if (c.id == id) return c.icon;
    }
    return Icons.inventory_2_outlined;
  }

  static String? parseLegacyIconPath(String? imagePath) {
    if (imagePath == null) return null;
    final v = imagePath.trim();
    if (!v.startsWith('icon:')) return null;
    final id = v.substring('icon:'.length).trim();
    return id.isEmpty ? null : id;
  }
}
