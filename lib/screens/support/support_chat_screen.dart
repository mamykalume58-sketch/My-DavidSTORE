import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/product.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SuggestedProduct {
  final String id;
  final String name;
  final String category;
  final int price;
  final int? promoPrice;
  final String? image;
  final String description;

  _SuggestedProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.promoPrice,
    this.image,
    required this.description,
  });

  factory _SuggestedProduct.fromJson(Map<String, dynamic> json) {
    return _SuggestedProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: json['price'] ?? 0,
      promoPrice: json['promoPrice'],
      image: json['image'],
      description: json['description'] ?? '',
    );
  }
}

class _ChatMessage {
  final String role; // 'user' ou 'model'
  final String text;
  final List<_SuggestedProduct> products;
  final bool isError;
  _ChatMessage({
    required this.role,
    required this.text,
    this.products = const [],
    this.isError = false,
  });
}

const _kBg = Color(0xFFF4F6F9);
const _kInk = Color(0xFF1E293B);
const _kMuted = Color(0xFF64748B);
const _kOnline = Color(0xFF22C55E);

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  static const String _apiUrl =
      'https://davidstore-payment.vercel.app/api/support-chat';

  static const List<String> _quickReplies = [
    'Voir les promos',
    'Suivre ma commande',
    'Parler à un humain',
  ];

  Widget _buildProductImage(String? source) {
    if (source == null || source.isEmpty) {
      return Container(
        color: const Color(0xFFF1F5F9),
        alignment: Alignment.center,
        child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 26),
      );
    }
    try {
      if (source.startsWith('data:image')) {
        final base64Str = source.split(',').last;
        return Image.memory(base64Decode(base64Str), fit: BoxFit.cover);
      } else if (source.startsWith('http')) {
        return Image.network(source, fit: BoxFit.cover);
      } else {
        return Image.memory(base64Decode(source), fit: BoxFit.cover);
      }
    } catch (_) {
      return Container(
        color: const Color(0xFFF1F5F9),
        alignment: Alignment.center,
        child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 26),
      );
    }
  }

  Future<void> _sendMessage([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(role: 'user', text: text));
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final history = _messages
          .sublist(0, _messages.length - 1)
          .map((m) => {
                'role': m.role,
                'parts': [
                  {'text': m.text}
                ],
              })
          .toList();

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text, 'history': history}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final productsJson = (data['products'] as List?) ?? [];
        final products = productsJson
            .map((p) => _SuggestedProduct.fromJson(p as Map<String, dynamic>))
            .toList();

        setState(() {
          _messages.add(_ChatMessage(
            role: 'model',
            text: data['reply'] ?? '',
            products: products,
          ));
        });
      } else {
        setState(() {
          _messages.add(_ChatMessage(
            role: 'model',
            text: "Désolée, une erreur est survenue. Réessaie ou contacte le support WhatsApp.",
            isError: true,
          ));
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          role: 'model',
          text: "Impossible de me contacter pour le moment. Vérifie ta connexion.",
          isError: true,
        ));
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _avatar({double size = 34}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF3D4FE0),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'N',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.42,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            _avatar(),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nicole',
                      style: TextStyle(color: _kInk, fontWeight: FontWeight.w700, fontSize: 15)),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(color: _kOnline, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      const Text('Conseillère DavidSTORE',
                          style: TextStyle(color: _kMuted, fontSize: 11.5, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: _kInk),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE7EAF0)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _buildTypingRow();
                      }
                      final msg = _messages[index];
                      final isUser = msg.role == 'user';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment:
                              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (!isUser) ...[
                                  _avatar(size: 26),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.72),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? theme.primaryColor
                                          : msg.isError
                                              ? const Color(0xFFFFF1F0)
                                              : Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                                        bottomRight: Radius.circular(isUser ? 4 : 16),
                                      ),
                                      border: msg.isError
                                          ? Border.all(color: const Color(0xFFFFD4D0))
                                          : null,
                                      boxShadow: isUser || msg.isError
                                          ? null
                                          : [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.04),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                    ),
                                    child: Text(
                                      msg.text,
                                      style: TextStyle(
                                        color: isUser
                                            ? Colors.white
                                            : msg.isError
                                                ? const Color(0xFFB3261E)
                                                : _kInk,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (msg.products.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 210,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.only(left: 34),
                                  itemCount: msg.products.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                                  itemBuilder: (context, i) => _buildProductCard(msg.products[i]),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
          _buildInputBar(theme),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      children: [
        _avatar(size: 56),
        const SizedBox(height: 16),
        const Text(
          'Bonjour, je suis Nicole 👋',
          textAlign: TextAlign.center,
          style: TextStyle(color: _kInk, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          "Votre conseillère DavidSTORE. Posez-moi une question sur nos produits,\nvos commandes ou la livraison.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5, height: 1.5),
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: _quickReplies
              .map((label) => OutlinedButton(
                    onPressed: () => _sendMessage(label),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kInk,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTypingRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _avatar(size: 26),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(_SuggestedProduct p) {
    final hasPromo = p.promoPrice != null && p.promoPrice! > 0 && p.promoPrice! < p.price;
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: SizedBox(
              height: 92,
              width: double.infinity,
              child: _buildProductImage(p.image),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _kInk),
                ),
                const SizedBox(height: 3),
                if (hasPromo) ...[
                  Row(
                    children: [
                      Text(
                        '${p.price} FC',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${p.promoPrice} FC',
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFFD8402A), fontWeight: FontWeight.w700),
                  ),
                ] else
                  Text(
                    '${p.price} FC',
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF3D4FE0), fontWeight: FontWeight.w700),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kInk,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      minimumSize: const Size(0, 30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/product',
                        arguments: Product.fromMap({
                          'id': p.id,
                          'name': p.name,
                          'price': p.price,
                          'promoPrice': p.promoPrice,
                          'category': p.category,
                          'description': p.description,
                          'images': p.image != null ? [p.image] : [],
                          'stock': 1,
                          'active': true,
                        }),
                      );
                    },
                    child: const Text('Voir le produit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(ThemeData theme) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE7EAF0))),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Écrivez votre message...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  filled: true,
                  fillColor: _kBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: _isLoading ? null : () => _sendMessage(),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isLoading ? theme.primaryColor.withValues(alpha: 0.4) : theme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 8,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) {
              final t = (_controller.value - (i * 0.2)) % 1.0;
              final scale = 0.6 + 0.4 * (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(color: Color(0xFF94A3B8), shape: BoxShape.circle),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
