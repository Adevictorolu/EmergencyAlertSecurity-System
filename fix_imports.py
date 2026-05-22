import os
import re

lib_dir = 'lib'
files_to_fix = []
for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            files_to_fix.append(os.path.join(root, f))

moved_mappings = {
    'utils/app_theme.dart': 'core/theme/app_theme.dart',
    'utils/app_colors.dart': 'core/theme/app_colors.dart',
    'auth/auth_service.dart': 'features/auth/services/auth_service.dart',
    'screens/email_verification_screen.dart': 'features/auth/screens/email_verification_screen.dart',
    'screens/sign_in_page.dart': 'features/auth/screens/sign_in_page.dart',
    'screens/sign_up_page.dart': 'features/auth/screens/sign_up_page.dart',
    'screens/onboarding_screen.dart': 'features/auth/screens/onboarding_screen.dart',
    'screens/student_home.dart': 'features/emergency/screens/student_home.dart',
    'screens/view_alert_page.dart': 'features/dashboard/screens/view_alert_page.dart',
    'screens/admin_home.dart': 'features/dashboard/screens/admin_home.dart',
    'screens/alert_history.dart': 'features/dashboard/screens/alert_history.dart',
    'screens/analytics_page.dart': 'features/dashboard/screens/analytics_page.dart',
    'widgets/voice_recorder_widget.dart': 'features/emergency/widgets/voice_recorder_widget.dart',
    'widgets/voice_player_widget.dart': 'features/dashboard/widgets/voice_player_widget.dart',
    'widgets/glowing_buttons.dart': 'core/widgets/glowing_buttons.dart',
}

for file_path in files_to_fix:
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    new_lines = []
    for line in content.split('\n'):
        if line.strip().startswith('import '):
            for old, new in moved_mappings.items():
                basename = old.split('/')[-1]
                # If the line contains the basename and it's a relative import
                if basename in line and ('/' + basename in line or '\'' + basename + '\'' in line or '\"' + basename + '\"' in line) and 'package:dualert' not in line:
                    line = f"import 'package:dualert/{new}';"
                    break
            
            # Special case for main.dart which had imports like 'screens/sign_in_page.dart'
            if file_path.endswith('main.dart'):
                for old, new in moved_mappings.items():
                    if f"import '{old}';" in line:
                        line = f"import 'package:dualert/{new}';"
                        break

        new_lines.append(line)
        
    final_content = '\n'.join(new_lines)
    if final_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(final_content)
        print(f'Fixed {file_path}')
