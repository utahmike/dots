# USB Audio Keepalive Daemon — Engineering Plan

## Problem

USB audio devices (e.g., Klipsch speakers connected via a dock) on macOS enter a
low-power sleep state when no audio is playing. When audio resumes, there's an
audible pop or delay as the device wakes. The previous workaround was a LaunchAgent
running `play -n synth sine 1 gain -96 repeat -` (SoX) unconditionally — always
on, regardless of whether the USB audio device was connected.

## Goal

Build a self-contained Swift command-line daemon that:

1. Monitors USB audio device connect/disconnect events
2. Plays a near-inaudible signal only to the target device when it's connected
3. Stops when the device disconnects
4. Requires zero third-party dependencies (system frameworks only)
5. Compiles with a single `swiftc` invocation — no Xcode project needed

The binary will eventually be managed by a macOS LaunchAgent, but that integration
is **out of scope** for this plan. Focus on the daemon itself.

---

## Architecture

Three components in a single file (`main.swift`):

### 1. DeviceMonitor

Responsibilities:
- Register an `AudioObjectAddPropertyListenerBlock` on
  `kAudioObjectSystemObject` for `kAudioHardwarePropertyDevices` changes
- On callback: enumerate all audio devices, filter by
  `kAudioDevicePropertyTransportType == kAudioDeviceTransportTypeUSB`
- Match the target device by name via `kAudioObjectPropertyName` (or UID via
  `kAudioDevicePropertyDeviceUID` — name is simpler for the user to configure)
- Notify the coordinator when the target device appears or disappears

CoreAudio device property query pattern (repeated for each property):
```
var address = AudioObjectPropertyAddress(
    mSelector: <property>,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain
)
var size: UInt32 = 0
AudioObjectGetPropertyDataSize(objectID, &address, 0, nil, &size)
AudioObjectGetPropertyData(objectID, &address, 0, nil, &size, &result)
```

This is verbose but mechanical. Consider a small helper function to reduce
repetition:
```swift
func getAudioProperty<T>(objectID: AudioObjectID, selector: AudioObjectPropertySelector, scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal) -> T?
```

### 2. AudioKeepAlive

Responsibilities:
- Manage an `AVAudioEngine` instance
- Attach an `AVAudioSourceNode` that fills buffers with a near-silent sine wave
  (amplitude ~0.0001, frequency 1 Hz — below audible threshold but enough to
  keep the USB DAC active)
- Set the output device on the engine's output node to the specific
  `AudioDeviceID` using:
  ```swift
  AudioUnitSetProperty(
      outputNode.audioUnit!,
      kAudioOutputUnitProperty_CurrentDevice,
      kAudioUnitScope_Global, 0,
      &deviceID, UInt32(MemoryLayout<AudioDeviceID>.size)
  )
  ```
- Expose `start(deviceID:)` and `stop()` methods
- Handle errors gracefully (device removed mid-playback, etc.)

### 3. Main / Coordinator

- Parse command-line arguments for target device name (with a sensible default,
  or require it as a flag: `--device "Klipsch"`)
- Wire DeviceMonitor callbacks to AudioKeepAlive start/stop
- Call `dispatchMain()` to run the event loop indefinitely
- Handle SIGTERM/SIGINT for clean shutdown

---

## Device Matching Strategy

The user should be able to specify a partial device name match (case-insensitive
substring). For example, `--device "Klipsch"` should match a device named
"Klipsch ProMedia". This avoids requiring the user to find the exact
`AudioDeviceUID` string.

On startup, perform an initial device scan (don't wait for the first change
event). If the target device is already connected, start playback immediately.

---

## Build

Single-file compilation, no Package.swift:

```bash
swiftc -O -framework CoreAudio -framework AudioToolbox -framework AVFAudio \
    main.swift -o usb-audio-keepalive
```

The binary dynamically links system frameworks (no static linking needed — these
ship with every macOS install).

Target output location: `~/.local/bin/usb-audio-keepalive` (or wherever the user
prefers).

---

## Logging

Use `os_log` (or plain stderr) for:
- Startup: which device name we're watching for
- Device connected: "Target device found: <name> (ID: <id>), starting keepalive"
- Device disconnected: "Target device removed, stopping keepalive"
- Errors: engine start failures, device property query failures

Keep it minimal — this runs as a daemon. No verbose per-buffer logging.

---

## Edge Cases

1. **Multiple matching devices** — Use the first match. Log a warning if multiple
   devices match the name filter.
2. **Device disconnects while playing** — `AVAudioEngine` will error. Catch it
   and stop cleanly. The device monitor will fire a separate disconnect event.
3. **Device reconnects rapidly** — The listener fires per-change. Debounce isn't
   strictly necessary since start/stop are idempotent, but avoid starting if
   already started.
4. **No matching device at startup** — Log and wait. The listener will fire when
   the device connects.
5. **System sleep/wake** — CoreAudio device notifications fire on wake if the
   device list changed. No special handling needed.

---

## Test Plan

### Manual Testing (this is a single-file daemon, not a library)

1. **Build succeeds** — `swiftc` compiles without errors or warnings
2. **Startup with device connected** — binary starts, logs device found, plays
   silence (verify with Audio MIDI Setup or `log stream --predicate`)
3. **Startup without device** — binary starts, logs waiting, no audio engine
   running
4. **Hot-plug connect** — plug in USB audio device, verify keepalive starts
   within 1-2 seconds
5. **Hot-plug disconnect** — unplug, verify keepalive stops, no crash
6. **Reconnect cycle** — unplug/replug several times, verify stable behavior
7. **CPU usage** — confirm near-zero CPU usage during playback (playing silence
   to a USB DAC should be negligible)
8. **SIGTERM** — `kill <pid>`, verify clean shutdown
9. **Wrong device name** — pass a name that doesn't match anything, verify it
   waits indefinitely without errors

---

## Open Questions

1. **Device name for Klipsch speakers** — Need to determine the exact CoreAudio
   device name. Run: `system_profiler SPAudioDataType` or use the AudioDeviceID
   enumeration in the program itself to list devices on first run (e.g.,
   `--list-devices` flag).
2. **Sine wave vs silence** — A true zero-amplitude signal may not prevent sleep
   on all USB DACs. The SoX approach used gain -96 dB (~0.000016 amplitude).
   Start with amplitude 0.0001 and adjust if needed.
3. **Sample rate** — Should match the device's preferred sample rate. Query
   `kAudioDevicePropertyNominalSampleRate` from the target device and configure
   the audio engine accordingly, rather than hardcoding 44100 or 48000.

---

## Out of Scope

- LaunchAgent plist and makefile integration (separate follow-up once the binary
  is stable)
- GUI or menu bar app
- Cross-platform support
- Automatic device name discovery (user provides the name)
