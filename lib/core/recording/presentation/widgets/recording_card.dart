import 'package:flutter/material.dart';

import 'package:alwan_hub/core/recording/models/recording_file.dart';

class RecordingCard extends StatelessWidget {
  const RecordingCard({
    super.key,
    required this.recording,
    this.selected = false,
    this.selectionMode = false,
    this.onTap,
    this.onLongPress,
    this.onMore,
  });

  final RecordingFile recording;
  final bool selected;
  final bool selectionMode;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onMore;

  ImageProvider<Object>? _recordingImage() {
    final imagePath = recording.imageUrl;
    if (imagePath == null || imagePath.trim().isEmpty) {
      return null;
    }
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return NetworkImage(imagePath);
    }
    return AssetImage(imagePath);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recordingImage = _recordingImage();

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: selected
              ? theme.colorScheme.primary
              : Colors.transparent,
          width: 1.6,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Hero(
                tag: recording.id,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(18),
                    color: theme
                        .colorScheme
                        .surfaceContainerHighest,
                    image: recordingImage != null
                        ? DecorationImage(
                            image: recordingImage,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: recordingImage == null
                      ? const Icon(
                          Icons.multitrack_audio,
                          size: 32,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      recording.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight:
                                FontWeight.w700,
                          ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      recording.folderName,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: theme
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: theme
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          _formatDuration(
                            recording.duration,
                          ),
                          style: theme
                              .textTheme
                              .labelMedium,
                        ),

                        const SizedBox(width: 16),

                        const Icon(
                          Icons.sd_storage,
                          size: 16,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          _formatSize(
                            recording.fileSize,
                          ),
                          style: theme
                              .textTheme
                              .labelMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (selectionMode)
                Checkbox(
                  value: selected,
                  onChanged: (_) => onTap?.call(),
                )
              else
                IconButton(
                  onPressed: onMore,
                  icon: const Icon(
                    Icons.more_vert,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);

    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${s.toString().padLeft(2, '0')}';
    }

    return '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
