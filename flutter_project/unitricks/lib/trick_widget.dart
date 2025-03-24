import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
//import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class UnicycleTrickWidget extends StatefulWidget {
  final String name;
  final List<String> tags;
  final String description;
  final String proposedBy;
  final List<String> videoLinks;
  final List<String> startPositions;
  final List<String> endPositions;

  const UnicycleTrickWidget({
    super.key,
    required this.name,
    required this.tags,
    required this.description,
    required this.proposedBy,
    required this.videoLinks,
    required this.startPositions,
    required this.endPositions,
  });

  @override
  State<UnicycleTrickWidget> createState() => _UnicycleTrickWidgetState();
}

class _UnicycleTrickWidgetState extends State<UnicycleTrickWidget> {
  // final List<YoutubePlayerController> _videoController = [];

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      for (int i = 0; i < widget.videoLinks.length; i++) {
        final vlUri = Uri.parse(widget.videoLinks[i]);
        final id = vlUri.queryParameters['v'] ?? vlUri.pathSegments[0];
        final startT = double.tryParse((vlUri.queryParameters['t'] ?? '').replaceFirst('s', ''));
        //_videoController.add(YoutubePlayerController.fromVideoId(videoId: id, startSeconds: startT));
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          const SizedBox(height: 12),
          // Display trick name
          Text(
            widget.name,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          //const SizedBox(height: 8),

          // Display who proposed the trick
          Text('Proposed by: ${widget.proposedBy}'),
          //const SizedBox(height: 16),
      
          // Display tags within chips
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: widget.tags
                .map((tag) => Chip(
                      label: Text(tag),
                    ))
                .toList(),
          ),
          //const SizedBox(height: 16),

          // Display description
          if (widget.description.isNotEmpty) ...[
            Text(
              'Description',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(widget.description),
            //const SizedBox(height: 16),
          ],

          // Display start position images
          if (widget.startPositions.isNotEmpty) ...[
            Text(
              'Start Positions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            //const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.start,
              children: widget.startPositions.map((pos) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Image(
                    image: AssetImage('assets/positions/$pos.png'),
                    width: 32,
                    height: 51,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
            ),
            //const SizedBox(height: 16),
          ],

          // Display end position images
          if (widget.endPositions.isNotEmpty) ...[
            Text(
              'End Positions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            //const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.start,
              children: widget.endPositions.map((pos) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Image(
                    image: AssetImage('assets/positions/$pos.png'),
                    width: 32,
                    height: 51,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
            ),
            //const SizedBox(height: 16),
          ],

          // Display video links as embedded YouTube players
          if (widget.videoLinks.isNotEmpty) ...[
            Text(
              'Video Links',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            for (int i = 0; i < widget.videoLinks.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: kIsWeb ? SizedBox(
                  width: 300,
                  child: HtmlWidget(
                    '''
                      <iframe title="YouTube video player" src="${widget.videoLinks[i]}"</iframe>
                    ''',
                  ),//YoutubePlayer(controller: _videoController[i]),
                ) :
                InkWell(
                  child: Text(widget.videoLinks[i]),
                  onTap: () => {launchUrlString(widget.videoLinks[i])},
                )
              )
          ],
        ],
      ),
    );
  }
}