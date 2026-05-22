const fs = require('fs');

const replacements = {
  "import '../utils/app_colors.dart';": "import 'package:dualert/core/theme/app_colors.dart';",
  "import '../providers/user_provider.dart';": "import 'package:dualert/providers/user_provider.dart';",
  "import '../models/alert_model.dart';": "import 'package:dualert/models/alert_model.dart';",
  "import '../models/app_user.dart';": "import 'package:dualert/models/app_user.dart';",
  "import '../auth/auth_service.dart';": "import 'package:dualert/features/auth/services/auth_service.dart';",
  "import '../widgets/voice_recorder_widget.dart';": "import 'package:dualert/features/emergency/widgets/voice_recorder_widget.dart';",
  "import '../widgets/voice_player_widget.dart';": "import 'package:dualert/features/dashboard/widgets/voice_player_widget.dart';",
  "import '../main.dart';": "import 'package:dualert/main.dart';",
  "import './auth/auth_service.dart';": "import 'package:dualert/features/auth/services/auth_service.dart';",
  "import './screens/sign_in_page.dart';": "import 'package:dualert/features/auth/screens/sign_in_page.dart';",
  "import './screens/sign_up_page.dart';": "import 'package:dualert/features/auth/screens/sign_up_page.dart';",
  "import './screens/admin_home.dart';": "import 'package:dualert/features/dashboard/screens/admin_home.dart';",
  "import './screens/student_home.dart';": "import 'package:dualert/features/emergency/screens/student_home.dart';",
  "import './screens/view_alert_page.dart';": "import 'package:dualert/features/dashboard/screens/view_alert_page.dart';",
  "import './screens/onboarding_screen.dart';": "import 'package:dualert/features/auth/screens/onboarding_screen.dart';",
  "import './screens/analytics_page.dart';": "import 'package:dualert/features/dashboard/screens/analytics_page.dart';",
  "import './screens/email_verification_screen.dart';": "import 'package:dualert/features/auth/screens/email_verification_screen.dart';",
  "import './utils/app_colors.dart';": "import 'package:dualert/core/theme/app_colors.dart';",
  "import './utils/app_theme.dart';": "import 'package:dualert/core/theme/app_theme.dart';",
  "import 'auth/auth_service.dart';": "import 'package:dualert/features/auth/services/auth_service.dart';",
  "import 'screens/sign_in_page.dart';": "import 'package:dualert/features/auth/screens/sign_in_page.dart';",
  "import 'screens/sign_up_page.dart';": "import 'package:dualert/features/auth/screens/sign_up_page.dart';",
  "import 'screens/admin_home.dart';": "import 'package:dualert/features/dashboard/screens/admin_home.dart';",
  "import 'screens/student_home.dart';": "import 'package:dualert/features/emergency/screens/student_home.dart';",
  "import 'screens/view_alert_page.dart';": "import 'package:dualert/features/dashboard/screens/view_alert_page.dart';",
  "import 'screens/onboarding_screen.dart';": "import 'package:dualert/features/auth/screens/onboarding_screen.dart';",
  "import 'screens/analytics_page.dart';": "import 'package:dualert/features/dashboard/screens/analytics_page.dart';",
  "import 'screens/email_verification_screen.dart';": "import 'package:dualert/features/auth/screens/email_verification_screen.dart';",
  "import 'utils/app_colors.dart';": "import 'package:dualert/core/theme/app_colors.dart';",
  "import 'utils/app_theme.dart';": "import 'package:dualert/core/theme/app_theme.dart';"
};

function walkDir(dir) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        const fullPath = dir + '/' + file;
        if (fs.statSync(fullPath).isDirectory()) {
            walkDir(fullPath);
        } else if (fullPath.endsWith('.dart')) {
            let content = fs.readFileSync(fullPath, 'utf-8');
            let modified = false;
            for (const [oldImport, newImport] of Object.entries(replacements)) {
                if (content.includes(oldImport)) {
                    content = content.split(oldImport).join(newImport);
                    modified = true;
                }
            }
            if (modified) {
                fs.writeFileSync(fullPath, content, 'utf-8');
                console.log(`Fixed ${fullPath}`);
            }
        }
    }
}

walkDir('lib');
