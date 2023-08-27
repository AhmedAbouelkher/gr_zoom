import 'package:flutter/services.dart';
import 'package:gr_zoom/gr_zoom_platform_interface.dart';

class MethodChannelZoom extends ZoomPlatform {
  final MethodChannel channel = MethodChannel('plugins.webcare/zoom_channel');

  /// The event channel used to interact with the native platform.
  final EventChannel meetingStatusChannel =
      EventChannel('plugins.webcare/zoom_event_stream');

  final EventChannel inMeetingServiceChannel =
      EventChannel('plugins.webcare/zoom_in_meeting_event_stream');
  @override
  Future<List> initZoom(ZoomOptions options) async {
    var optionMap = new Map<String, String>();
    if (options.appKey != null) {
      optionMap.putIfAbsent("appKey", () => options.appKey!);
    }
    if (options.appSecret != null) {
      optionMap.putIfAbsent("appSecret", () => options.appSecret!);
    }
    if (options.jwtToken != null) {
      optionMap.putIfAbsent("jwtToken", () => options.jwtToken!);
    }
    optionMap.putIfAbsent("domain", () => options.domain);
    return channel
        .invokeMethod<List>('init', optionMap)
        .then<List>((List? value) => value ?? List.empty());
  }

  @override
  Future<bool> joinMeeting(ZoomMeetingOptions options) async {
    final optionMap = Map<String, String>();
    optionMap.putIfAbsent("userId", () => options.userId);
    optionMap.putIfAbsent("meetingId", () => options.meetingId);
    optionMap.putIfAbsent("meetingPassword", () => options.meetingPassword);
    if (options.meetingViewOptions != null) {
      optionMap.putIfAbsent(
          "meetingViewOptions", () => options.meetingViewOptions!.toString());
    }

    return channel
        .invokeMethod<bool>('join', optionMap)
        .then<bool>((bool? value) => value ?? false);
  }

  @override
  Future<void> leaveMeeting() async {
    await channel.invokeMethod<bool>('leave');
  }

  @override
  Future<List> meetingStatus(String meetingId) async {
    var optionMap = new Map<String, String>();
    optionMap.putIfAbsent("meetingId", () => meetingId);

    return channel
        .invokeMethod<List>('meeting_status', optionMap)
        .then<List>((List? value) => value ?? List.empty());
  }

  @override
  Stream<dynamic> onMeetingStatus() {
    return meetingStatusChannel.receiveBroadcastStream();
  }

  @override
  Stream<dynamic> listenToInMeetingService() {
    return inMeetingServiceChannel.receiveBroadcastStream();
  }
}
