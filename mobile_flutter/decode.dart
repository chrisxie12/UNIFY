import 'dart:io';

void main() {
  final file = File('build/web/main.dart.js');
  final lines = file.readAsLinesSync();
  
  // Read around line 4312
  for (int i = 4305; i <= 4325 && i < lines.length; i++) {
    final line = lines[i];
    if (line.length > 200) {
      stderr.writeln('${i+1}: ${line.substring(0, 200)}...');
    } else {
      stderr.writeln('${i+1}: $line');
    }
    stderr.writeln('');
  }
}
