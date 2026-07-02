import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dualert/core/theme/app_colors.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final Function(String voicePath)? onRecordingComplete;
  final int maxDurationSeconds;

  const VoiceRecorderWidget({
    super.key,
    this.onRecordingComplete,
    this.maxDurationSeconds = 10,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordingPath;
  int _recordingDuration = 0;

  Future<void> _startRecording() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.wav';
      
      // Simulate recording - in production, use flutter_sound or record package
      if (mounted) {
        setState(() {
          _isRecording = true;
          _recordingPath = path;
          _recordingDuration = 0;
        });
      }

      // Auto-stop after max duration
      Future.delayed(Duration(seconds: widget.maxDurationSeconds), () {
        if (_isRecording) {
          _stopRecording();
        }
      });

      // Update duration counter
      Future.doWhile(() async {
        if (!_isRecording) return false;
        if (mounted) {
          setState(() {
            _recordingDuration++;
          });
        }
        await Future.delayed(const Duration(seconds: 1));
        return _isRecording;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting recording: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }

      if (_recordingPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice recording saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        if (widget.onRecordingComplete != null) {
          widget.onRecordingComplete!(_recordingPath!);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error stopping recording: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _playRecording() async {
    try {
      if (_recordingPath == null) return;

      if (mounted) {
        setState(() {
          _isPlaying = !_isPlaying;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing recording: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteRecording() async {
    try {
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      if (mounted) {
        setState(() {
          _recordingPath = null;
          _recordingDuration = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting recording: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Voice Registration (Optional)',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Record up to ${widget.maxDurationSeconds} seconds of your voice to describe your emergency',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          if (_recordingPath == null)
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isRecording ? _stopRecording : _startRecording,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? AppColors.error : AppColors.primaryBlue,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? AppColors.error : AppColors.primaryBlue)
                                .withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isRecording ? '${_recordingDuration}s' : 'Tap to record',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _isRecording ? AppColors.error : null,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Recording saved (${_recordingDuration}s)',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _playRecording,
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      label: Text(_isPlaying ? 'Pause' : 'Play'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _deleteRecording,
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

