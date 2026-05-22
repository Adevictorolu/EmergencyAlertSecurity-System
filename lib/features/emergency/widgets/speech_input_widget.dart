import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:dualert/core/theme/app_colors.dart';

class SpeechInputWidget extends StatefulWidget {
  final Function(String) onTextRecognized;
  final TextEditingController controller;

  const SpeechInputWidget({
    super.key,
    required this.onTextRecognized,
    required this.controller,
  });

  @override
  State<SpeechInputWidget> createState() => _SpeechInputWidgetState();
}

class _SpeechInputWidgetState extends State<SpeechInputWidget> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (val) => print('Speech Error: ${val.errorMsg}'),
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() {});
  }

  void _startListening() async {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition is not available or permitted.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final currentText = widget.controller.text;

    setState(() => _isListening = true);
    await _speechToText.listen(
      onResult: (result) {
        final recognizedWords = result.recognizedWords;
        final newText = currentText.isEmpty 
            ? recognizedWords 
            : '$currentText $recognizedWords';
        
        widget.onTextRecognized(newText);
        
        if (mounted) setState(() {});
      },
    );
  }

  void _stopListening() async {
    await _speechToText.stop();
    if (mounted) setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isListening ? _stopListening : _startListening,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isListening ? AppColors.error.withOpacity(0.1) : AppColors.primaryBlue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          color: _isListening ? AppColors.error : AppColors.primaryBlue,
          size: 28,
        ),
      ),
    );
  }
}
