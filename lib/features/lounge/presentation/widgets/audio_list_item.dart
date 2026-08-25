import 'package:flutter/material.dart' hide Text;
import 'package:alwan_hub/core/localization/localized_text.dart';

class AudioListItem extends StatelessWidget {
  const AudioListItem({
    super.key,
    required this.index,
    required this.title,
    required this.duration,
    this.subtitle,
    this.imageUrl,
    this.isFavorite = false,
    this.isDownloaded = false,
    this.isPlaying = false,
    this.accentColor = const Color(0xFF5B4CF0),
    this.moreItemLabel = 'أغنية',
    this.onTap,
    this.onPlay,
    this.onFavorite,
    this.onDownload,
    this.onShare,
    this.onLibrary,
    this.onFolders,
    this.onCreateFolder,
    this.onMore,
  });

  final int index;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final Duration duration;
  final bool isFavorite;
  final bool isDownloaded;
  final bool isPlaying;
  final Color accentColor;
  final String moreItemLabel;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final VoidCallback? onFavorite;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;
  final VoidCallback? onLibrary;
  final VoidCallback? onFolders;
  final VoidCallback? onCreateFolder;
  final VoidCallback? onMore;

  String get durationText {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: .07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 25,
                        height: 25,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$index',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: duration.inHours > 0 ? 62 : 44,
                  child: Text(
                    durationText,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onDownload != null)
                  _AudioAction(
                    tooltip: 'تحميل',
                    onPressed: onDownload,
                    icon: isDownloaded
                        ? Icons.download_done_rounded
                        : Icons.download_rounded,
                    color: isDownloaded ? Colors.green : Colors.grey.shade700,
                  ),
                if (onFavorite != null)
                  _AudioAction(
                    tooltip: 'المفضلة',
                    onPressed: onFavorite,
                    icon: isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? Colors.red : Colors.grey.shade700,
                  ),
                if (onPlay != null)
                  _AudioAction(
                    tooltip: isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
                    onPressed: onPlay,
                    icon: isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    color: accentColor,
                    size: 27,
                  ),
                if (onShare != null ||
                    onLibrary != null ||
                    onFolders != null ||
                    onCreateFolder != null)
                  _AudioMorePopup(
                    trackTitle: title,
                    itemLabel: moreItemLabel,
                    onShare: onShare,
                    onLibrary: onLibrary,
                    onFolders: onFolders,
                    onCreateFolder: onCreateFolder,
                  )
                else if (onMore != null)
                  _AudioAction(
                    tooltip: 'المزيد',
                    onPressed: onMore,
                    icon: Icons.more_vert_rounded,
                    color: Colors.grey.shade700,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AudioMorePopup extends StatelessWidget {
  const _AudioMorePopup({
    required this.trackTitle,
    required this.itemLabel,
    this.onShare,
    this.onLibrary,
    this.onFolders,
    this.onCreateFolder,
  });

  final String trackTitle;
  final String itemLabel;
  final VoidCallback? onShare;
  final VoidCallback? onLibrary;
  final VoidCallback? onFolders;
  final VoidCallback? onCreateFolder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 40,
      child: PopupMenuButton<String>(
        tooltip: 'المزيد',
        padding: EdgeInsets.zero,
        icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onSelected: (value) {
          switch (value) {
            case 'share':
              onShare?.call();
              break;
            case 'library':
              onLibrary?.call();
              break;
            case 'folders':
              onFolders?.call();
              break;
            case 'create_folder':
              onCreateFolder?.call();
              break;
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem<String>(
            enabled: false,
            child: SizedBox(
              width: 240,
              child: Text(
                'إضافة $itemLabel "$trackTitle"',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF25263D),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const PopupMenuDivider(),
          if (onShare != null)
            const PopupMenuItem<String>(
              value: 'share',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.share_rounded),
                title: Text('المشاركة'),
              ),
            ),
          if (onLibrary != null)
            const PopupMenuItem<String>(
              value: 'library',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.library_music_rounded),
                title: Text('مكتبتي'),
                subtitle: Text('جميع التصنيفات'),
              ),
            ),
          if (onFolders != null)
            const PopupMenuItem<String>(
              value: 'folders',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.folder_copy_rounded),
                title: Text('مجلداتي'),
              ),
            ),
          if (onCreateFolder != null)
            const PopupMenuItem<String>(
              value: 'create_folder',
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.create_new_folder_rounded),
                title: Text('إنشاء مجلد'),
              ),
            ),
        ],
      ),
    );
  }
}

class _AudioAction extends StatelessWidget {
  const _AudioAction({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    required this.color,
    this.size = 21,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 36, height: 40),
      icon: Icon(icon, color: color, size: size),
    );
  }
}
