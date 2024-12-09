import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

class Plant3DViewPage extends StatefulWidget {
  final String herbName;
  final String modelPath;
  final String mtlPath;
  final String pngPath;

  const Plant3DViewPage({
    Key? key,
    required this.herbName,
    required this.modelPath,
    required this.mtlPath,
    required this.pngPath,
  }) : super(key: key);

  @override
  _Plant3DViewPageState createState() => _Plant3DViewPageState();
}

class _Plant3DViewPageState extends State<Plant3DViewPage> {
  bool isLoading = true;
  late Object _object;
  late Scene _scene;

  @override
  void initState() {
    super.initState();
    load3DModel();
  }

  Future<void> load3DModel() async {
    try {
      _object = Object(fileName: widget.modelPath);
      _object.scale.setValues(12.0, 12.0, 12.0); // Set larger initial scale

      // Ensure that you are handling the object correctly
      setState(() {
        isLoading = false;
      });
      print('3D Model loaded successfully');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error loading 3D model assets: $e");
    }
  }

  void zoomIn() {
    setState(() {
      double currentScale = _object.scale.x;
      if (currentScale < 10.0) {
        _object.scale.setValues(
          currentScale + 0.1,
          currentScale + 0.1,
          currentScale + 0.1,
        );
      }
      _scene.camera.position.z -= 0.5;
    });
  }

  void zoomOut() {
    setState(() {
      double currentScale = _object.scale.x;
      if (currentScale > 0.5) {
        _object.scale.setValues(
          currentScale - 0.1,
          currentScale - 0.1,
          currentScale - 0.1,
        );
      }
      _scene.camera.position.z += 0.5;
    });
  }

  void resetView() {
    setState(() {
      _object.rotation.setValues(0.0, 0.0, 0.0); // Reset rotation
      _object.scale.setValues(8.0, 8.0, 8.0); // Reset scale to initial state (larger size)
      _scene.camera.position.setValues(0.0, 0.0, 12.0); // Adjusted camera position for larger model
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '${widget.herbName} - 3D View',
          style: const TextStyle(color: Color(0xFFF39C12)),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFFF39C12)),
      ),
      body: Stack(
        children: [
          // Background GIF with opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.15, // Adjust opacity here if needed (max opacity is 1.0)
              child: Image.asset(
                'assets/images/appbackgroundoptimize.gif', // Replace with the path to your GIF
                fit: BoxFit.cover, // Cover the entire screen
              ),
            ),
          ),
          // Loading indicator
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFF39C12)),
            )
          else
            Cube(
              onSceneCreated: (scene) {
                _scene = scene;
                _scene.world.add(_object);  // Ensure the object is added to the scene
                _scene.camera.position.setValues(0.0, 0.0, 12.0); // Camera position for larger model
                print("3D model added to the scene");
              },
            ),
          // Controls for zooming and resetting view
          if (!isLoading)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildControlButton(
                    icon: Icons.zoom_out,
                    label: 'Zoom Out',
                    onPressed: zoomOut,
                  ),
                  _buildControlButton(
                    icon: Icons.refresh,
                    label: 'Reset',
                    onPressed: resetView,
                  ),
                  _buildControlButton(
                    icon: Icons.zoom_in,
                    label: 'Zoom In',
                    onPressed: zoomIn,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          backgroundColor: const Color(0xFFF39C12),
          mini: true,
          onPressed: onPressed,
          child: Icon(icon, color: Colors.black),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
