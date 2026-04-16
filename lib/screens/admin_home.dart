import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../auth/auth_service.dart';
import '../models/alert_model.dart';
import '../utils/app_colors.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Admin Dashboard'), 
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.4),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('alerts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, alertSnapshot) {
          if (alertSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryBlue,
                ),
              ),
            );
          }

          if (!alertSnapshot.hasData || alertSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No alerts yet',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final alerts = alertSnapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alertData = alerts[index].data() as Map<String, dynamic>;
              final alert = AlertModel.fromMap(alertData);

              Widget content;
              if (alert.senderUid.isEmpty) {
                content = _buildAlertCard(context, alert, {}, false);
              } else {
                content = FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(alert.senderUid)
                      .get(),
                  builder: (context, senderSnapshot) {
                    Map<String, dynamic> senderData = {};
                    bool isLoadingSender = true;

                    if (senderSnapshot.connectionState == ConnectionState.done &&
                        senderSnapshot.hasData) {
                      senderData =
                          senderSnapshot.data!.data() as Map<String, dynamic>? ??
                          {};
                      isLoadingSender = false;
                    }

                    return _buildAlertCard(
                      context,
                      alert,
                      senderData,
                      isLoadingSender,
                    );
                  },
                );
              }
              return content;
            },
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    AlertModel alert,
    Map<String, dynamic> senderData,
    bool isLoadingSender,
  ) {
    String formattedTime = 'Unknown Time';
    try {
      formattedTime = DateFormat(
        'MMM d, yyyy • h:mm a',
      ).format(alert.createdAt);
    } catch (_) {}

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    alert.title,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _buildStatusChip(alert.handled),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formattedTime,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              alert.description,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "SENDER DETAILS",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: isLoadingSender
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          Icons.person,
                          senderData['fullName'] ?? 'Unknown User',
                          isBold: true,
                        ),
                        _buildInfoRow(
                          Icons.email,
                          senderData['email'] ?? 'N/A',
                        ),
                        if (senderData['matricNo'] != null && senderData['matricNo'].toString().isNotEmpty)
                          _buildInfoRow(
                            Icons.badge,
                            senderData['matricNo'],
                          ),
                        if (senderData['phone'] != null && senderData['phone'].toString().isNotEmpty)
                          InkWell(
                            onTap: () async {
                              final telUrl = Uri.parse('tel:${senderData['phone']}');
                              if (await canLaunchUrl(telUrl)) {
                                await launchUrl(telUrl);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.phone, size: 18, color: AppColors.primaryBlue),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '${senderData['phone']} (Tap to call)',
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (alert.lat != null && alert.lng != null)
                          InkWell(
                            onTap: () async {
                              final url = Uri.parse(
                                'https://www.google.com/maps/search/?api=1&query=${alert.lat},${alert.lng}',
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 18,
                                    color: AppColors.primaryBlue,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'View on Map',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            if (!alert.handled) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.textLight,
                  ),
                  label: const Text(
                    'Mark as Handled',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final adminUid = FirebaseAuth.instance.currentUser!.uid;
                      await AuthService().handleAlert(alert.id, adminUid);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Alert marked as handled',
                              style: TextStyle(fontFamily: 'Montserrat'),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}',
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                color: AppColors.textLight,
                              ),
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool handled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: handled
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: handled ? AppColors.success : AppColors.warning,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            handled ? Icons.check_circle : Icons.pending,
            size: 16,
            color: handled ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 6),
          Text(
            handled ? "Handled" : "Pending",
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: handled ? AppColors.success : AppColors.warning,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
