import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simo_learn/utils/image_disk_cache.dart';

/// A picture from the internet that is kept on disk after the first
/// download (see [ImageDiskCache]). Use it instead of `Image.network`
/// everywhere in the app.
///
/// On the web the browser already caches pictures (the server sends a
/// one-year cache header), so it stays a plain `Image.network` there.
///
/// Pass [cacheWidth] (in physical pixels, about 3x the shown size) for small
/// pictures such as avatars: a 2000px photo is then decoded at that size and
/// takes a fraction of the memory.
class NetImage extends StatelessWidget {
  const NetImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.color,
    this.cacheWidth,
    this.cacheHeight,
    this.errorBuilder,
    this.loadingBuilder,
    this.webHtmlElementStrategy = WebHtmlElementStrategy.never,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final Color? color;
  final int? cacheWidth;
  final int? cacheHeight;
  final ImageErrorWidgetBuilder? errorBuilder;
  final ImageLoadingBuilder? loadingBuilder;
  final WebHtmlElementStrategy webHtmlElementStrategy;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        color: color,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        errorBuilder: errorBuilder,
        loadingBuilder: loadingBuilder,
        webHtmlElementStrategy: webHtmlElementStrategy,
      );
    }
    return Image(
      image: ResizeImage.resizeIfNeeded(
        cacheWidth,
        cacheHeight,
        CachedNetImage(url),
      ),
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    );
  }
}

/// The image provider behind [NetImage], for places that need a provider
/// (`DecorationImage`, `precacheImage`).
ImageProvider netImageProvider(String url) {
  if (kIsWeb) return NetworkImage(url);
  return CachedNetImage(url);
}

/// Loads a picture through [ImageDiskCache]. While a picture downloads it
/// reports progress, so `loadingBuilder` placeholders show; a picture already
/// on disk appears without any loading state.
class CachedNetImage extends ImageProvider<CachedNetImage> {
  const CachedNetImage(this.url, {this.scale = 1.0, this.cache});

  final String url;
  final double scale;

  /// The cache to use; [ImageDiskCache.instance] when null (tests swap it).
  final ImageDiskCache? cache;

  @override
  Future<CachedNetImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<CachedNetImage>(this);

  @override
  ImageStreamCompleter loadImage(
    CachedNetImage key,
    ImageDecoderCallback decode,
  ) {
    final chunks = StreamController<ImageChunkEvent>();
    return MultiFrameImageStreamCompleter(
      codec: _load(key, chunks, decode),
      chunkEvents: chunks.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<CachedNetImage>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _load(
    CachedNetImage key,
    StreamController<ImageChunkEvent> chunks,
    ImageDecoderCallback decode,
  ) async {
    final store = key.cache ?? ImageDiskCache.instance;
    try {
      var bytes = await store.cached(key.url);
      if (bytes == null) {
        chunks.add(const ImageChunkEvent(
          cumulativeBytesLoaded: 0,
          expectedTotalBytes: null,
        ));
        bytes = await store.load(
          key.url,
          onProgress: (received, total) {
            if (!chunks.isClosed) {
              chunks.add(ImageChunkEvent(
                cumulativeBytesLoaded: received,
                expectedTotalBytes: total,
              ));
            }
          },
        );
      }
      try {
        return await decode(await ui.ImmutableBuffer.fromUint8List(bytes));
      } catch (_) {
        // A broken file would otherwise fail the same way forever.
        unawaited(store.remove(key.url));
        rethrow;
      }
    } catch (_) {
      // Let the next attempt (e.g. after the connection is back) try again
      // instead of replaying this failure from the memory cache.
      scheduleMicrotask(
        () => PaintingBinding.instance.imageCache.evict(key),
      );
      rethrow;
    } finally {
      unawaited(chunks.close());
    }
  }

  @override
  bool operator ==(Object other) =>
      other is CachedNetImage && other.url == url && other.scale == scale;

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'CachedNetImage')}("$url", scale: $scale)';
}
