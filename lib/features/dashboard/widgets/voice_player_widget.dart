import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:dualert/core/theme/app_colors.dart';

class VoicePlayerWidget extends StatefulWidget {
  final String? voiceUrl;
  final String userName;

  const VoicePlayerWidget({
    super.key,
    this.voiceUrl,
    required this.userName,
  });

  @override
  State<VoicePlayerWidget> createState() => _VoicePlayerWidgetState();
}

class _VoicePlayerWidgetState extends State<VoicePlayerWidget> {
  late FlutterSoundPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = FlutterSoundPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    await _audioPlayer.openPlayer();
  }

  Future<void> _playPauseAudio() async {
    if (widget.voiceUrl == null || widget.voiceUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No voice recording available'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pausePlayer();
      } else {
        if (mounted) {
          setState(() {
            _isLoading = true;
          });
        }

        await _audioPlayer.startPlayer(fromURI: widget.voiceUrl!);

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.voiceUrl == null || widget.voiceUrl!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.mic_off,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No voice recording from ${widget.userName}',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.mic,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Voice Message from ${widget.userName}",
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (_isLoading)
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  ),
                )
              else
                GestureDetector(
                  onTap: _playPauseAudio,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue,
                    ),
                    child: Center(
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Tap to play voice recording",
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
