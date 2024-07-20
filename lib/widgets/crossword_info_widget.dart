import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:generate_crossword/providers.dart';
import 'package:generate_crossword/utils.dart';

class CrosswordInfoWidget extends ConsumerWidget {
  const CrosswordInfoWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = ref.watch(sizeProvider);
    final displayInfo = ref.watch(displayinfoprovider);
    final workerCount = ref.watch(workerCountProvider).label;
    final startTime = ref.watch(startTimeProvider);
    final endTime = ref.watch(endTimeProvider);
    final remaining = ref.watch(expectedRemainingTimeProvider);

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(
          right: 32.0,
          bottom: 32.0,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ColoredBox(
            color: Theme.of(context).colorScheme.onPrimary.withAlpha(230),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CrosswordInfoRichText(
                        label: 'Grid Size',
                        value: '${size.width} x ${size.height}'),
                    _CrosswordInfoRichText(
                        label: 'Words in grid',
                        value: displayInfo.wordsInGridCount.toString()),
                    _CrosswordInfoRichText(
                        label: 'Candidate words',
                        value: displayInfo.candidateWordsCount.toString()),
                    _CrosswordInfoRichText(
                        label: 'Locations to explore',
                        value: displayInfo.locationsToExploreCount.toString()),
                    _CrosswordInfoRichText(
                        label: 'Known bad locations',
                        value: displayInfo.knownBadLocationsCount.toString()),
                    _CrosswordInfoRichText(
                        label: 'Grid filled',
                        value: displayInfo.gridFilledPercentage.toString()),
                    _CrosswordInfoRichText(
                        label: 'Max worker count', value: workerCount),
                    if (startTime.state == null)
                      _CrosswordInfoRichText(
                          label: 'Time elapsed', value: 'Not started yet')
                    else if (endTime.state == null)
                      StreamBuilder(
                        stream: Stream.periodic(Duration(seconds: 1)),
                        builder: (context, snapshot) {
                          final elapsed =
                              DateTime.now().difference(startTime.state!);
                          return _CrosswordInfoRichText(
                            label: 'Time elapsed',
                            value: formatDuration(elapsed),
                          );
                        },
                      )
                    else
                      _CrosswordInfoRichText(
                          label: 'Completed in',
                          value: formatDuration(
                              endTime.state!.difference(startTime.state!))),
                    if (startTime.state != null && endTime.state == null)
                      _CrosswordInfoRichText(
                          label: 'Est. remaining',
                          value: formatDuration(remaining)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CrosswordInfoRichText extends StatelessWidget {
  final String label;
  final String value;

  const _CrosswordInfoRichText({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: DefaultTextStyle.of(context).style,
            ),
            TextSpan(
              text: value,
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
}

// Utility function to format durations
String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$hours:$minutes:$seconds";
}
