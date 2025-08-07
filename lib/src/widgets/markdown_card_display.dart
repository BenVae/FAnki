import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownCardDisplay extends StatelessWidget {
  final String content;
  final TextStyle? style;
  final bool selectable;

  const MarkdownCardDisplay({
    Key? key,
    required this.content,
    this.style,
    this.selectable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Process content to handle LaTeX
    final processedContent = _processLatex(content);
    
    return MarkdownBody(
      data: processedContent,
      selectable: selectable,
      styleSheet: MarkdownStyleSheet(
        p: style ?? Theme.of(context).textTheme.bodyLarge,
        h1: Theme.of(context).textTheme.headlineMedium,
        h2: Theme.of(context).textTheme.headlineSmall,
        h3: Theme.of(context).textTheme.titleLarge,
        h4: Theme.of(context).textTheme.titleMedium,
        h5: Theme.of(context).textTheme.titleSmall,
        h6: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        code: TextStyle(
          fontFamily: 'monospace',
          backgroundColor: Colors.grey.shade100,
          fontSize: 14,
        ),
        codeblockDecoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        blockquote: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.grey.shade700,
        ),
        listBullet: style ?? Theme.of(context).textTheme.bodyLarge,
        tableHead: const TextStyle(fontWeight: FontWeight.bold),
        tableBody: Theme.of(context).textTheme.bodyMedium,
      ),
      builders: {
        'latex': LatexElementBuilder(),
      },
      extensionSet: md.ExtensionSet(
        md.ExtensionSet.gitHubFlavored.blockSyntaxes,
        [
          LatexInlineSyntax(),
          ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
        ],
      ),
    );
  }

  String _processLatex(String text) {
    // Replace $$...$$ with block math
    text = text.replaceAllMapped(
      RegExp(r'\$\$(.*?)\$\$', dotAll: true),
      (match) => '<latex display="true">${match.group(1)}</latex>',
    );
    
    // Replace $...$ with inline math
    text = text.replaceAllMapped(
      RegExp(r'\$([^\$]+)\$'),
      (match) => '<latex>${match.group(1)}</latex>',
    );
    
    return text;
  }
}

// Custom inline syntax for LaTeX
class LatexInlineSyntax extends md.InlineSyntax {
  LatexInlineSyntax() : super(r'<latex(?:\s+display="true")?>(.*?)</latex>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final latex = match.group(1) ?? '';
    final isDisplay = match.group(0)?.contains('display="true"') ?? false;
    
    parser.addNode(
      md.Element.text('latex', latex)
        ..attributes['display'] = isDisplay.toString(),
    );
    return true;
  }
}

// Custom builder for LaTeX elements
class LatexElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final latex = element.textContent;
    final isDisplay = element.attributes['display'] == 'true';
    
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isDisplay ? 8.0 : 0,
        horizontal: isDisplay ? 0 : 4.0,
      ),
      child: Math.tex(
        latex,
        textStyle: preferredStyle,
        mathStyle: isDisplay ? MathStyle.display : MathStyle.text,
        onErrorFallback: (error) => Text(
          latex,
          style: TextStyle(color: Colors.red.shade700),
        ),
      ),
    );
  }
}