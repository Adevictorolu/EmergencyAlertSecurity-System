import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'dart:math' as math;
import '../models/alert_model.dart';
import '../utils/app_colors.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  Future<void> _exportCSV(BuildContext context, List<AlertModel> alerts) async {
    try {
      String csv = "ID,Title,Description,Handled,Date\n";
      for (var a in alerts) {
        String dateStr = DateFormat('yyyy-MM-dd HH:mm').format(a.createdAt);
        String desc = a.description.replaceAll('"', '""').replaceAll('\n', ' ');
        csv += '${a.id},"${a.title}","$desc",${a.handled},$dateStr\n';
      }
      
      final bytes = Uri.encodeComponent(csv);
      final url = Uri.parse('data:text/csv;charset=utf-8,$bytes');
      
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch export';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e', style: const TextStyle(fontFamily: 'Montserrat'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('System Analytics', style: TextStyle(color: AppColors.textPrimary)),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.4),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('alerts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No analytical data available.', style: TextStyle(fontFamily: 'Montserrat', color: AppColors.textSecondary)));
          }

          final alerts = snapshot.data!.docs.map((doc) => AlertModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
          
          int totalAlerts = alerts.length;
          int handledAlerts = alerts.where((a) => a.handled).length;
          int pendingAlerts = totalAlerts - handledAlerts;

          // Group by title (Fire, Medical, Security, Others)
          Map<String, int> typeCounts = {'Fire': 0, 'Medical': 0, 'Security': 0, 'Other': 0};
          for (var alert in alerts) {
            String t = alert.title.toLowerCase();
            if (t.contains('fire')) typeCounts['Fire'] = typeCounts['Fire']! + 1;
            else if (t.contains('medical') || t.contains('health')) typeCounts['Medical'] = typeCounts['Medical']! + 1;
            else if (t.contains('security') || t.contains('sos')) typeCounts['Security'] = typeCounts['Security']! + 1;
            else typeCounts['Other'] = typeCounts['Other']! + 1;
          }

          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Overview',
                        style: TextStyle(fontFamily: 'Montserrat', fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => _exportCSV(context, alerts),
                        icon: const Icon(Icons.download, size: 16, color: Colors.white),
                        label: const Text('Export CSV', style: TextStyle(color: Colors.white, fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildMetricCard('Total Alerts', totalAlerts.toString(), Colors.blueAccent)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildMetricCard('Resolved', handledAlerts.toString(), AppColors.success)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildMetricCard('Pending', pendingAlerts.toString(), AppColors.error)),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  const Text('Distribution by Category', style: TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 20),
                  
                  Container(
                    height: 250,
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CustomPaint(
                            painter: PieChartPainter(
                              data: typeCounts.values.toList(),
                              colors: const [Colors.orange, Colors.blue, Colors.green, Colors.purple],
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem('Fire', Colors.orange, typeCounts['Fire']!),
                            _buildLegendItem('Medical', Colors.blue, typeCounts['Medical']!),
                            _buildLegendItem('Security', Colors.green, typeCounts['Security']!),
                            _buildLegendItem('Other', Colors.purple, typeCounts['Other']!),
                          ],
                        )
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  const Text('Volume Comparison', style: TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 20),
                  
                  Container(
                    height: 250,
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: CustomPaint(
                      painter: BarChartPainter(
                        data: typeCounts.values.toList(),
                        labels: typeCounts.keys.toList(),
                        colors: const [Colors.orange, Colors.blue, Colors.green, Colors.purple],
                        maxValue: math.max(1, typeCounts.values.reduce(math.max)).toDouble(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontFamily: 'Montserrat', fontSize: 28, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text('$label ($count)', style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<int> data;
  final List<Color> colors;

  PieChartPainter({required this.data, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    int total = data.fold(0, (sum, item) => sum + item);
    if (total == 0) return;

    double startAngle = -math.pi / 2;
    final rect = Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: size.width, height: size.height);

    for (int i = 0; i < data.length; i++) {
      if (data[i] == 0) continue;
      final sweepAngle = (data[i] / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
        
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BarChartPainter extends CustomPainter {
  final List<int> data;
  final List<String> labels;
  final List<Color> colors;
  final double maxValue;

  BarChartPainter({required this.data, required this.labels, required this.colors, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    
    final barWidth = size.width / (data.length * 2);
    final maxBarHeight = size.height - 30; // space for labels
    
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < data.length; i++) {
      final x = (i * 2 + 0.5) * barWidth;
      final barHeight = (data[i] / maxValue) * maxBarHeight;
      final y = maxBarHeight - barHeight;

      if (data[i] > 0) {
        final paint = Paint()
          ..color = colors[i]
          ..style = PaintingStyle.fill;
        canvas.drawRect(Rect.fromLTWH(x, y, barWidth, barHeight), paint);
      }

      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Colors.black54, fontSize: 12, fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + (barWidth - textPainter.width) / 2, maxBarHeight + 5));
    }
    
    // Dispose the TextPainter to prevent memory leaks!
    textPainter.dispose();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
