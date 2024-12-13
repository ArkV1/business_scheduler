import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/service_category.dart';
import '../models/service_addon.dart';
import '../services/category_management_service.dart';

part 'service_categories_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<List<ServiceCategory>> serviceCategories(Ref ref) {
  final categoryManagement = ref.watch(categoryManagementProvider);
  return categoryManagement.getAllServiceCategories();
}

@Riverpod(keepAlive: true)
Stream<List<ServiceCategory>> categorySubcategories(
  Ref ref,
  String categoryId,
) {
  final categoryManagement = ref.watch(categoryManagementProvider);
  return categoryManagement.getSubcategories(categoryId);
}

@Riverpod(keepAlive: true)
Stream<List<ServiceAddon>> categoryAddons(
  Ref ref,
  String categoryId,
) {
  final categoryManagement = ref.watch(categoryManagementProvider);
  return categoryManagement.getCategoryAddons(categoryId);
}