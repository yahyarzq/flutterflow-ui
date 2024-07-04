/*
 * Copyright 2019 Florent37
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * The source code used herein has been modified and added to.
 */

import 'dart:math' as math;
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutterflow_ui/src/utils/flutter_flow_helpers.dart'
    show routeObserver;

export 'package:assets_audio_player/assets_audio_player.dart';

/// A widget that displays an audio player with playback controls and a seek bar.
///
/// The [FlutterFlowAudioPlayer] widget is used to play audio files. It provides
/// playback controls such as play/pause button, title, and playback duration.
/// It also includes a seek bar to allow users to seek to a specific position
/// in the audio file.
///
/// The [FlutterFlowAudioPlayer] requires an [Audio] object to specify the audio
/// file to be played. It also accepts various customization options such as
/// text styles, colors, elevation, and more.
///
/// Example usage:
/// ```dart
/// FlutterFlowAudioPlayer(
///   audio: Audio(
///     path: 'path/to/audio.mp3',
///     audioType: AudioType.network,
///   ),
///   titleTextStyle: TextStyle(
///     fontSize: 16,
///     fontWeight: FontWeight.bold,
///   ),
///   playbackDurationTextStyle: TextStyle(
///     fontSize: 14,
///     color: Colors.grey,
///   ),
///   fillColor: Colors.white,
///   playbackButtonColor: Colors.blue,
///   activeTrackColor: Colors.blue,
///   elevation: 4,
///   pauseOnNavigate: true,
///   playInBackground: PlayInBackground.enabled,
/// )
/// ```
class FlutterFlowAudioPlayer extends StatefulWidget {
  /// Creates a [FlutterFlowAudioPlayer] widget.
  ///
  /// - [audio] parameter is required and specifies the audio file to be played.
  /// - [titleTextStyle] and [playbackDurationTextStyle] parameters are required
  /// and define the text styles for the title and playback duration respectively.
  /// - [fillColor], [playbackButtonColor], [activeTrackColor], and [inactiveTrackColor]
  /// parameters are used to customize the colors of the audio player.
  /// - [elevation] parameter specifies the elevation of the audio player.
  /// - [pauseOnNavigate] parameter determines whether the audio should be paused
  /// when navigating to a different screen.
  /// - [playInBackground] parameter specifies whether the audio should continue
  /// playing in the background when the app is not in the foreground.
  const FlutterFlowAudioPlayer({
    super.key,
    required this.audio,
    required this.titleTextStyle,
    required this.playbackDurationTextStyle,
    required this.fillColor,
    required this.playbackButtonColor,
    required this.activeTrackColor,
    this.inactiveTrackColor,
    required this.elevation,
    this.pauseOnNavigate = true,
    required this.playInBackground,
  });

  final Audio audio;
  final TextStyle titleTextStyle;
  final TextStyle playbackDurationTextStyle;
  final Color fillColor;
  final Color playbackButtonColor;
  final Color activeTrackColor;
  final Color? inactiveTrackColor;
  final double elevation;
  final bool pauseOnNavigate;
  final PlayInBackground playInBackground;

  @override
  State<FlutterFlowAudioPlayer> createState() => _FlutterFlowAudioPlayerState();
}

class _FlutterFlowAudioPlayerState extends State<FlutterFlowAudioPlayer>
    with RouteAware {
  AssetsAudioPlayer? _assetsAudioPlayer;
  bool _subscribedRoute = false;

  @override
  void initState() {
    super.initState();
    openPlayer();
  }

  Future openPlayer() async {
    _assetsAudioPlayer ??=
        AssetsAudioPlayer.withId(generateRandomAlphaNumericString());
    if (_assetsAudioPlayer?.playlist != null) {
      _assetsAudioPlayer!.playlist!.replaceAt(0, (oldAudio) => widget.audio);
    } else {
      await _assetsAudioPlayer!.open(
        Playlist(audios: [widget.audio]),
        autoStart: false,
        playInBackground: widget.playInBackground,
      );
    }
  }

  @override
  void dispose() {
    if (_subscribedRoute) {
      routeObserver.unsubscribe(this);
    }
    _assetsAudioPlayer?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FlutterFlowAudioPlayer old) {
    super.didUpdateWidget(old);
    final changed = old.audio.path != widget.audio.path ||
        old.audio.audioType != widget.audio.audioType;
    final isPlaying = _assetsAudioPlayer?.isPlaying.value ?? false;
    if (changed && !isPlaying) {
      openPlayer();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.pauseOnNavigate && ModalRoute.of(context) is PageRoute) {
      _subscribedRoute = true;
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    }
  }

  @override
  void didPushNext() {
    if (widget.pauseOnNavigate) {
      _assetsAudioPlayer?.pause();
    }
  }

  Duration currentPosition(RealtimePlayingInfos infos) =>
      infos.currentPosition.ensureFinite;
  Duration duration(RealtimePlayingInfos infos) => infos.duration.ensureFinite;

  String playbackStateText(RealtimePlayingInfos infos) {
    final currentPositionString = durationToString(currentPosition(infos));
    final durationString = durationToString(duration(infos));
    return '$currentPositionString/$durationString';
  }

  @override
  Widget build(BuildContext context) =>
      _assetsAudioPlayer!.builderRealtimePlayingInfos(
          builder: (context, infos) => PlayerBuilder.isPlaying(
              player: _assetsAudioPlayer!,
              builder: (context, isPlaying) {
                final childWidget = Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: widget.fillColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  15, 10, 0, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.audio.metas.title ?? 'Audio Title',
                                    style: widget.titleTextStyle,
                                  ),
                                  Text(
                                    playbackStateText(infos),
                                    style: widget.playbackDurationTextStyle,
                                  )
                                ],
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(34),
                            child: Material(
                              color: Colors.transparent,
                              child: IconButton(
                                onPressed: _assetsAudioPlayer!.playOrPause,
                                icon: Icon(
                                  isPlaying
                                      ? Icons.pause_circle_filled_rounded
                                      : Icons.play_circle_fill_rounded,
                                  color: widget.playbackButtonColor,
                                  size: 34,
                                ),
                                iconSize: 34,
                              ),
                            ),
                          ),
                        ],
                      ),
                      PositionSeekWidget(
                        currentPosition: currentPosition(infos),
                        duration: duration(infos),
                        seekTo: (to) {
                          _assetsAudioPlayer!.seek(to);
                        },
                        activeTrackColor: widget.activeTrackColor,
                        inactiveTrackColor: widget.inactiveTrackColor,
                      ),
                    ],
                  ),
                );
                return Material(
                    color: Colors.transparent,
                    elevation: widget.elevation,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: childWidget);
              }));
}

