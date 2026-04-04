import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/ui/Contenu/WidgetContenu/contenu_image_widget.dart';
import 'package:factoscope/ui/Contenu/WidgetContenu/contenu_audio_widget.dart';
import 'package:factoscope/ui/Contenu/WidgetContenu/contenu_video_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ContenuCoursView extends StatelessWidget {
  final Cours cours;
  final int selectedPageIndex;

  const ContenuCoursView({
    super.key,
    required this.cours,
    required this.selectedPageIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (cours.pages == null ||
        selectedPageIndex < 0 ||
        selectedPageIndex >= cours.pages!.length) {
      if (kDebugMode) print("Page introuvable");
      return const Center(child: Text("Page introuvable"));
    }

    var page = cours.pages![selectedPageIndex];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (page.description != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                page.description!,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          if (page.contenu != null && page.contenu!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: MarkdownBlock(
                text: page.contenu!,
                baseStyle: const TextStyle(
                  fontSize: 17,
                  height: 1.7,
                  color: Colors.black87,
                ),
              ),
            ),
          if (page.medias != null && page.medias!.isNotEmpty)
            ...page.medias!.map((media) {
              if (media.type == "image") {
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ContenuImageWidget(media: media));
              } else if (media.type == "video") {
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ContenuVideoWidget(data: media));
              } else if (media.type == "audio") {
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ContenuAudioWidget(urlAudio: media.url));
              } else {
                return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Le Media n'a pas le bon type !"));
              }
            }),
        ],
      ),
    );
  }
}

class MarkdownBlock extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;

  const MarkdownBlock({super.key, required this.text, required this.baseStyle});

  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n');
    final List<Widget> widgets = [];

    for (final line in lines) {
      final trimmed = line.trimLeft();
      if (trimmed.startsWith('- ')) {
        final content = trimmed.substring(2);
        widgets.add(_BulletLine(content: content, baseStyle: baseStyle));
      } else if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 6));
      } else {
        widgets.add(RichTextParser(text: line, baseStyle: baseStyle));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String content;
  final TextStyle baseStyle;

  const _BulletLine({required this.content, required this.baseStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3.0, right: 8.0),
            child: Text('•',
                style: baseStyle.copyWith(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: RichTextParser(text: content, baseStyle: baseStyle),
          ),
        ],
      ),
    );
  }
}

class RichTextParser extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;

  const RichTextParser(
      {super.key, required this.text, required this.baseStyle});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(style: baseStyle, children: _parseSpans(text)),
    );
  }

  List<InlineSpan> _parseSpans(String input) {
    final List<InlineSpan> spans = [];

    final regex = RegExp(
      r'\*\*(.+?)\*\*' // **gras**
      r'|\*(.+?)\*' // *italique*
      r'|(https?://\S+)', // lien
    );

    int cursor = 0;

    for (final match in regex.allMatches(input)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: input.substring(cursor, match.start)));
      }

      if (match.group(1) != null) {
        spans.add(TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(2) != null) {
        spans.add(TextSpan(
          text: match.group(2),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(3) != null) {
        final url = match.group(3)!;
        spans.add(TextSpan(
          text: url,
          style: baseStyle.copyWith(
            color: Colors.blue,
            decoration: TextDecoration.underline,
            decorationColor: Colors.blue,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final uri = Uri.tryParse(url);
              if (uri == null) return;
              try {
                final launched = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
                if (!launched) {
                  await launchUrl(uri, mode: LaunchMode.platformDefault);
                }
              } catch (e) {
                if (kDebugMode) print('❌ Impossible d\'ouvrir $url : $e');
              }
            },
        ));
      }

      cursor = match.end;
    }

    if (cursor < input.length) {
      spans.add(TextSpan(text: input.substring(cursor)));
    }

    return spans;
  }
}
