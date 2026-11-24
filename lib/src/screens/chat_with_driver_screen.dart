import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

// BACKEND-NEEDED: Real-time in-app driver messaging and push dispatch API

class ChatMessage {
  final String id;
  final String text;
  final bool isFromCustomer;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isFromCustomer,
    required this.timestamp,
  });
}

class ChatWithDriverScreen extends StatefulWidget {
  final String driverName;
  final String? driverPhone;
  final String orderId;

  const ChatWithDriverScreen({
    super.key,
    required this.driverName,
    this.driverPhone,
    required this.orderId,
  });

  @override
  State<ChatWithDriverScreen> createState() => _ChatWithDriverScreenState();
}

class _ChatWithDriverScreenState extends State<ChatWithDriverScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: 'm-1',
      text: 'Hi! I have picked up your order and I am on my way.',
      isFromCustomer: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  static const List<String> quickReplies = [
    'I am waiting at the gate.',
    'Please leave it at the door.',
    'Please call before ringing bell.',
    'Take the elevator to 3rd floor.',
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(
        ChatMessage(
          id: 'm-${DateTime.now().millisecondsSinceEpoch}',
          text: text.trim(),
          isFromCustomer: true,
          timestamp: DateTime.now(),
        ),
      );
      _msgCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.driverName, style: const TextStyle(fontSize: 16)),
            const Text('Delivery Partner • Active en route', style: TextStyle(fontSize: 11, color: Colors.green)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isFromCustomer ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: msg.isFromCustomer ? AllGoColors.primary : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: msg.isFromCustomer ? AllGoColors.primary : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isFromCustomer ? Colors.white : AllGoColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Quick Replies
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: quickReplies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final reply = quickReplies[i];
                return ActionChip(
                  label: Text(reply, style: const TextStyle(fontSize: 11)),
                  onPressed: () => _sendMessage(reply),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Theme.of(context).cardColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Type a message to your partner...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: AllGoColors.primary),
                  tooltip: 'Send message',
                  onPressed: () => _sendMessage(_msgCtrl.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
