import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/pembeli_model.dart';

class ChatPage extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final bool isAdminChat;

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
  String? currentUserId;
  String? currentUserName;
  String? currentUserRole;
  Timer? pollingTimer;

  @override
  void initState() {
    super.initState();
    getCurrentUserInfo();
    pollingTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) loadChatMessages();
    });
  }

  @override
  void dispose() {
    pollingTimer?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> getCurrentUserInfo() async {
    try {
      const storage = FlutterSecureStorage();
      currentUserId = await storage.read(key: 'id');
      currentUserName = await storage.read(key: 'nama') ?? 'Saya';
      currentUserRole = await storage.read(key: 'role');

      print(
        '[DEBUG] User ID: $currentUserId, Name: $currentUserName, Role: $currentUserRole',
      );

      await loadChatMessages();
    } catch (e) {
      print('Error getting user info: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadChatMessages() async {
    try {
      final messages = await GetChat.getChat(widget.recipientId);
      if (mounted) {
        setState(() {
          chatList = messages;
          isLoading = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToBottom();
        });
      }
    } catch (e) {
      print('Error loading chat: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat pesan: $e'),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty || currentUserId == null) return;

    final messageText = messageController.text.trim();
    messageController.clear();

    // Optimistically add message to UI immediately
    final optimisticMessage = GetChat(
      id_pengirim: currentUserId!,
      id_penerima: widget.recipientId,
      pesan: messageText,
    );

    setState(() {
      chatList.add(optimisticMessage);
    });

    scrollToBottom();

    try {
      print(
        '[DEBUG] Sending message from $currentUserId to ${widget.recipientId}',
      );

      await PostChat.postChat(currentUserId!, widget.recipientId, messageText);

      await loadChatMessages();
    } catch (e) {
      print('Error sending message: $e');

      setState(() {
        chatList.removeWhere(
          (msg) => msg.id_pengirim == currentUserId && msg.pesan == messageText,
        );
      });

      // Restore message to input field
      messageController.text = messageText;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim pesan: $e'),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  bool isMyMessage(GetChat message) {
    final isMine = message.id_pengirim == currentUserId;
    print(
      '[DEBUG] Message from: ${message.id_pengirim}, Current User: $currentUserId => isMyMessage: $isMine',
    );
    return isMine;
  }

  String getSenderName(GetChat message) {
    return isMyMessage(message)
        ? (currentUserName ?? 'Saya')
        : widget.recipientName;
  }

  Widget buildMessageBubble(GetChat message) {
    final isMe = isMyMessage(message);
    final senderName = getSenderName(message);

    return Container(
      margin: EdgeInsets.only(
        left: isMe ? 60 : 16,
        right: isMe ? 16 : 60,
        top: 4,
        bottom: 4,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: isMe ? 0 : 48,
              right: isMe ? 48 : 0,
              bottom: 4,
            ),
            child: Text(
              senderName,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                Container(
                  width: 36,
                  height: 36,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: Icon(
                    _getRecipientIcon(),
                    color: Colors.grey[700],
                    size: 18,
                  ),
                ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.black87 : Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 6),
                      bottomRight: Radius.circular(isMe ? 6 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.pesan,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
              if (isMe)
                Container(
                  width: 36,
                  height: 36,
                  margin: EdgeInsets.only(left: 12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    _getCurrentUserIcon(),
                    color: Colors.white,
                    size: 18,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCurrentUserIcon() {
    if (currentUserRole == 'admin' || widget.isAdminChat) {
      return Icons.support_agent_rounded;
    } else {
      return Icons.person_rounded;
    }
  }

  IconData _getRecipientIcon() {
    return widget.isAdminChat
        ? Icons.person_rounded
        : Icons.support_agent_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black87),
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Icon(
                _getRecipientIcon(),
                color: Colors.grey[700],
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
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.black87),
            onPressed: loadChatMessages,
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.black87,
                        ),
                        strokeWidth: 2,
                      ),
                    )
                    : chatList.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Belum ada pesan',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Mulai percakapan dengan mengirim pesan',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: loadChatMessages,
                      color: Colors.black87,
                      child: ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        itemCount: chatList.length,
                        itemBuilder:
                            (context, index) =>
                                buildMessageBubble(chatList[index]),
                      ),
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
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan...',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => sendMessage(),
                        enabled: currentUserId != null,
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: currentUserId == null ? null : sendMessage,
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
