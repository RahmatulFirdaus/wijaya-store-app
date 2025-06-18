import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TampilVideoProduk extends StatefulWidget {
  final String videoUrl;
  final String productName;

  const TampilVideoProduk({
    super.key,
    required this.videoUrl,
    required this.productName,
  });

  @override
  State<TampilVideoProduk> createState() => _TampilVideoProdukState();
}

class _TampilVideoProdukState extends State<TampilVideoProduk> {
  late VideoPlayerController _controller;
  final String baseUrl = 'http://192.168.1.96:3000/uploads/';
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    // Gabungkan base URL dengan video URL dari parameter
    String fullVideoUrl = baseUrl + widget.videoUrl;

    _controller = VideoPlayerController.network(fullVideoUrl)
      ..initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              _controller.play(); // otomatis play
            }
          })
          .catchError((error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
                _errorMessage = 'Gagal memuat video: $error';
              });
            }
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Video: ${widget.productName}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child:
            _isLoading
                ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Memuat video...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )
                : _hasError
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                          _isLoading = true;
                        });
                        _controller.dispose();
                        _initializeVideo();
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                )
                : _controller.value.isInitialized
                ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
                : const CircularProgressIndicator(color: Colors.white),
      ),
      floatingActionButton:
          !_isLoading && !_hasError && _controller.value.isInitialized
              ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                backgroundColor: Colors.white,
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.black,
                ),
              )
              : null,
    );
  }
}
