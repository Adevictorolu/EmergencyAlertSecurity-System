import 'package:flutter/foundation.dart' show kIsWeb;
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
    if (!kIsWeb) {
      _initSpeech();
    } else {
      // On web, try to initialize speech_to_text (uses Web Speech API)
      _initSpeech();
    }
  }

  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (val) => debugPrint('Speech Error: ${val.errorMsg}'),
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
      );
    } catch (_) {
      _speechEnabled = false;
    }
    if (mounted) setState(() {});
  }

  void _startListening() async {
    if (!_speechEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              kIsWeb
                  ? 'Speech recognition requires a browser that supports the Web Speech API (e.g. Chrome).'
                  : 'Speech recognition is not available or permitted.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
    return Tooltip(
      message: kIsWeb && !_speechEnabled
          ? 'Speech recognition requires Chrome or a compatible browser'
          : _isListening
              ? 'Tap to stop'
              : 'Tap to speak',
      child: GestureDetector(
        onTap: _isListening ? _stopListening : _startListening,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isListening
                ? AppColors.error.withOpacity(0.1)
                : AppColors.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            color: _isListening ? AppColors.error : AppColors.primaryBlue,
            size: 28,
          ),
        ),
      ),
    );
  }
}
