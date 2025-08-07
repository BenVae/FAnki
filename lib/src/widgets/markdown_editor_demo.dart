import 'package:flutter/material.dart';
import 'markdown_editor.dart';

/// Demo page showing the markdown editor capabilities
class MarkdownEditorDemo extends StatefulWidget {
  const MarkdownEditorDemo({super.key});

  @override
  State<MarkdownEditorDemo> createState() => _MarkdownEditorDemoState();
}

class _MarkdownEditorDemoState extends State<MarkdownEditorDemo> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with example markdown
    _controller.text = '''# Markdown Editor Demo

## Text Formatting
You can use **bold text**, *italic text*, or ***both***!

## Lists
### Bullet List:
- First item
- Second item
- Third item

### Numbered List:
1. First step
2. Second step
3. Third step

## Code
Inline code: `const x = 42;`

Code block:
```dart
void main() {
  print('Hello, Flutter!');
}
```

## Math Formulas
Inline math: The quadratic formula is \$x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}\$

Block math:
\$\$
\\int_{0}^{\\infty} e^{-x^2} dx = \\frac{\\sqrt{\\pi}}{2}
\$\$

## Links and Tables
[Flutter Documentation](https://flutter.dev)

| Language | Framework |
|----------|-----------|
| Dart     | Flutter   |
| Swift    | SwiftUI   |
| Kotlin   | Jetpack   |
''';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Markdown Editor Demo'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Try the markdown editor below:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: MarkdownEditor(
                  controller: _controller,
                  labelText: 'Card Answer',
                  hintText: 'Enter your answer with formatting...',
                  maxLines: 15,
                  onChanged: (value) {
                    // Handle changes if needed
                    print('Content changed: ${value.length} characters');
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Show the current markdown content
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Markdown Content'),
                      content: SingleChildScrollView(
                        child: SelectableText(_controller.text),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Show Raw Markdown'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}