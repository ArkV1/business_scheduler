import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_link.dart';
import '../services/social_links_service.dart';

final socialLinksServiceProvider = Provider((ref) => SocialLinksService());

final socialLinksStreamProvider = StreamProvider<List<SocialLink>>((ref) {
  final service = ref.watch(socialLinksServiceProvider);
  return service.getSocialLinks();
}); 