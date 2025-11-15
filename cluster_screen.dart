import 'package:flutter/material.dart';
import 'data.dart';
import 'photo_detail_screen.dart';

class ClusterScreen extends StatefulWidget {
  static const routeName = '/cluster-photos';

  const ClusterScreen({super.key});

  @override
  State<ClusterScreen> createState() => _ClusterScreenState();
}

class _ClusterScreenState extends State<ClusterScreen> {
  // We use setState to rebuild the screen when a photo is deleted.
  void _onPhotoDeleted() {
    setState(() {
      // Rebuilds the widget, causing getClusterPhotos to run again
      // and update the displayed list.
    });
  }

  @override
  Widget build(BuildContext context) {
    // Extract the Cluster object passed from HomeScreen
    final cluster = ModalRoute.of(context)!.settings.arguments as Cluster;

    // Get the current list of non-deleted photos
    final photos = getClusterPhotos(cluster.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(cluster.name),
      ),
      body: photos.isEmpty
          ? const Center(
        child: Text(
          'This cluster is empty!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final photo = photos[index];
          return GestureDetector(
            onTap: () {
              // Navigate to the PhotoDetailScreen
              // Pass the photo and the callback function
              Navigator.pushNamed(
                context,
                PhotoDetailScreen.routeName,
                arguments: {
                  'photo': photo,
                  'onDelete': _onPhotoDeleted,
                },
              );
            },
            child: Hero(
              tag: photo.id, // For a smooth transition effect
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    photo.url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.red),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}