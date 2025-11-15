import 'package:flutter/material.dart';
import 'data.dart';
import 'home_screen.dart';
import 'cluster_screen.dart';
import 'photo_detail_screen.dart';

void main() {
  runApp(const PhotoGalleryApp());
}

class PhotoGalleryApp extends StatelessWidget {
  const PhotoGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Photo Gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 4,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        // ClusterScreen expects a Cluster object as an argument
        ClusterScreen.routeName: (context) => const ClusterScreen(),
        // PhotoDetailScreen expects a Photo object and a callback
        PhotoDetailScreen.routeName: (context) => const PhotoDetailScreen(),
      },
    );
  }
}