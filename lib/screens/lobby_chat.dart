import 'package:baseapp/screens/lobbylist_page.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LobbyChat extends StatefulWidget {
  final String lobbyId;
  final String lobbyName;
  final String className;
  final String school;
  final String username;
  final bool isHost;
  final int maxUsers;
  final int currentUsers;

  const LobbyChat({
    Key? key,
    required this.lobbyId,
    required this.lobbyName,
    required this.className,
    required this.school,
    required this.username,
    required this.isHost,
    required this.maxUsers,
    required this.currentUsers,
  }) : super(key: key);

  @override
  _LobbyChatState createState() => _LobbyChatState();
}

class _LobbyChatState extends State<LobbyChat> {
  late IO.Socket socket;
  List<ChatMessage> messages = [];
  List<String> activeUsers = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }

  void _initializeSocket() {
    socket = IO.io('https://studybuddy.ddns.net', {
      'transports': ['websocket'],
      'autoConnect': true,
      'auth': {
        'token': AuthService.getToken(),
      },
    });

    // Socket event listeners
    socket.onConnect((_) {
      print('Connected to chat');
      // Join the specific lobby chat room
      socket.emit('joinChat', {
        'lobbyId': widget.lobbyId,
        'username': widget.username,
      });
    });

    // Listen for new messages
    socket.on('message', (data) {
      setState(() {
        messages.add(ChatMessage.fromJson(data));
      });
      _scrollToBottom();
    });

    // Listen for user updates
    socket.on('userJoined', (data) {
      setState(() {
        activeUsers = List<String>.from(data['users']);
      });
    });

    socket.on('userLeft', (data) {
      setState(() {
        activeUsers = List<String>.from(data['users']);
      });
    });

    // Listen for any errors
    socket.onError((error) {
      print('Socket Error: $error');
    });

    socket.onDisconnect((_) {
      print('Disconnected from chat');
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final message = {
        'lobbyId': widget.lobbyId,
        'sender': widget.username,
        'content': _messageController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      socket.emit('sendMessage', message);
      _messageController.clear();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(body: Text('CHAT PAGE'));
  }

  // Build method implementation...
}

class ChatMessage {
  final String sender;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: json['sender'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
