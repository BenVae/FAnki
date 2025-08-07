import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_repository/card_deck_manager.dart';
import '../cubit/ai_import_cubit.dart';
import '../../widgets/markdown_editor.dart';
import '../../widgets/markdown_card_display.dart';

class AiImportView extends StatelessWidget {
  const AiImportView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiImportCubit, AiImportState>(
      listener: (context, state) {
        if (state is AiImportSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully added ${state.cardCount} cards!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is AiImportError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AiImportInitial) {
          return _buildUploadView(context);
        } else if (state is AiImportPdfSelected) {
          return _buildSelectedView(context, state.fileName);
        } else if (state is AiImportProcessing) {
          return _buildProcessingView();
        } else if (state is AiImportPreview) {
          return _buildPreviewView(context, state);
        } else if (state is AiImportSaving) {
          return Center(child: CircularProgressIndicator());
        }
        return Container();
      },
    );
  }

  Widget _buildUploadView(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () => _selectPdf(context),
                borderRadius: BorderRadius.circular(10),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Tap to select PDF',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'or drag & drop your file here',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Upload your lecture PDF and let AI generate flashcards for you!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedView(BuildContext context, String fileName) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
            SizedBox(height: 24),
            Text(
              'PDF Selected:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              fileName,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.read<AiImportCubit>().clearSelection(),
                  child: Text('Change PDF'),
                ),
                SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => context.read<AiImportCubit>().generateCards(),
                  icon: Icon(Icons.auto_awesome),
                  label: Text('Generate Cards'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingView() {
    final messages = [
      'Reading your PDF...',
      'Understanding the content...',
      'Crafting perfect questions...',
      'Almost there...',
    ];
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: 'https://media.giphy.com/media/3o7TKtnuHOHHUjR38Y/giphy.gif',
              height: 200,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => CircularProgressIndicator(),
            ),
            SizedBox(height: 32),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: messages.length - 1),
              duration: Duration(seconds: 8),
              builder: (context, value, child) {
                return Text(
                  messages[value % messages.length],
                  style: Theme.of(context).textTheme.titleLarge,
                );
              },
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewView(BuildContext context, AiImportPreview state) {
    final deckNameController = TextEditingController(text: state.suggestedDeckName);
    
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Generated ${state.cards.length} Cards',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Spacer(),
              TextButton(
                onPressed: () => context.read<AiImportCubit>().clearSelection(),
                child: Text('Start Over'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.cards.length,
            itemBuilder: (context, index) {
              final card = state.cards[index];
              return _CardPreviewItem(
                card: card,
                onDelete: () => context.read<AiImportCubit>().removeCard(card.id),
                onEdit: (question, answer) => 
                  context.read<AiImportCubit>().updateCard(card.id, question, answer),
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: deckNameController,
                      decoration: InputDecoration(
                        labelText: 'Deck Name',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.auto_awesome),
                          onPressed: () {
                            // TODO: Generate new suggestion
                          },
                          tooltip: 'Get new suggestion',
                        ),
                      ),
                      onChanged: (value) => 
                        context.read<AiImportCubit>().updateDeckName(value),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: state.cards.isEmpty ? null : () {
                        context.read<AiImportCubit>().addCardsToDecks(
                          deckNameController.text.isEmpty 
                            ? 'AI Generated' 
                            : deckNameController.text
                        );
                      },
                      icon: Icon(Icons.add),
                      label: Text('Add to Deck'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectPdf(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      context.read<AiImportCubit>().selectPdf(file);
    }
  }
}

class _CardPreviewItem extends StatefulWidget {
  final SingleCard card;
  final VoidCallback onDelete;
  final Function(String, String) onEdit;

  const _CardPreviewItem({
    required this.card,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<_CardPreviewItem> createState() => _CardPreviewItemState();
}

class _CardPreviewItemState extends State<_CardPreviewItem> {
  bool isEditing = false;
  late TextEditingController questionController;
  late TextEditingController answerController;

  @override
  void initState() {
    super.initState();
    questionController = TextEditingController(text: widget.card.questionText);
    answerController = TextEditingController(text: widget.card.answerText);
  }

  @override
  void dispose() {
    questionController.dispose();
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEditing) ...[
              TextField(
                controller: questionController,
                decoration: InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 8),
              MarkdownEditor(
                controller: answerController,
                labelText: 'Answer',
                maxLines: 3,
              ),
            ] else ...[
              Text(
                'Q: ${widget.card.questionText}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('A: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
                  Expanded(
                    child: MarkdownCardDisplay(
                      content: widget.card.answerText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isEditing) ...[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        questionController.text = widget.card.questionText;
                        answerController.text = widget.card.answerText;
                        isEditing = false;
                      });
                    },
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onEdit(
                        questionController.text,
                        answerController.text,
                      );
                      setState(() {
                        isEditing = false;
                      });
                    },
                    child: Text('Save'),
                  ),
                ] else ...[
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onDelete,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}