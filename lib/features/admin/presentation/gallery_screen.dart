import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/firebase_error_handler.dart';
import '../widgets/admin_app_bar.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:developer' as developer;

class GalleryImage {
  // Firebase implementation
  final String id;
  final String url;
  final int order;

  // Local assets implementation
  final String? assetPath;

  GalleryImage({
    this.id = '',  // Default empty string for local assets
    this.url = '',  // Default empty string for local assets
    required this.order,
    this.assetPath,  // Optional for Firebase implementation
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json, String id) {
    return GalleryImage(
      id: id,
      url: json['url'] as String,
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'order': order,
    };
  }
}

// Local assets implementation
final localGalleryImages = [
  GalleryImage(assetPath: 'assets/gallery/image1.jpg', order: 0),
  GalleryImage(assetPath: 'assets/gallery/image2.jpg', order: 1),
  // GalleryImage(assetPath: 'assets/gallery/image3.jpg', order: 2),
  // Add more images as needed
];

// Firebase implementation (commented out but preserved)
/*
final galleryImagesProvider = StreamProvider<List<GalleryImage>>((ref) {
  return FirebaseFirestore.instance
      .collection('gallery')
      .orderBy('order')
      .snapshots()
      .handleError((error, stackTrace) {
        handleFirebaseError(error, stackTrace);
        return const Stream.empty();
      })
      .map((snapshot) => snapshot.docs
          .map((doc) => GalleryImage.fromJson(doc.data(), doc.id))
          .toList());
});
*/

// Local assets implementation using StreamProvider for compatibility
final galleryImagesProvider = StreamProvider<List<GalleryImage>>((ref) {
  // Create a stream that emits the local gallery images once
  return Stream.value(localGalleryImages);
});

class GalleryAdminView extends ConsumerWidget {
  const GalleryAdminView({super.key});

  // Firebase implementation (commented out but preserved)
  /*
  Future<void> _uploadImage(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    developer.log('Starting image upload process', name: 'GalleryUpload');
    
    try {
      final picker = ImagePicker();
      developer.log('Attempting to pick image...', name: 'GalleryUpload');
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image == null) {
        developer.log('No image selected', name: 'GalleryUpload');
        return;
      }
      
      developer.log('Image selected: ${image.name}', name: 'GalleryUpload');
      final storage = FirebaseStorage.instance;
      final firestore = FirebaseFirestore.instance;
      
      try {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        developer.log('Creating storage reference: gallery/$fileName', name: 'GalleryUpload');
        final ref = storage.ref().child('gallery/$fileName');
        String url;

        if (kIsWeb) {
          developer.log('Processing web upload...', name: 'GalleryUpload');
          final bytes = await image.readAsBytes();
          developer.log('Image read as bytes: ${bytes.length} bytes', name: 'GalleryUpload');
          
          final contentType = 'image/${image.name.split('.').last}';
          developer.log('Starting upload with content type: $contentType', name: 'GalleryUpload');
          
          final uploadTask = await ref.putData(
            bytes,
            SettableMetadata(
              contentType: contentType,
              cacheControl: 'public, max-age=31536000',
            ),
          );
          
          developer.log('Upload completed, getting download URL...', name: 'GalleryUpload');
          url = await uploadTask.ref.getDownloadURL();
        } else {
          developer.log('Processing mobile upload...', name: 'GalleryUpload');
          final uploadTask = await ref.putFile(File(image.path));
          url = await uploadTask.ref.getDownloadURL();
        }

        developer.log('Got download URL: $url', name: 'GalleryUpload');
        
        developer.log('Getting gallery count...', name: 'GalleryUpload');
        final count = await firestore.collection('gallery').count().get();
        
        developer.log('Adding document to Firestore...', name: 'GalleryUpload');
        await firestore.collection('gallery').add({
          'url': url,
          'order': count.count,
          'fileName': fileName,
          'uploadedAt': FieldValue.serverTimestamp(),
        });

        developer.log('Upload process completed successfully', name: 'GalleryUpload');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.imageUploadSuccess)),
          );
        }
      } catch (e, stackTrace) {
        developer.log(
          'Error during upload process: ${e.toString()}',
          error: e,
          stackTrace: stackTrace,
          name: 'GalleryUpload'
        );
        rethrow;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error in image picker or outer process: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
        name: 'GalleryUpload'
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.imageUploadError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteImage(BuildContext context, GalleryImage image) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final storage = FirebaseStorage.instance;
      await storage.refFromURL(image.url).delete();

      await FirebaseFirestore.instance
          .collection('gallery')
          .doc(image.id)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.imageDeleteSuccess)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.imageDeleteError(e.toString()))),
        );
      }
    }
  }
  */

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final galleryAsync = ref.watch(galleryImagesProvider);
    
    return Scaffold(
      appBar: AdminAppBar(
        title: l10n.galleryTitle,
        backPath: '/admin',
      ),
      body: galleryAsync.when(
        data: (images) => GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final image = images[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: image.assetPath != null
                  ? Image.asset(
                      image.assetPath!,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      image.url,
                      fit: BoxFit.cover,
                    ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(l10n.galleryError(error.toString())),
        ),
      ),
      // Floating action button commented out since we're using local assets
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () => _uploadImage(context),
        tooltip: l10n.addPhoto,
        child: const Icon(Icons.add_photo_alternate),
      ),
      */
    );
  }
} 