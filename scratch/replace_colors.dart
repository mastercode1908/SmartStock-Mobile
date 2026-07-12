import 'dart:io';

void main() async {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = await file.readAsString();
    bool changed = false;

    // Replace color constants with Theme.of(context)
    final replacements = {
      // Primary
      'const Color(0xFFB02528)': 'Theme.of(context).colorScheme.primary',
      'const Color(0xffb02528)': 'Theme.of(context).colorScheme.primary',
      'const Color(0xFFB3272E)': 'Theme.of(context).colorScheme.primary',
      'const Color(0xffb3272e)': 'Theme.of(context).colorScheme.primary',
      
      // Backgrounds & Surfaces
      'const Color(0xFFF9F9F9)': 'Theme.of(context).scaffoldBackgroundColor',
      'const Color(0xfff9f9f9)': 'Theme.of(context).scaffoldBackgroundColor',
      'const Color(0xFFFFFFFF)': 'Theme.of(context).colorScheme.surface',
      'const Color(0xffffffff)': 'Theme.of(context).colorScheme.surface',
      'Colors.white': 'Theme.of(context).colorScheme.surface',
      
      // On surfaces (Text)
      'const Color(0xFF1A1C1C)': 'Theme.of(context).colorScheme.onSurface',
      'const Color(0xff1a1c1c)': 'Theme.of(context).colorScheme.onSurface',
      'Colors.black': 'Theme.of(context).colorScheme.onSurface',
      'Colors.black87': 'Theme.of(context).colorScheme.onSurface',
      'Colors.black54': 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)',
      'Colors.black38': 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)',
      'Colors.black12': 'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12)',
      
      // Containers / Grey
      'Colors.grey[100]!': 'Theme.of(context).colorScheme.surfaceContainerLow',
      'Colors.grey[100]': 'Theme.of(context).colorScheme.surfaceContainerLow',
      'Colors.grey[200]!': 'Theme.of(context).colorScheme.surfaceContainer',
      'Colors.grey[200]': 'Theme.of(context).colorScheme.surfaceContainer',
      'Colors.grey[300]!': 'Theme.of(context).colorScheme.surfaceContainerHigh',
      'Colors.grey[300]': 'Theme.of(context).colorScheme.surfaceContainerHigh',
      'Colors.grey[400]!': 'Theme.of(context).colorScheme.surfaceContainerHighest',
      'Colors.grey[400]': 'Theme.of(context).colorScheme.surfaceContainerHighest',
      'Colors.grey': 'Theme.of(context).colorScheme.onSurfaceVariant',
    };

    // First remove 'const' keyword before replacing if it is a widget that receives Theme.of
    // E.g. const Text(..., style: TextStyle(color: Colors.white)) -> Text(..., style: TextStyle(color: Theme.of...))
    // We can do a simple regex to remove const if the line will contain a Theme.of replacement.
    
    // Instead of complex parsing, I'll do a simple string replace for now.
    // If it breaks 'const', dart analyze will tell us and we can fix it.
  }
}
