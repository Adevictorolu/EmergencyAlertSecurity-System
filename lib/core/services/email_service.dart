import 'package:cloud_firestore/cloud_firestore.dart';

class EmailService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String _getBaseHtml(String title, String content) {
    return '''
      <div style="font-family: 'Montserrat', sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #e0e0e0; border-radius: 8px; overflow: hidden;">
        <div style="background-color: #003366; padding: 20px; text-align: center;">
          <h1 style="color: #ffffff; margin: 0;">DUalert</h1>
        </div>
        <div style="padding: 30px; background-color: #ffffff;">
          <h2 style="color: #003366;">$title</h2>
          $content
        </div>
        <div style="background-color: #f5f5f5; padding: 15px; text-align: center; font-size: 12px; color: #666666;">
          <p>This is an automated message from the DUalert Emergency System.</p>
          <p>Dominion University | Emergency Services</p>
          <p>Generated at: ${DateTime.now().toLocal().toString()}</p>
        </div>
      </div>
    ''';
  }

  static Future<void> sendWelcomeEmail(String email, String name) async {
    final content = '''
      <p>Hello <strong>$name</strong>,</p>
      <p>Welcome to DUalert, the official Emergency Alert Security System for Dominion University.</p>
      <p>Your account has been created successfully. Please ensure you verify your email address to gain full access to the system features.</p>
      <p>Stay safe!</p>
    ''';

    await _db.collection('mail').add({
      'to': email,
      'message': {
        'subject': 'Welcome to DUalert',
        'html': _getBaseHtml('Welcome!', content),
      },
    });
  }

  static Future<void> sendAlertConfirmation(String email, String name, String alertTitle, String alertDesc) async {
    final content = '''
      <p>Hello <strong>$name</strong>,</p>
      <p>We have successfully received your emergency alert:</p>
      <div style="background-color: #fff3e0; padding: 15px; border-left: 4px solid #ff9800; margin: 20px 0;">
        <h3 style="margin-top: 0; color: #e65100;">$alertTitle</h3>
        <p style="margin-bottom: 0;">$alertDesc</p>
      </div>
      <p>Security personnel have been notified and are reviewing your report. Please stay safe and follow any instructions from authorities.</p>
    ''';

    await _db.collection('mail').add({
      'to': email,
      'message': {
        'subject': 'Emergency Alert Received: $alertTitle',
        'html': _getBaseHtml('Alert Confirmation', content),
      },
    });
  }

  static Future<void> sendAlertStatusUpdate(String email, String name, String alertTitle, String newStatus) async {
    final content = '''
      <p>Hello <strong>$name</strong>,</p>
      <p>There is an update regarding your recent emergency alert: <strong>$alertTitle</strong></p>
      <p>The status of your alert has been updated to: <span style="background-color: #e8f5e9; color: #2e7d32; padding: 4px 8px; border-radius: 4px; font-weight: bold;">$newStatus</span></p>
      <p>If you require further assistance, please contact the security office directly.</p>
    ''';

    await _db.collection('mail').add({
      'to': email,
      'message': {
        'subject': 'Alert Status Update: $alertTitle',
        'html': _getBaseHtml('Alert Update', content),
      },
    });
  }
}
