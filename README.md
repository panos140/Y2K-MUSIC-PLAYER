# Y2K-MUSIC-PLAYER

<a href="https://wakatime.com/@f81fa566-77e2-46b8-acdf-ed6fdc96c621"><img src="https://wakatime.com/badge/user/f81fa566-77e2-46b8-acdf-ed6fdc96c621.svg" alt="Total time coded since Jun 12 2026" /></a>

I have always been excited by 2000s music players like the iPod or Winamp, so I decided to build a simple Y2K music player in LOVE2D in Lua. The code isn't anything special, just a simple code, but I think you would like it. I'm still working on some new features, which I will release in the next update.

## Run it

**Option A — Standalone (Windows, easiest)**
1. Download `Y2KMusicPlayer-release.zip` from the [latest release](https://github.com/panos140/Y2K-MUSIC-PLAYER/releases)
2. Unzip it anywhere
3. Double-click `Y2KMusicPlayer.exe`

**Option B — From source (Mac/Linux/Windows)**
1. Install [LÖVE2D](https://love2d.org/) (11.x). It's free, tiny, and works on Mac/Windows/Linux.
2. Unzip the source zip to your desired destination.
3. Run it:
   - **Mac/Linux:** `love .` from inside this folder (or drag the folder onto the LÖVE app)
   - **Windows:** `WIN + R` then `cmd` and paste this `"C:\Program Files\LOVE\love.exe" "C:\path\to\your\project\folder"`, changing the path to wherever you unzipped it

The player starts empty — just drag an `.mp3`, `.ogg`, or `.wav` file onto the window to add it. Everything you drop is saved, so it's still there next time you open it.

## Controls

| Action | Input |
|---|---|
| Play / Pause | `Space` or click the orange center button |
| Next / Prev track | `→` / `←` or the cyan buttons |
| Stop | Magenta square button |
| Volume | `↑` / `↓` or drag the volume slider |
| Seek | Click anywhere on the green progress bar |
| Pick a song | Click it in the playlist, or scroll with your mouse wheel |
| Add a song | Drag an audio file onto the window |

## Screenshots

<img src="https://raw.githubusercontent.com/panos140/Y2K-MUSIC-PLAYER/refs/heads/main/screenshot2.png">
<img src="https://raw.githubusercontent.com/panos140/Y2K-MUSIC-PLAYER/refs/heads/main/screenshot1.png">

## Files

- `main.lua` — all the UI drawing + playback logic (single file, heavily commented)
- `conf.lua` — window setup (460×700, fixed size)
- `music/` — songs you drop onto the player are saved here automatically