/// Widget that represents the position seek bar in the audio player.
class PositionSeekWidget extends StatefulWidget {
  const PositionSeekWidget({
    super.key,
    required this.currentPosition,
    required this.duration,
    required this.seekTo,
    required this.activeTrackColor,
    this.inactiveTrackColor,
  });

  /// The current position of the audio playback.
  final Duration currentPosition;

  /// The total duration of the audio.
  final Duration duration;

  /// Callback function to seek to a specific position in the audio.
  final Function(Duration) seekTo;

  /// The color of the active track in the seek bar.
  final Color activeTrackColor;

  /// The color of the inactive track in the seek bar.
  final Color? inactiveTrackColor;

  @override
  State<PositionSeekWidget> createState() => _PositionSeekWidgetState();
}

class _PositionSeekWidgetState extends State<PositionSeekWidget> {
  late Duration _visibleValue;
  bool listenOnlyUserInteraction = false;

  /// The percentage of the current position in relation to the total duration.
  double get percent => widget.duration.inMilliseconds == 0
      ? 0
      : _visibleValue.inMilliseconds / widget.duration.inMilliseconds;

  @override
  void initState() {
    super.initState();
    _visibleValue = widget.currentPosition;
  }

  @override
  void didUpdateWidget(PositionSeekWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listenOnlyUserInteraction) {
      _visibleValue = widget.currentPosition;
    }
  }

  @override
  Widget build(BuildContext context) => SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: widget.activeTrackColor,
          inactiveTrackColor:
              widget.inactiveTrackColor ?? const Color(0xFFC9D0D5),
          trackShape: const FlutterFlowRoundedRectSliderTrackShape(),
          trackHeight: 6.0,
          thumbShape: SliderComponentShape.noThumb,
          overlayColor: const Color(0xFF57636C).withAlpha(32),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
        ),
        child: Slider(
          min: 0,
          max: widget.duration.inMilliseconds.toDouble(),
          value: math.min(1.0, percent) *
              widget.duration.inMilliseconds.toDouble(),
          onChangeEnd: (newValue) => setState(() {
            listenOnlyUserInteraction = false;
            widget.seekTo(_visibleValue);
          }),
          onChangeStart: (_) =>
              setState(() => listenOnlyUserInteraction = true),
          onChanged: (newValue) => setState(
              () => _visibleValue = Duration(milliseconds: newValue.floor())),
        ),
      );
}

/// Converts a [Duration] object to a formatted string in the format "mm:ss".
String durationToString(Duration duration) {
  String twoDigits(int n) => (n >= 10) ? '$n' : '0$n';

  final twoDigitMinutes =
      twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour).toInt());
  final twoDigitSeconds = twoDigits(
      duration.inSeconds.remainder(Duration.secondsPerMinute).toInt());
  return '$twoDigitMinutes:$twoDigitSeconds';
}

/// Custom slider track shape for the audio player seek bar.
class FlutterFlowRoundedRectSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  /// Create a slider track that draws two rectangles with rounded outer edges.
  const FlutterFlowRoundedRectSliderTrackShape();

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    Offset? secondaryOffset,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    // If the slider [SliderThemeData.trackHeight] is less than or equal to 0,
    // then it makes no difference whether the track is painted or not,
    // therefore the painting  can be a no-op.
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor,
        end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;
    final Paint leftTrackPaint = activePaint;
    final Paint rightTrackPaint = inactivePaint;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    const Radius trackRadius = Radius.circular(2.0);
    const Radius activeTrackRadius = Radius.circular(2.0);

    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        thumbCenter.dx - activeTrackRadius.x,
        trackRect.top,
        trackRect.right,
        trackRect.bottom,
        topRight: trackRadius,
        bottomRight: trackRadius,
        topLeft: activeTrackRadius,
        bottomLeft: activeTrackRadius,
      ),
      rightTrackPaint,
    );
    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.left,
        trackRect.top - (additionalActiveTrackHeight / 2),
        thumbCenter.dx,
        trackRect.bottom + (additionalActiveTrackHeight / 2),
        topLeft: activeTrackRadius,
        bottomLeft: activeTrackRadius,
        topRight: trackRadius,
        bottomRight: trackRadius,
      ),
      leftTrackPaint,
    );
  }
}

/// Generates a random alphanumeric string of length 8.
String generateRandomAlphaNumericString() {
  const chars = 'abcdefghijklmnopqrstuvwxyz1234567890';
  return String.fromCharCodes(Iterable.generate(
      8, (_) => chars.codeUnits[math.Random().nextInt(chars.length)]));
}

extension _AudioPlayerDurationExtensions on Duration {
  /// Ensures that the duration is finite by returning [Duration.zero] if it is not.
  Duration get ensureFinite => inMicroseconds.isFinite ? this : Duration.zero;
}
