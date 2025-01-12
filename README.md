Video player for flutter web & mobile devices, pod player supports playing video from `Youtube` and `Vimeo`

pod player is a simple and easy-to-use video player. Its video controls are similar to Youtube player (with customizable controls) and also can play videos from `Youtube` and `Vimeo` (By providing url/video_id).

This plugin built upon flutter's official [`video_player`](https://pub.dartlang.org/packages/video_player) plugin

This plugin fork from pod_player official [`pod_player`](https://pub.dev/packages/pod_player) plugin.

---

| PLATFORM | AVAILABLE |
| :------: | :-------: |
| Android  |    ✅     |
|   IOS    |    ✅     |
|   WEB    |    ✅     |

## Features

- Play `youtube` videos (using video URL or ID)
- Play `vimeo` videos (using video ID [with ou without hash])
- Play `vimeo` private videos (using video ID [with ou without hash], access token)
- Video overlay similar to youtube
- `Double tap` to seek video.
- On video tap show/hide video overlay.
- Auto hide overlay
- Change `playback speed`
- Custom overlay
- Custom progress bar
- Custom labels
- `Change video quality` (for vimeo and youtube)
- Enable/disable full-screen player
- support for live youtube video
- [TODO] support for video playlist

## Features on web

- Double tap on Video player to enable/disable full-screen
- `Mute/unMute` volume
- Video player integration with keyboard

  - `SPACE` play/pause video
  - `M` mute/unMute video
  - `F` enable/disable full-screen
  - `ESC` enable/disable full-screen
  - `->` seek video forward
  - `<-` seek video backward

- Double tap on video (enable/disables full-screen)

## Example

---

Please run the app in the [`example/`](https://github.com/ayahsujana/foodly_pod_player/tree/master/example) folder to start playing!
