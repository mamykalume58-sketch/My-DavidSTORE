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
  _ChatMessage({required this.role, required this.text, this.products = const []});
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  static const String _apiUrl =
      'https://davidstore-payment.vercel.app/api/support-chat';

  Widget _buildProductImage(String? source) {
    if (source == null || source.isEmpty) {
      return Container(
        color: Colors.grey.shade100,
        alignment: Alignment.center,
        child: const Text('📦', style: TextStyle(fontSize: 28)),
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
        color: Colors.grey.shade100,
        alignment: Alignment.center,
        child: const Text('📦', style: TextStyle(fontSize: 28)),
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
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
          ));
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(
          role: 'model',
          text: "Impossible de me contacter pour le moment. Vérifie ta connexion.",
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Nicole — Assistante DAVIDSTORE',
            style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 15)),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        "Bonjour 👋 Je suis Nicole, de l'équipe DAVIDSTORE.\nPose-moi une question sur nos produits, commandes ou livraisons.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg.role == 'user';
                      return Column(
                        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              decoration: BoxDecoration(
                                color: isUser ? theme.primaryColor : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Text(
                                msg.text,
                                style: TextStyle(color: isUser ? Colors.white : const Color(0xFF1E293B), fontSize: 14),
                              ),
                            ),
                          ),
                          if (msg.products.isNotEmpty)
                            SizedBox(
                              height: 190,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: msg.products.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 10),
                                itemBuilder: (context, i) {
                                  final p = msg.products[i];
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
                                            height: 90,
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
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${p.price} FC',
                                                style: TextStyle(fontSize: 11, color: theme.primaryColor, fontWeight: FontWeight.w700),
                                              ),
                                              const SizedBox(height: 6),
                                              SizedBox(
                                                width: double.infinity,
                                                child: OutlinedButton(
                                                  style: OutlinedButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                                    minimumSize: const Size(0, 28),
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
                                                  child: const Text('Voir', style: TextStyle(fontSize: 11)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Écris ton message...',
                        filled: true,
                        fillColor: Colors.white,
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
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
