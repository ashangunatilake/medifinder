import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  FullScreenImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              InteractiveViewer(
                child: imageUrl.startsWith('http')
                    ? Image.network(
                    imageUrl,
                    fit: BoxFit.fill,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
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
                )
                    : Image.asset(imageUrl),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.black, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
