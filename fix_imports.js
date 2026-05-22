const fs = require('fs');
const path = require('path');

const libDir = 'lib';
const filesToFix = [];

function walkDir(dir) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        const fullPath = path.join(dir, file);
        if (fs.statSync(fullPath).isDirectory()) {
            walkDir(fullPath);
        } else if (fullPath.endsWith('.dart')) {
            filesToFix.push(fullPath);
        }
    }
}

walkDir(libDir);

const movedMappings = {
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
};

for (const filePath of filesToFix) {
    const content = fs.readFileSync(filePath, 'utf-8');
    const lines = content.split('\n');
    const newLines = [];
    
    for (let line of lines) {
        if (line.trim().startsWith('import ')) {
            for (const [oldPath, newPath] of Object.entries(movedMappings)) {
                const basename = path.basename(oldPath);
                if (line.includes(basename) && (line.includes('/' + basename) || line.includes("'" + basename + "'") || line.includes('"' + basename + '"')) && !line.includes('package:dualert')) {
                    line = `import 'package:dualert/${newPath}';`;
                    break;
                }
            }
            if (filePath.endsWith('main.dart')) {
                for (const [oldPath, newPath] of Object.entries(movedMappings)) {
                    if (line.includes(`import '${oldPath}';`)) {
                        line = `import 'package:dualert/${newPath}';`;
                        break;
                    }
                }
            }
        }
        newLines.push(line);
    }
    
    const finalContent = newLines.join('\n');
    if (finalContent !== content) {
        fs.writeFileSync(filePath, finalContent, 'utf-8');
        console.log(`Fixed ${filePath}`);
    }
}
