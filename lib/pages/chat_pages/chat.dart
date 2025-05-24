import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/pembeli_model.dart';

class ChatPage extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final bool isAdminChat; // true jika admin yang chat ke pembeli

  ChatPage({
    required this.recipientId,
    required this.recipientName,
    required this.isAdminChat,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<GetChat> chatList = [];
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool isLoading = true;
  bool isSending = false;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    getCurrentUserId();
    loadChatMessages();
  }

  Future<void> getCurrentUserId() async {
    const storage = FlutterSecureStorage();
    currentUserId = await storage.read(key: 'user_id');
  }

  Future<void> loadChatMessages() async {
    try {
      final messages = await GetChat.getChat(widget.recipientId);
      setState(() {
        chatList = messages;
        isLoading = false;
      });
      scrollToBottom();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat pesan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final messageText = messageController.text.trim();
    messageController.clear();

    // Buat pesan sementara untuk ditampilkan langsung (optimistic update)
    final tempMessage = GetChat(
      id_pengirim: currentUserId ?? '',
      id_penerima: widget.recipientId,
      pesan: messageText,
      // Tambahkan properti lain yang diperlukan sesuai model GetChat
    );

    // Tambahkan pesan ke list dan update UI langsung
    setState(() {
      chatList.add(tempMessage);
      isSending = true;
    });

    // Scroll ke bawah langsung setelah menambah pesan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });

    try {
      // Kirim pesan ke server
      await PostChat.postChat(
        currentUserId ?? '',
        widget.recipientId,
        messageText,
      );

      // Refresh chat dari server untuk mendapatkan data yang akurat
      await loadChatMessages();
    } catch (e) {
      // Jika gagal kirim, hapus pesan sementara dari list
      setState(() {
        chatList.removeLast();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim pesan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget buildMessageBubble(GetChat message, bool isMe) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.isAdminChat ? Icons.person : Icons.support_agent,
                color: Colors.grey[600],
                size: 16,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? Colors.black : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      message.pesan,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  // Tambahkan indikator loading jika pesan sedang dikirim
                  if (isMe && isSending && chatList.last == message) ...[
                    SizedBox(width: 8),
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isMe) ...[
            SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.isAdminChat ? Icons.support_agent : Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                widget.isAdminChat ? Icons.person : Icons.support_agent,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipientName,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: loadChatMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                    : chatList.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Belum ada pesan',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Mulai percakapan dengan mengirim pesan',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      itemCount: chatList.length,
                      itemBuilder: (context, index) {
                        final message = chatList[index];
                        final isMe = message.id_pengirim == currentUserId;
                        return buildMessageBubble(message, isMe);
                      },
                    ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => sendMessage(), // Kirim dengan Enter
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: sendMessage,
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

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
