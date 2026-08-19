import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerCarousel extends StatefulWidget {
  final void Function(String category) onCategoryTap;
  final void Function(String productId) onProductTap;

  const BannerCarousel({
    super.key,
    required this.onCategoryTap,
    required this.onProductTap,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  Future<void> _handleTap(Map<String, dynamic> banner) async {
    final linkType = banner['linkType'] as String? ?? 'none';
    final linkValue = banner['linkValue'] as String? ?? '';
    if (linkValue.isEmpty) return;

    if (linkType == 'category') {
      widget.onCategoryTap(linkValue);
    } else if (linkType == 'product') {
      widget.onProductTap(linkValue);
    } else if (linkType == 'url') {
      final uri = Uri.tryParse(linkValue);
      if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Color _parseColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse('FF$cleaned', radix: 16);
    return value != null ? Color(value) : fallback;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('banners')
          .where('active', isEqualTo: true)
          .orderBy('order')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final banners = snapshot.data!.docs.map((d) => d.data()).toList();

        return SizedBox(
          height: 150,
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: banners.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    final imageUrl = banner['imageUrl'] as String? ?? '';
                    final title = banner['title'] as String? ?? '';
                    final textColor = _parseColor(banner['textColor'] as String?, Colors.white);
                    final bgColor = _parseColor(banner['backgroundColor'] as String?, const Color(0xFF2563EB));

                    Widget imageWidget = const SizedBox.shrink();
                    if (imageUrl.startsWith('data:image')) {
                      try {
                        final base64Str = imageUrl.split(',').last;
                        imageWidget = Image.memory(base64Decode(base64Str), fit: BoxFit.cover);
                      } catch (_) {}
                    } else if (imageUrl.isNotEmpty) {
                      imageWidget = Image.network(imageUrl, fit: BoxFit.cover);
                    }

                    return GestureDetector(
                      onTap: () => _handleTap(banner),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: bgColor,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Opacity(opacity: 0.9, child: imageWidget),
                            Positioned(
                              left: 16,
                              bottom: 16,
                              right: 16,
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: const [Shadow(blurRadius: 4, color: Colors.black38)],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (banners.length > 1) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(banners.length, (i) {
                    final isActive = i == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF2563EB) : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
