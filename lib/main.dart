import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF0A0E21),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6C63FF),
        secondary: Color(0xFF00BFA6),
        surface: Color(0xFF1D1E33),
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    home: RobotArmPage(),
  ));
}

class RobotArmPage extends StatelessWidget {
  final channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.4.1:80/ws'), // Added explicit port number
  );

  RobotArmPage({super.key});

  void sendCommand(String command) {
    final data = jsonEncode({"command": command});
    channel.sink.add(data);
  }

  Widget buildControlButton(String label, String command,
      {double fontSize = 12}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTapDown: (_) => sendCommand("${command}_start"),
        onTapUp: (_) => sendCommand("${command}_stop"),
        onTapCancel: () => sendCommand("${command}_stop"),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 130,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6C63FF), Color(0xFF4A44CC)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF6C63FF).withOpacity(0.3),
                offset: Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _getIconForCommand(command),
                const SizedBox(width: 8),
                Text(
                  label.replaceAll(RegExp(r'[⬆️⬇️⬅️➡️🔼🔽🤏✋]'), '').trim(),
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Icon _getIconForCommand(String command) {
    final iconMap = {
      'shoulder_up': Icons.arrow_upward,
      'shoulder_down': Icons.arrow_downward,
      'rotate_left': Icons.rotate_left,
      'rotate_right': Icons.rotate_right,
      'elbow_up': Icons.keyboard_arrow_up,
      'elbow_down': Icons.keyboard_arrow_down,
      'grip_close': Icons.close_fullscreen,
      'grip_open': Icons.open_in_full,
      'wrist_up': Icons.rotate_right,
      'wrist_down': Icons.rotate_left,
    };
    return Icon(iconMap[command] ?? Icons.error, size: 20);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Robot Arm Controller",
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show info dialog
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E21), Color(0xFF090C1A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildControlSection(
                    "Base & Shoulder Control",
                    [
                      buildControlButton("Shoulder Up", "shoulder_up"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildControlButton("Base Left", "rotate_left"),
                          const SizedBox(width: 16),
                          buildControlButton("Base Right", "rotate_right"),
                        ],
                      ),
                      buildControlButton("Shoulder Down", "shoulder_down"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildControlSection(
                    "Elbow & Gripper Control",
                    [
                      buildControlButton("Elbow Up", "elbow_up"),
                      buildControlButton("Elbow Down", "elbow_down"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildControlButton("Wrist Up", "wrist_up"),
                          const SizedBox(width: 16),
                          buildControlButton("Wrist Down", "wrist_down"),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildControlButton("Close", "grip_close"),
                          const SizedBox(width: 16),
                          buildControlButton("Open", "grip_open"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlSection(String title, List<Widget> children) {
    return Card(
      color: const Color(0xFF1D1E33),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
