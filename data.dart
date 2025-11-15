import 'package:flutter/material.dart';


/// Defines the source where the photo originated.
enum PhotoSource { camera, download, social, album }

/// Defines the type of media file.
enum MediaType { image, video }


/// Represents a single photo item.
class Photo {
  final String id;
  final String url;

  String caption;
  bool isDeleted;
  bool isFavorite;

  // Smart Clustering
  final PhotoSource source;
  final MediaType type;

  Photo({
    required this.id,
    required this.url,
    this.caption = 'No Caption',
    this.isDeleted = false,
    this.isFavorite = false,
    this.source = PhotoSource.album,
    this.type = MediaType.image,
  });
}

/// Defines if a cluster is a manual album or a smart/filtered category.
enum ClusterType {
  album,
  allPhotos,
  camera,
  download,
  social,
  videos,
}

/// Represents a group or cluster of photos (an album).
class Cluster {
  final String id;
  final String name;
  final List<String> photoIds; // Used only for ClusterType.album
  final ClusterType clusterType; // Defines the filtering logic

  Cluster({
    required this.id,
    required this.name,
    required this.photoIds,
    this.clusterType = ClusterType.album,
  });
}

// Mock Data Service (Centralized Photo Storage)

// Using a Map for O(1) lookup and easy state updates
final Map<String, Photo> _photoMap = {
  // Photos with different sources
  'p1': Photo(id: 'p1', url: 'https://picsum.photos/id/1018/300/300', caption: 'Nature Trail', source: PhotoSource.camera),
  'p2': Photo(id: 'p2', url: 'https://picsum.photos/id/1020/300/300', caption: 'Mountain View', source: PhotoSource.camera),
  'p3': Photo(id: 'p3', url: 'https://picsum.photos/id/1035/300/300', caption: 'Night City', source: PhotoSource.social),
  'p4': Photo(id: 'p4', url: 'https://picsum.photos/id/1043/300/300', caption: 'Old Bridge', source: PhotoSource.download),
  'p5': Photo(id: 'p5', url: 'https://picsum.photos/id/1054/300/300', caption: 'Beach Sunset', source: PhotoSource.download),
  'p6': Photo(id: 'p6', url: 'https://picsum.photos/id/1063/300/300', caption: 'Forest Path', source: PhotoSource.camera),
  'p7': Photo(id: 'p7', url: 'https://picsum.photos/id/1074/300/300', caption: 'Desert Road', source: PhotoSource.social),
  'p8': Photo(id: 'p8', url: 'https://picsum.photos/id/1084/300/300', caption: 'Rainy Street', source: PhotoSource.camera),
  'p9': Photo(id: 'p9', url: 'https://picsum.photos/id/1090/300/300', caption: 'Coffee Time', source: PhotoSource.social),
  'p10': Photo(id: 'p10', url: 'https://picsum.photos/id/111/300/300', caption: 'Abstract Art', source: PhotoSource.album),

  // Video mock data
  'v1': Photo(id: 'v1', url: 'https://placehold.co/300x300/003366/ffffff?text=Video+1', caption: 'Travel Vlog Clip', source: PhotoSource.camera, type: MediaType.video),
  'v2': Photo(id: 'v2', url: 'https://placehold.co/300x300/336600/ffffff?text=Video+2', caption: 'Funny Cat Video', source: PhotoSource.social, type: MediaType.video),
};


// Global List of ALL Clusters (Albums and Smart Filters)

final List<Cluster> allClusters = [
  //  Smart Clusters (listed first for priority in Home Screen)
  Cluster(id: 's1', name: 'All Photos', photoIds: const [], clusterType: ClusterType.allPhotos),
  Cluster(id: 's5', name: 'Videos', photoIds: const [], clusterType: ClusterType.videos),
  Cluster(id: 's2', name: 'Camera Roll', photoIds: const [], clusterType: ClusterType.camera),
  Cluster(id: 's3', name: 'Downloads', photoIds: const [], clusterType: ClusterType.download),
  Cluster(id: 's4', name: 'Social Media', photoIds: const [], clusterType: ClusterType.social),

  // Existing Manual Albums
  Cluster(id: 'c1', name: 'Vacation 2024', photoIds: ['p1', 'p2', 'p3', 'p4', 'v1'], clusterType: ClusterType.album),
  Cluster(id: 'c2', name: 'Family & Friends', photoIds: ['p5', 'p6', 'p7', 'v2'], clusterType: ClusterType.album),
  Cluster(id: 'c3', name: 'Miscellaneous', photoIds: ['p8', 'p9', 'p10'], clusterType: ClusterType.album),
];

// Global function to retrieve the list of photos for a cluster (now handles filtering)
List<Photo> getClusterPhotos(String clusterId) {
  final cluster = allClusters.firstWhere((c) => c.id == clusterId);
  final allNonDeletedPhotos = _photoMap.values.where((p) => !p.isDeleted);

  // Filtering logic based on ClusterType
  switch (cluster.clusterType) {
    case ClusterType.allPhotos:
      return allNonDeletedPhotos.toList();

    case ClusterType.camera:
      return allNonDeletedPhotos.where((p) => p.source == PhotoSource.camera).toList();

    case ClusterType.download:
      return allNonDeletedPhotos.where((p) => p.source == PhotoSource.download).toList();

    case ClusterType.social:
      return allNonDeletedPhotos.where((p) => p.source == PhotoSource.social).toList();

    case ClusterType.videos:
      return allNonDeletedPhotos.where((p) => p.type == MediaType.video).toList();

    case ClusterType.album:
    default:
    // Return photos based on photoIds list (for manually defined clusters)
      return cluster.photoIds
          .map((id) => _photoMap[id])
          .where((photo) => photo != null && !photo.isDeleted)
          .cast<Photo>()
          .toList();
  }
}

/// Marks a list of photos as deleted (Batch Operation).
void deletePhotos(List<String> photoIds) {
  for (final id in photoIds) {
    if (_photoMap.containsKey(id)) {
      _photoMap[id]!.isDeleted = true;
    }
  }
  debugPrint('Deleted ${photoIds.length} photos.');
}

///  Global function to add a new photo, setting source to camera.
void addNewPhoto(String path) {
  final newId = 'p${_photoMap.length + 1}';
  // Use a placeholder URL for display, as the actual local path won't work
  // with Image.network outside of a device.
  final placeholderUrl = 'https://placehold.co/300x300/ffbb00/000000?text=New+Pic';

  final newPhoto = Photo(
    id: newId,
    url: placeholderUrl,
    caption: 'New Photo ${DateTime.now().second}',
    source: PhotoSource.camera, // New photo is always from the camera
    type: MediaType.image,
  );
  _photoMap[newId] = newPhoto;

  // For demonstration, we also add it to the first manual album (c1)
  final cluster1 = allClusters.firstWhere((c) => c.id == 'c1');
  cluster1.photoIds.insert(0, newId); // Add to the start
  debugPrint('New photo $newId added to cluster ${cluster1.name}.');
}