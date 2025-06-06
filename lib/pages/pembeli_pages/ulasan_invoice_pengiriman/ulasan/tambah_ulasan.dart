import 'package:flutter/material.dart';
import 'package:frontend/models/pembeli_model.dart';
import 'package:toastification/toastification.dart';

class TambahUlasan extends StatefulWidget {
  final String idProduk;
  final String idVarianProduk;

  const TambahUlasan({
    super.key,
    required this.idProduk,
    required this.idVarianProduk,
  });

  @override
  State<TambahUlasan> createState() => _TambahUlasanState();
}

class _TambahUlasanState extends State<TambahUlasan> {
  int selectedRating = 0;
  final TextEditingController _komentarController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _komentarController.dispose();
    super.dispose();
  }

  Future<void> _kirimUlasan() async {
    if (selectedRating == 0) {
      toastification.show(
        context: context,
        title: const Text('Silakan pilih rating terlebih dahulu'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.bottomCenter,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return;
    }

    if (_komentarController.text.trim().isEmpty) {
      toastification.show(
        context: context,
        title: const Text('Silakan masukkan komentar'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.bottomCenter,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await PostKomentar.kirimKomentar(
        idProduk: widget.idProduk,
        idVarianProduk: widget.idVarianProduk,
        rating: selectedRating.toString(),
        komentar: _komentarController.text.trim(),
      );

      if (mounted) {
        toastification.show(
          context: context,
          title: Text(result.pesan),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.bottomCenter,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          title: Text(e.toString().replaceAll('Exception: ', '')),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 4),
          alignment: Alignment.bottomCenter,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final rating = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedRating = rating;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    selectedRating >= rating
                        ? Colors.black
                        : Colors.grey.shade400,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
              color: selectedRating >= rating ? Colors.black : Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color:
                      selectedRating >= rating
                          ? Colors.white
                          : Colors.grey.shade400,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  rating.toString(),
                  style: TextStyle(
                    color:
                        selectedRating >= rating
                            ? Colors.white
                            : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Produk Ulasan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating Section
            const Text(
              'Rating',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            _buildRatingStars(),
            const SizedBox(height: 32),

            // Comment Section
            const Text(
              'Komentar / Ulasan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _komentarController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Tulis komentar atau ulasan Anda...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ),

            const Spacer(),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _kirimUlasan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Text(
                          'Kirim',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
