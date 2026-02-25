import 'dart:io';

void main() async {
  final dir = Directory('lib');
  if (!await dir.exists()) return;

  final files = await dir.list(recursive: true).toList();

  for (var file in files) {
    if (file is File && file.path.endsWith('.dart')) {
      String content = await file.readAsString();
      bool changed = false;

      // Add GetX import if not present and we actually use Navigator
      if (content.contains('Navigator.')) {
        if (!content.contains("import 'package:get/get.dart';")) {
          // find last import or first line
          var lines = content.split('\n');
          int insertIdx = 0;
          for (int i = 0; i < lines.length; i++) {
            if (lines[i].startsWith('import ')) {
              insertIdx = i + 1;
            }
          }
          lines.insert(insertIdx, "import 'package:get/get.dart';");
          content = lines.join('\n');
          changed = true;
        }
      }

      // Replace pop
      if (content.contains('Navigator.pop(context);')) {
        content = content.replaceAll('Navigator.pop(context);', 'Get.back();');
        changed = true;
      }
      if (content.contains('Navigator.pop(context)')) {
        content = content.replaceAll('Navigator.pop(context)', 'Get.back()');
        changed = true;
      }

      // We will do a regex for push to handle multi-line calls
      // Navigator.push(context, MaterialPageRoute(builder: (context) => Widget()));
      final pushRegex = RegExp(
        r'Navigator\.push\s*\(\s*context\s*,\s*MaterialPageRoute\s*\(\s*builder\s*:\s*\(\s*context\s*\)\s*=>\s*([^,]+?)\s*,?\s*\)\s*,?\s*\)\s*;?',
        multiLine: true,
        dotAll: true,
      );
      if (pushRegex.hasMatch(content)) {
        content = content.replaceAllMapped(pushRegex, (match) {
          final widget = match.group(1)!.trim();
          bool hasSemi = match.group(0)!.endsWith(';');
          return 'Get.to(() => $widget)${hasSemi ? ';' : ''}';
        });
        changed = true;
      }

      // Replace pushReplacement
      final pushRepRegex = RegExp(
        r'Navigator\.pushReplacement\s*\(\s*context\s*,\s*MaterialPageRoute\s*\(\s*builder\s*:\s*\(\s*context\s*\)\s*=>\s*([^,]+?)\s*,?\s*\)\s*,?\s*\)\s*;?',
        multiLine: true,
        dotAll: true,
      );
      if (pushRepRegex.hasMatch(content)) {
        content = content.replaceAllMapped(pushRepRegex, (match) {
          final widget = match.group(1)!.trim();
          bool hasSemi = match.group(0)!.endsWith(';');
          return 'Get.off(() => $widget)${hasSemi ? ';' : ''}';
        });
        changed = true;
      }

      // Replace pushAndRemoveUntil
      // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Widget()), (route) => false);
      final pushRemoveRegex = RegExp(
        r'Navigator\.pushAndRemoveUntil\s*\(\s*context\s*,\s*MaterialPageRoute\s*\(\s*builder\s*:\s*\(\s*context\s*\)\s*=>\s*([^,]+?)\s*,?\s*\)\s*,\s*\([^\)]+\)\s*=>\s*false\s*\)\s*;?',
        multiLine: true,
        dotAll: true,
      );
      if (pushRemoveRegex.hasMatch(content)) {
        content = content.replaceAllMapped(pushRemoveRegex, (match) {
          final widget = match.group(1)!.trim();
          bool hasSemi = match.group(0)!.endsWith(';');
          return 'Get.offAll(() => $widget)${hasSemi ? ';' : ''}';
        });
        changed = true;
      }

      if (changed) {
        await file.writeAsString(content);
        print('Updated: ${file.path}');
      }
    }
  }
}
