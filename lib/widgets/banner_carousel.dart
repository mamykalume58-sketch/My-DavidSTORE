import 'dart:convert';
import 'dart:math';
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

  Alignment _gradientBegin(double angleDeg) {
    final rad = angleDeg * pi / 180;
    return Alignment(-sin(rad), cos(rad));
  }

  Alignment _gradientEnd(double angleDeg) {
    final rad = angleDeg * pi / 180;
    return Alignment(sin(rad), -cos(rad));
  }

  Alignment _imageAlignment(String? position) {
    switch (position) {
      case 'top-left':
        return Alignment.topLeft;
      case 'top-center':
        return Alignment.topCenter;
      case 'top-right':
        return Alignment.topRight;
      case 'center-left':
        return Alignment.centerLeft;
      case 'center':
        return Alignment.center;
      case 'bottom-left':
        return Alignment.bottomLeft;
      case 'bottom-center':
        return Alignment.bottomCenter;
      case 'bottom-right':
        return Alignment.bottomRight;
      case 'center-right':
      default:
        return Alignment.centerRight;
    }
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
          height: 200,
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
                    final subtitle = banner['subtitle'] as String? ?? '';
                    final badge = banner['badge'] as String? ?? '';
                    final buttonText = banner['buttonText'] as String? ?? '';
                    final titleColor = _parseColor(banner['textColor'] as String?, Colors.white);
                    final subtitleColorRaw = banner['subtitleColor'] as String?;
                    final subtitleColor = (subtitleColorRaw == null || subtitleColorRaw.isEmpty)
                        ? titleColor
                        : _parseColor(subtitleColorRaw, titleColor);
                    final fallbackBg = _parseColor(banner['backgroundColor'] as String?, const Color(0xFF0057B8));
                    final gradFrom = _parseColor(banner['overlayFrom'] as String?, fallbackBg);
                    final gradTo = _parseColor(banner['overlayTo'] as String?, fallbackBg);
                    final gradAngle = (banner['overlayAngle'] as num?)?.toDouble() ?? 180;
                    final gradOpacity = (banner['overlayOpacity'] as num?)?.toDouble() ?? 0.55;
                    final imageAlign = _imageAlignment(banner['imagePosition'] as String?);
                    final zoom = 1.0 + ((banner['imageScale'] as num?)?.toDouble() ?? 0.0);
                    final accentColor = _parseColor(banner['accentColor'] as String?, const Color(0xFFD85A30));
                    final linkValue = banner['linkValue'] as String? ?? '';
                    final hasLink = linkValue.isNotEmpty;

                    Widget imageWidget = const SizedBox.shrink();
                    if (imageUrl.startsWith('data:image')) {
                      try {
                        final base64Str = imageUrl.split(',').last;
                        imageWidget = Image.memory(
                          base64Decode(base64Str),
                          fit: BoxFit.cover,
                          alignment: imageAlign,
                        );
                      } catch (_) {}
                    } else if (imageUrl.isNotEmpty) {
                      imageWidget = Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        alignment: imageAlign,
                      );
                    }

                    return GestureDetector(
                      onTap: () => _handleTap(banner),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (imageUrl.isNotEmpty)
                              Transform.scale(
                                scale: zoom,
                                alignment: imageAlign,
                                child: imageWidget,
                              ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: _gradientBegin(gradAngle),
                                  end: _gradientEnd(gradAngle),
                                  colors: [
                                    gradFrom.withValues(alpha: gradOpacity),
                                    gradTo.withValues(alpha: gradOpacity),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 20,
                              right: 20,
                              top: 16,
                              bottom: 16,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (badge.isNotEmpty) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: accentColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        badge,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  if (title.isNotEmpty)
                                    Text(
                                      title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: titleColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        height: 1.15,
                                        shadows: const [Shadow(blurRadius: 4, color: Colors.black38)],
                                      ),
                                    ),
                                  if (subtitle.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      subtitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: subtitleColor,
                                        fontSize: 12,
                                        height: 1.3,
                                        shadows: const [Shadow(blurRadius: 3, color: Colors.black38)],
                                      ),
                                    ),
                                  ],
                                  if (hasLink && buttonText.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: accentColor,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        buttonText,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
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
