import 'package:flutter/material.dart';
import 'markdown_card_display.dart';

class MarkdownEditor extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final int maxLines;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const MarkdownEditor({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.maxLines = 5,
    this.onChanged,
    this.validator,
  });

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  bool _showPreview = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _insertMarkdown(String prefix, String suffix, {String? placeholder}) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    
    String newText;
    int newCursorPos;
    
    if (selection.isCollapsed) {
      // No text selected - insert with placeholder
      final insertText = '$prefix${placeholder ?? ""}$suffix';
      newText = text.replaceRange(selection.start, selection.end, insertText);
      newCursorPos = selection.start + prefix.length + (placeholder?.length ?? 0);
    } else {
      // Text selected - wrap it
      final selectedText = text.substring(selection.start, selection.end);
      final insertText = '$prefix$selectedText$suffix';
      newText = text.replaceRange(selection.start, selection.end, insertText);
      newCursorPos = selection.start + prefix.length + selectedText.length + suffix.length;
    }
    
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
    
    if (widget.onChanged != null) {
      widget.onChanged!(newText);
    }
    
    _focusNode.requestFocus();
  }

  void _insertList(String marker) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    
    // Find the start of the current line
    int lineStart = selection.start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }
    
    // Insert list marker at the beginning of the line
    final newText = text.replaceRange(lineStart, lineStart, '$marker ');
    
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + marker.length + 1),
    );
    
    if (widget.onChanged != null) {
      widget.onChanged!(newText);
    }
    
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toolbar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Column(
            children: [
              // Formatting toolbar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ToolbarButton(
                      icon: Icons.format_bold,
                      tooltip: 'Bold',
                      onPressed: () => _insertMarkdown('**', '**', placeholder: 'bold text'),
                    ),
                    _ToolbarButton(
                      icon: Icons.format_italic,
                      tooltip: 'Italic',
                      onPressed: () => _insertMarkdown('*', '*', placeholder: 'italic text'),
                    ),
                    _ToolbarDivider(),
                    _ToolbarButton(
                      icon: Icons.title,
                      tooltip: 'Heading',
                      onPressed: () => _insertMarkdown('## ', '', placeholder: 'Heading'),
                    ),
                    _ToolbarDivider(),
                    _ToolbarButton(
                      icon: Icons.format_list_bulleted,
                      tooltip: 'Bullet List',
                      onPressed: () => _insertList('-'),
                    ),
                    _ToolbarButton(
                      icon: Icons.format_list_numbered,
                      tooltip: 'Numbered List',
                      onPressed: () => _insertList('1.'),
                    ),
                    _ToolbarDivider(),
                    _ToolbarButton(
                      icon: Icons.code,
                      tooltip: 'Inline Code',
                      onPressed: () => _insertMarkdown('`', '`', placeholder: 'code'),
                    ),
                    _ToolbarButton(
                      icon: Icons.code_off,
                      tooltip: 'Code Block',
                      onPressed: () => _insertMarkdown('```\n', '\n```', placeholder: 'code block'),
                    ),
                    _ToolbarDivider(),
                    _ToolbarButton(
                      icon: Icons.functions,
                      tooltip: 'Math (Inline)',
                      onPressed: () => _insertMarkdown(r'$', r'$', placeholder: 'x^2'),
                    ),
                    _ToolbarButton(
                      icon: Icons.functions_outlined,
                      tooltip: 'Math (Block)',
                      onPressed: () => _insertMarkdown(r'$$', r'$$', placeholder: r'\frac{1}{2}'),
                    ),
                    _ToolbarDivider(),
                    _ToolbarButton(
                      icon: Icons.link,
                      tooltip: 'Link',
                      onPressed: () => _insertMarkdown('[', '](url)', placeholder: 'link text'),
                    ),
                    _ToolbarButton(
                      icon: Icons.table_chart,
                      tooltip: 'Table',
                      onPressed: () {
                        const table = '''
| Header 1 | Header 2 |
|----------|----------|
| Cell 1   | Cell 2   |''';
                        _insertMarkdown('', table);
                      },
                    ),
                  ],
                ),
              ),
              // Preview toggle
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _showPreview = false),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_showPreview ? Colors.white : null,
                            border: !_showPreview
                                ? Border(
                                    bottom: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    ),
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Write',
                              style: TextStyle(
                                fontWeight: !_showPreview ? FontWeight.bold : FontWeight.normal,
                                color: !_showPreview
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _showPreview = true),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _showPreview ? Colors.white : null,
                            border: _showPreview
                                ? Border(
                                    bottom: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    ),
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Preview',
                              style: TextStyle(
                                fontWeight: _showPreview ? FontWeight.bold : FontWeight.normal,
                                color: _showPreview
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Editor/Preview area
        if (!_showPreview)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            constraints: BoxConstraints(
              minHeight: 100,
              maxHeight: 300,
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              maxLines: widget.maxLines,
              minLines: 3,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Enter text... (Markdown supported)',
                labelText: widget.labelText,
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
              validator: widget.validator,
              onChanged: widget.onChanged,
            ),
          ),
        if (_showPreview)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: Colors.grey.shade300),
                right: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            constraints: BoxConstraints(
              minHeight: 200,
              maxHeight: 400,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: widget.controller.text.isEmpty
                  ? Center(
                      child: Text(
                        'Nothing to preview',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    )
                  : MarkdownCardDisplay(
                      content: widget.controller.text,
                    ),
            ),
          ),
        // Help text
        Padding(
          padding: EdgeInsets.only(top: 8, left: 4),
          child: Text(
            'Supports Markdown formatting and LaTeX math',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 1,
      margin: EdgeInsets.symmetric(horizontal: 4),
      color: Colors.grey.shade300,
    );
  }
}