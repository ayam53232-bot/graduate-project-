import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState
    extends State<ChatScreen> {
  final TextEditingController controller =
  TextEditingController();

  final List<Map<String, String>> messages =
  [];

  bool isLoading = false;

  final String apiKey =
      'AQ.Ab8RN6L1DO3mIEJLc5pMy-Tl3XF1Wx10-UfJkOQXOZ_AK7bODQ';

  Future<void> sendMessage() async {
    final text = controller.text.trim();

    if (text.isEmpty || isLoading) {
      return;
    }

    setState(() {
      messages.add({
        'role': 'user',
        'content': text,
      });

      controller.clear();
      isLoading = true;
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-3.5-flash',
        apiKey: apiKey,
      );

      final response =
      await model.generateContent([
        Content.text(text),
      ]);

      setState(() {
        messages.add({
          'role': 'ai',
          'content':
          response.text ??
              'No response returned.',
        });
      });
    } catch (e) {
      setState(() {
        messages.add({
          'role': 'ai',
          'content': 'Error: $e',
        });
      });
    }
    finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Chat Assistant',
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
              child: Text(
                'Ask me anything 🤖',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            )
                : ListView.builder(
              padding:
              const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder:
                  (context, index) {
                final message =
                messages[index];

                final isUser =
                    message['role'] ==
                        'user';

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints:
                    BoxConstraints(
                      maxWidth:
                      MediaQuery.of(
                        context,
                      ).size.width *
                          0.75,
                    ),
                    margin:
                    const EdgeInsets.only(
                      bottom: 8,
                    ),
                    padding:
                    const EdgeInsets.all(
                      12,
                    ),
                    decoration:
                    BoxDecoration(
                      color: isUser
                          ? Colors.blue
                          : Colors.grey.shade300,
                      borderRadius:
                      BorderRadius.circular(
                        15,
                      ),
                    ),
                    child: Text(
                      message['content'] ??
                          '',
                      style: TextStyle(
                        color: isUser
                            ? Colors.white
                            : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration:
                    InputDecoration(
                      hintText:
                      'Type your message...',
                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                          20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  child: IconButton(
                    onPressed: isLoading
                        ? null
                        : sendMessage,
                    icon: const Icon(
                      Icons.send,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}