import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'data.dart';
import 'cluster_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // Function to handle opening the camera
  Future<void> _openCamera() async {
    try {
      // Create an instance of ImagePicker
      final picker = ImagePicker();

      // Use picker.pickImage to launch the camera
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        // Add the new photo to our mock data structure
        addNewPhoto(photo.path);

        // Refresh the UI to show the new cluster count/image
        setState(() {});

        // Inform the user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo captured and added to "Vacation 2024" cluster!'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No photo was taken.'),
            ),
          );
        }
      }
    } catch (e) {
      // Handle permission errors or other exceptions
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening camera or missing permissions.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Gallery Clusters'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0, // Make the cards square
        ),

        itemCount: allClusters.length,
        itemBuilder: (context, index) {
          final cluster = allClusters[index];
          return ClusterCard(
            cluster: cluster,
            // Pass a key so Flutter knows to rebuild the card when a new photo is added
            key: ValueKey(cluster.id),
          );
        },
      ),
      // Floating action button to open the camera
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCamera,
        label: const Text('New Photo'),
        icon: const Icon(Icons.camera_alt),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class ClusterCard extends StatelessWidget {
  final Cluster cluster;
  const ClusterCard({required this.cluster, super.key});

  @override
  Widget build(BuildContext context) {

    final clusterPhotos = getClusterPhotos(cluster.id);
    final photoCount = clusterPhotos.length;

    // Use the first photo's URL as the cover, or a placeholder if empty
    final coverImageUrl = clusterPhotos.isNotEmpty
        ? clusterPhotos.first.url
        : 'https://placehold.co/300x300/cccccc/333333?text=Empty';

    // Placeholder Icon for Video Cluster
    final isVideoCluster = cluster.clusterType == ClusterType.videos;
    final placeholderIcon = isVideoCluster ? Icons.videocam : Icons.folder;


    return InkWell(
      onTap: () {
        // Navigate to the ClusterScreen, passing the selected Cluster
        Navigator.pushNamed(
          context,
          ClusterScreen.routeName,
          arguments: cluster,
        );
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Card(
        clipBehavior: Clip.antiAlias, // Ensures the image respects border radius
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Cluster Cover Image
            Image.network(
              coverImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(
                // Use a different icon for the video cluster placeholder
                child: Icon(placeholderIcon, size: 80, color: Colors.blueGrey),
              ),
            ),
            // Gradient Overlay for readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            // Cluster Name and Count
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cluster.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$photoCount ${isVideoCluster ? 'Videos' : 'Photos'}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}