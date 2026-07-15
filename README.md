# Y2K-MUSIC-PLAYER
<img src="https://img.shields.io/badge/hackatime-1h%2043m-blue">
<img src="https://github-readme-stats.hackclub.dev/api/wakatime?username=33335&api_domain=hackatime.hackclub.com&theme=dark&custom_title=Hackatime+Stats&layout=compact&cache_seconds=0&langs_count=8">
I have always been excited by 2000s music players like the iPod or Winamp, so I decided to build a simple Y2K music player in LOVE2D in Lua.  The code isn’t anything special, just a simple code, but I think you would like it. I’m still working on some new features, which I will release in the next update.

## Run it

1. Install [LÖVE2D](https://love2d.org/) (11.x). It's free, tiny, and works on Mac/Windows/Linux.
2. Unzip the zip file to you desired destination.
3. Drop some `.mp3`, `.ogg`, or `.wav` files into the `music/` folder.
4. Run it:
   - **Mac/Linux:** `love .` from inside this folder (or drag the folder onto the LÖVE app)
   - **Windows:** `WIN + R` then `cmd` and paste this `"C:\Program Files\LOVE\love.exe" "C:\path\to\your\project\folder"` change the path that you installed the zip
5. If you don't add any songs, the player still runs — the screen will just tell you to drop some in.

## Controls

| Action | Input |
|---|---|
| Play / Pause | `Space` or click the orange center button |
| Next / Prev track | `→` / `←` or the cyan buttons |
| Stop | Magenta square button |
| Volume | `↑` / `↓` or drag the volume slider |
| Seek | Click anywhere on the green progress bar |
| Pick a song | Click it in the playlist, or scroll with your mouse wheel |

## Files

- `main.lua` — all the UI drawing + playback logic (single file, heavily commented)
- `conf.lua` — window setup (460×700, fixed size)
- `music/` — put your audio files here
