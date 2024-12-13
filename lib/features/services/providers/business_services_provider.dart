import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/business_service.dart';
import '../services/service_management_service.dart';

final businessServicesProvider = StreamProvider<List<BusinessService>>((ref) {
  final serviceManagement = ref.watch(businessServiceManagementProvider);
  return serviceManagement.getActiveBusinessServices();
}); 