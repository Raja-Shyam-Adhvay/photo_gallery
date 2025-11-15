import 'package:flutter/material.dart';
import 'data.dart';


class PhotoDetailScreen extends StatefulWidget {
  static const routeName = '/photo-detail';

  const PhotoDetailScreen({super.key});

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late Photo _photo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize photo from arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _photo = args['photo'] as Photo;
  }

  // Function to simulate editing the photo caption
  Future<void> _handleEditCaption() async {
    // Use the photo's current caption for the initial value
    final TextEditingController controller = TextEditingController(text: _photo.caption);

    final newCaption = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Photo Caption'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'New Caption'),
          // The onSubmitted handler is optional, but convenient
          onSubmitted: (value) => Navigator.of(ctx).pop(value),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );

    // Check if a new caption was provided and it's different
    if (newCaption != null && newCaption.isNotEmpty && newCaption != _photo.caption) {
      // 1. Update the photo object (now possible since 'caption' is non-final in data.dart)
      setState(() {
        _photo.caption = newCaption;
      });

      // 2. Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Caption updated!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // The title now uses the state variable
        title: Text(_photo.caption),
      ),
      // The body uses InteractiveViewer for zoom and pan functionality
      body: Center(
        child: InteractiveViewer(
          maxScale: 4.0,
          minScale: 1.0,
          child: Hero(
            tag: _photo.id,
            child: Image.network(
              _photo.url,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.error_outline, size: 100, color: Colors.red),
              ),
            ),
          ),
        ),
      ),
      // Action buttons in a clean bottom area
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Edit Caption Button
            Tooltip(
              message: 'Edit Caption',
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.blueGrey),
                iconSize: 30,
                onPressed: _handleEditCaption, // Call the stateful function
              ),
            ),
            // Zoom/Pan Info (just informational)
            const Row(
              children: [
                Icon(Icons.zoom_in_map, color: Colors.blueGrey),
                SizedBox(width: 8),
                Text('Pinch to Zoom/Pan'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}