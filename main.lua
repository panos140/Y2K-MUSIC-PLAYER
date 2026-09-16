--[[
    Y2K PLAYER
    BY PANOSTSAK
    GITHUB: PANOS140
    ALGORITHMICS GR 
    CODENAME: 2000S PLAYER
]]

-- ================== Palette ==================
 
local COL = {
    bgTop = {1.00, 0.42, 0.71},
    bgBottom = {0.36, 0.20, 0.85},
    shell = {0.80, 0.82, 0.88},
    shellHi = {1.00, 1.00, 1.00},
    shellLo = {0.38, 0.38, 0.46},
    screenBg = {0.04, 0.12, 0.10},
    screenLine = {0.35, 1.00, 0.55},
    screenDim = {0.15, 0.55, 0.30},
    btnOrange = {1.00, 0.55, 0.15},
    btnCyan = {0.20, 0.90, 0.95},
    btnMagenta = {1.00, 0.30, 0.65},
    btnGrey = {0.85, 0.85, 0.90},
    text = {0.15, 0.10, 0.25},
    textLight = {1.00, 1.00, 1.00},
}
 
-- ================== State ==================
 
local playlist = {}
local currentIndex = 1
local source = nil
local playing = false
local volume = 0.7
local marqueeOffset = 0
 
local barsFont
local titleFont
local smallFont
 
local bars = {}
local NUM_BARS = 20
local barTimer = 0
 
local pressedButton = nil
 
local screen = {
    x = 40,
    y = 60,
    w = 380,
    h = 190
}
 
local scrollOffset = 0
 
local dropMessage = ""
local dropMessageTimer = 0
 
local buttons = {}
 
local loadTrack
 
-- Startup state
local musicFolderScanned = false
 
-- ================== Helpers ==================
 
local function lerp(a, b, t)
    return a + (b - a) * t
end
 
local function clamp(v, lo, hi)
    if v < lo then
        return lo
    elseif v > hi then
        return hi
    end
 
    return v
end
 
local function setColor(c, a)
    love.graphics.setColor(
        c[1],
        c[2],
        c[3],
        a or 1
    )
end
 
-- ================== Physical Music Folder ==================
 
local function getMusicFolder()
    -- getSourceBaseDirectory() returns the PARENT of the project folder
    -- (e.g. Desktop, not Desktop/Y2KY PLAYER) -- that was the bug.
    -- getSource() returns the actual project folder when running unfused.
    local basePath = love.filesystem.getSource()
    return basePath .. "\\music"
end
 
local function isAudioFile(filename)
 
    if type(filename) ~= "string" then
        return false
    end
 
    local ext =
        filename:match("%.([%a%d]+)$")
 
    if not ext then
        return false
    end
 
    ext = ext:lower()
 
    return ext == "mp3"
        or ext == "ogg"
        or ext == "wav"
end
 
-- ================== Safe Display ==================
 
local function getSafeName(name, index)
 
    if type(name) ~= "string" then
        return "TRACK " .. tostring(index)
    end
 
    local ok =
        pcall(
            love.graphics.getFont().getWidth,
            love.graphics.getFont(),
            name
        )
 
    if ok then
        return name
    end
 
    return "TRACK " .. tostring(index)
end
 
-- ================== Scan Music Folder ==================
 
local function scanMusicFolder()
 
    playlist = {}
 
    local ok, files =
        pcall(
            love.filesystem.getDirectoryItems,
            "music"
        )
 
    if not ok or not files then
        return
    end
 
    for _, filename in ipairs(files) do
 
        if isAudioFile(filename) then
 
            table.insert(
                playlist,
                {
                    name = filename,
 
                    -- love.filesystem only understands paths relative to
                    -- the project folder ("music/song.mp3"), NOT absolute
                    -- OS paths -- that was the second bug.
                    path = "music/" .. filename
                }
            )
        end
    end
 
    table.sort(
        playlist,
        function(a, b)
 
            local okA, aName =
                pcall(
                    string.lower,
                    a.name
                )
 
            local okB, bName =
                pcall(
                    string.lower,
                    b.name
                )
 
            if not okA then
                aName = ""
            end
 
            if not okB then
                bName = ""
            end
 
            return aName < bName
        end
    )
 
    if #playlist == 0 then
 
        currentIndex = 1
        scrollOffset = 0
 
    else
 
        if currentIndex > #playlist then
            currentIndex = #playlist
        end
 
        local maxScroll =
            math.max(
                0,
                #playlist * 30 - 240
            )
 
        scrollOffset =
            clamp(
                scrollOffset,
                0,
                maxScroll
            )
    end
end
 
-- ================== Bevel ==================
 
local function drawBevel(x, y, w, h, r, base, raised)
 
    r = r or 10
    local bevel = 3
 
    if raised then
        setColor(COL.shellLo)
        love.graphics.rectangle("fill", x + bevel, y + bevel, w, h, r, r)
    end
 
    setColor(base)
    love.graphics.rectangle("fill", x, y, w, h, r, r)
 
    local hi = raised and COL.shellHi or COL.shellLo
    local lo = raised and COL.shellLo or COL.shellHi
 
    love.graphics.setLineWidth(2)
    setColor(hi)
    love.graphics.line(x + r * 0.5, y + h - 2, x + r * 0.5, y + r * 0.5, x + w - r * 0.5, y + r * 0.5)
    setColor(lo)
    love.graphics.line(x + r * 0.5, y + h - 2, x + w - r * 0.5, y + h - 2, x + w - r * 0.5, y + r * 0.5)
end
 
-- ================== Screw ==================
 
local function drawScrew(x, y)
    setColor(COL.shellLo)
    love.graphics.circle("fill", x, y, 6)
    setColor(COL.shellHi)
    love.graphics.circle("fill", x - 1, y - 1, 4)
    setColor(COL.shellLo)
    love.graphics.setLineWidth(1.5)
    love.graphics.line(x - 3, y, x + 3, y)
end
 
-- ================== Icons ==================
 
local function iconPlay(x, y, s, c)
    setColor(c)
    love.graphics.polygon("fill", x - s * 0.4, y - s * 0.55, x - s * 0.4, y + s * 0.55, x + s * 0.55, y)
end
local function iconPause(x, y, s, c)
    setColor(c)
    love.graphics.rectangle("fill", x - s * 0.45, y - s * 0.5, s * 0.32, s, 2, 2)
    love.graphics.rectangle("fill", x + s * 0.13, y - s * 0.5, s * 0.32, s, 2, 2)
end
local function iconStop(x, y, s, c)
    setColor(c)
    love.graphics.rectangle("fill", x - s * 0.4, y - s * 0.4, s * 0.8, s * 0.8, 2, 2)
end
local function iconNext(x, y, s, c)
    setColor(c)
    love.graphics.polygon("fill", x - s * 0.5, y - s * 0.5, x - s * 0.5, y + s * 0.5, x + s * 0.15, y)
    love.graphics.rectangle("fill", x + s * 0.15, y - s * 0.5, s * 0.18, s)
end
local function iconPrev(x, y, s, c)
    setColor(c)
    love.graphics.polygon("fill", x + s * 0.5, y - s * 0.5, x + s * 0.5, y + s * 0.5, x - s * 0.15, y)
    love.graphics.rectangle("fill", x - s * 0.33, y - s * 0.5, s * 0.18, s)
end
 
-- ================== Audio ==================
 
local function stopCurrent()
    if source then
        source:stop()
        source:release()
        source = nil
    end
    playing = false
end
 
loadTrack = function(index, autoPlay)
 
    if #playlist == 0 then
        return
    end
 
    index = ((index - 1) % #playlist) + 1
    currentIndex = index
 
    stopCurrent()
 
    local track = playlist[currentIndex]
 
    local data, err =
        love.filesystem.newFileData(track.path)
 
    if not data then
        dropMessage = "FAILED TO LOAD AUDIO"
        dropMessageTimer = 3
        return
    end
 
    local ok, newSource =
        pcall(love.audio.newSource, data, "stream")
 
    if not ok then
        dropMessage = "AUDIO LOAD ERROR"
        dropMessageTimer = 3
        return
    end
 
    source = newSource
    source:setVolume(volume)
    marqueeOffset = 0
 
    if autoPlay then
        source:play()
        playing = true
    else
        playing = false
    end
end
 
-- ================== Drag & Drop ==================
 
function love.filedropped(file)
 
    local filename = file:getFilename()
    filename = filename:match("[^\\/]+$") or "dropped_audio.mp3"
 
    if not isAudioFile(filename) then
        dropMessage = "NOT AN AUDIO FILE"
        dropMessageTimer = 3
        return
    end
 
    local opened = file:open("r")
    if not opened then
        dropMessage = "FAILED TO OPEN FILE"
        dropMessageTimer = 3
        return
    end
 
    local size = file:getSize()
    if not size or size <= 0 then
        file:close()
        dropMessage = "EMPTY FILE"
        dropMessageTimer = 3
        return
    end
 
    local data = file:read(size)
    file:close()
 
    if not data then
        dropMessage = "FAILED TO READ FILE"
        dropMessageTimer = 3
        return
    end
 
    local musicPath = getMusicFolder()
 
    -- love.filesystem.getInfo reliably tells us whether "music" already
    -- exists inside the project folder (the old io.open test never
    -- actually detected a missing folder, since io.open just returns nil
    -- instead of raising an error -- pcall saw that as "success").
    local info = love.filesystem.getInfo("music")
    if not info or info.type ~= "directory" then
        os.execute('mkdir "' .. musicPath .. '" 2>nul')
    end
 
    local outputPath = musicPath .. "\\" .. filename
 
    local output = io.open(outputPath, "wb")
 
    if not output then
        dropMessage = "FAILED TO SAVE"
        dropMessageTimer = 3
        return
    end
 
    output:write(data)
    output:close()
 
    scanMusicFolder()
 
    for i, track in ipairs(playlist) do
        if track.name == filename then
            currentIndex = i
            loadTrack(i, false)
            dropMessage = "ADDED: " .. filename
            dropMessageTimer = 3
            return
        end
    end
 
    dropMessage = "SAVED BUT NOT FOUND"
    dropMessageTimer = 3
end
 
-- ================== Playback ==================
 
local function togglePlay()
    if #playlist == 0 then return end
    if not source then
        loadTrack(currentIndex, true)
        return
    end
    if playing then
        source:pause()
        playing = false
    else
        source:play()
        playing = true
    end
end
 
local function nextTrack()
    if #playlist == 0 then return end
    loadTrack(currentIndex + 1, true)
end
 
local function prevTrack()
    if #playlist == 0 then return end
    loadTrack(currentIndex - 1, true)
end
 
-- ================== Load ==================
 
function love.load()
 
    love.graphics.setBackgroundColor(0, 0, 0)
 
    titleFont = love.graphics.newFont(20)
    titleFont:setFilter("nearest", "nearest")
 
    barsFont = love.graphics.newFont(14)
    smallFont = love.graphics.newFont(11)
 
    for i = 1, NUM_BARS do
        bars[i] = { h = 0, target = 0 }
    end
end
 
-- ================== Update ==================
 
function love.update(dt)
 
    if not musicFolderScanned then
        musicFolderScanned = true
        local ok = pcall(scanMusicFolder)
        if not ok then
            playlist = {}
            currentIndex = 1
            dropMessage = "MUSIC FOLDER ERROR"
            dropMessageTimer = 3
        end
    end
 
    marqueeOffset = marqueeOffset + dt * 40
 
    if dropMessageTimer > 0 then
        dropMessageTimer = dropMessageTimer - dt
        if dropMessageTimer <= 0 then
            dropMessage = ""
        end
    end
 
    barTimer = barTimer + dt
    if barTimer >= 0.09 then
        barTimer = 0
        for i = 1, NUM_BARS do
            if playing then
                bars[i].target =
                    math.random() * (0.4 + 0.6 * math.sin(love.timer.getTime() * 2 + i)) * 0.9
                bars[i].target = math.abs(bars[i].target)
            else
                bars[i].target = 0
            end
        end
    end
 
    for i = 1, NUM_BARS do
        bars[i].h = lerp(bars[i].h, bars[i].target, 0.25)
    end
 
    if source and playing then
        if not source:isPlaying() then
            nextTrack()
        end
    end
end
 
-- ================== Draw Helpers ==================
 
local function formatTime(t)
    if not t or t ~= t then return "0:00" end
    t = math.floor(t)
    local minutes = math.floor(t / 60)
    local seconds = t % 60
    return string.format("%d:%02d", minutes, seconds)
end
 
local function addButton(name, x, y, w, h)
    buttons[name] = { x = x, y = y, w = w, h = h }
end
 
-- ================== Draw ==================
 
function love.draw()
 
    local grad = love.graphics.newMesh({
        { 0, 0, 0, 0, COL.bgTop[1], COL.bgTop[2], COL.bgTop[3], 1 },
        { 460, 0, 0, 0, COL.bgTop[1], COL.bgTop[2], COL.bgTop[3], 1 },
        { 460, 700, 0, 0, COL.bgBottom[1], COL.bgBottom[2], COL.bgBottom[3], 1 },
        { 0, 700, 0, 0, COL.bgBottom[1], COL.bgBottom[2], COL.bgBottom[3], 1 },
    }, "fan")
 
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(grad)
 
    drawBevel(15, 15, 430, 670, 26, COL.shell, true)
    drawScrew(35, 35)
    drawScrew(425, 35)
    drawScrew(35, 665)
    drawScrew(425, 665)
 
    love.graphics.setFont(titleFont)
    setColor(COL.btnMagenta)
    love.graphics.printf("Y2K MUSIC PLAYER 3000", 0, 30, 460, "center")
 
    love.graphics.setFont(smallFont)
    setColor({0.4, 0.15, 0.5})
    love.graphics.printf("* certified rad since 2000 *", 0, 52, 460, "center")
 
    drawBevel(screen.x, screen.y, screen.w, screen.h, 10, COL.shellLo, false)
    setColor(COL.screenBg)
    love.graphics.rectangle("fill", screen.x + 6, screen.y + 6, screen.w - 12, screen.h - 12, 6, 6)
 
    love.graphics.setScissor(screen.x + 6, screen.y + 6, screen.w - 12, screen.h - 12)
 
    love.graphics.setFont(barsFont)
 
    local trackName = "NO TRACKS FOUND -- Just drag and drop some audio files here!"
 
    if #playlist > 0 then
        local safeName = getSafeName(playlist[currentIndex].name, currentIndex)
        trackName = string.format("%02d. %s", currentIndex, safeName)
    end
 
    local widthOK, tw = pcall(barsFont.getWidth, barsFont, trackName)
 
    if not widthOK then
        trackName = "TRACK " .. tostring(currentIndex)
        tw = barsFont:getWidth(trackName)
    end
 
    local mx = screen.x + 16 - (marqueeOffset % (tw + 60))
 
    setColor(COL.screenLine)
    pcall(love.graphics.print, trackName, mx, screen.y + 16)
    pcall(love.graphics.print, trackName, mx + tw + 60, screen.y + 16)
 
    love.graphics.setFont(smallFont)
    setColor(COL.screenDim)
 
    local cur = 0
    local dur = 0
 
    if source then
        cur = source:tell("seconds") or 0
        dur = source:getDuration("seconds") or 0
        if dur ~= dur or dur == math.huge then dur = 0 end
    end
 
    love.graphics.print(formatTime(cur) .. " / " .. formatTime(dur), screen.x + 16, screen.y + 40)
 
    setColor(COL.screenLine)
    love.graphics.printf(
        playing and "> PLAYING" or (source and "|| PAUSED" or "[] STOPPED"),
        screen.x, screen.y + 40, screen.w - 16, "right"
    )
 
    local pbX = screen.x + 16
    local pbY = screen.y + 62
    local pbW = screen.w - 32
    local pbH = 10
 
    setColor(COL.screenDim)
    love.graphics.rectangle("fill", pbX, pbY, pbW, pbH, 4, 4)
 
    local pct = (dur > 0) and clamp(cur / dur, 0, 1) or 0
 
    setColor(COL.screenLine)
    love.graphics.rectangle("fill", pbX, pbY, pbW * pct, pbH, 4, 4)
 
    buttons.progress = { x = pbX, y = pbY, w = pbW, h = pbH }
 
    local ebX = screen.x + 16
    local ebY = screen.y + 84
    local ebW = screen.w - 32
    local ebH = 96
    local barW = ebW / NUM_BARS
 
    for i = 1, NUM_BARS do
        local h = 6 + bars[i].h * ebH
        setColor(COL.screenLine, 0.85)
        love.graphics.rectangle("fill", ebX + (i - 1) * barW + 2, ebY + ebH - h, barW - 4, h, 2, 2)
    end
 
    love.graphics.setScissor()
 
    local by = 270
    local specs = {
        { "prev", 60, iconPrev, COL.btnCyan },
        { "play", 150, playing and iconPause or iconPlay, COL.btnOrange },
        { "stop", 250, iconStop, COL.btnMagenta },
        { "next", 340, iconNext, COL.btnCyan },
    }
 
    for _, spec in ipairs(specs) do
        local name, bx, icon, col = spec[1], spec[2], spec[3], spec[4]
        local bw, bh = 70, 60
        local x, y = bx - bw / 2, by
 
        addButton(name, x, y, bw, bh)
 
        local raised = pressedButton ~= name
        drawBevel(x, y, bw, bh, 14, col, raised)
        icon(bx, y + bh / 2 + (raised and 0 or 2), 26, COL.textLight)
    end
 
    local vX, vY, vW, vH = 60, 355, 340, 14
 
    setColor({0.4, 0.15, 0.5})
    love.graphics.setFont(smallFont)
    love.graphics.print("VOLUME", vX, vY - 18)
 
    drawBevel(vX, vY, vW, vH, 7, COL.shellLo, false)
 
    setColor(COL.btnOrange)
    love.graphics.rectangle("fill", vX + 2, vY + 2, (vW - 4) * volume, vH - 4, 5, 5)
 
    local knobX = vX + (vW - 4) * volume + 2
 
    setColor(COL.shell)
    love.graphics.circle("fill", knobX, vY + vH / 2, 11)
 
    setColor(COL.shellLo)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", knobX, vY + vH / 2, 11)
 
    buttons.volume = { x = vX, y = vY - 10, w = vW, h = vH + 20 }
 
    local plX, plY, plW, plH = 40, 400, 380, 250
 
    drawBevel(plX, plY, plW, plH, 12, COL.shellLo, false)
 
    setColor({0.06, 0.06, 0.1})
    love.graphics.rectangle("fill", plX + 5, plY + 5, plW - 10, plH - 10, 8, 8)
 
    love.graphics.setScissor(plX + 5, plY + 5, plW - 10, plH - 10)
    love.graphics.setFont(barsFont)
 
    buttons.playlistRows = {}
 
    if #playlist == 0 then
        setColor(COL.screenLine)
        love.graphics.printf(
            "Drag and drop audio files\nhere to add them to the playlist",
            plX + 20, plY + 20, plW - 40, "left"
        )
    else
        local rowH = 30
 
        for i, track in ipairs(playlist) do
            local ry = plY + 5 + (i - 1) * rowH - scrollOffset
 
            if ry > plY - rowH and ry < plY + plH then
                if i == currentIndex then
                    setColor(COL.btnMagenta, 0.35)
                    love.graphics.rectangle("fill", plX + 5, ry, plW - 10, rowH)
                elseif i % 2 == 0 then
                    setColor({1, 1, 1}, 0.04)
                    love.graphics.rectangle("fill", plX + 5, ry, plW - 10, rowH)
                end
 
                local safeName = getSafeName(track.name, i)
 
                setColor(i == currentIndex and COL.screenLine or {0.75, 0.85, 0.8})
 
                local text = string.format("%02d  %s", i, safeName)
 
                local drawOK = pcall(love.graphics.print, text, plX + 16, ry + 7)
 
                if not drawOK then
                    love.graphics.print(string.format("%02d  TRACK %02d", i, i), plX + 16, ry + 7)
                end
            end
 
            table.insert(buttons.playlistRows, { x = plX, y = ry, w = plW, h = rowH, index = i })
        end
    end
 
    love.graphics.setScissor()
 
    if dropMessage ~= "" then
        setColor(COL.btnMagenta)
        love.graphics.rectangle("fill", 70, 215, 320, 40, 10, 10)
 
        setColor(COL.textLight)
        love.graphics.setFont(smallFont)
 
        pcall(love.graphics.printf, dropMessage, 80, 228, 300, "center")
    end
 
    setColor({1, 1, 1}, 0.85)
    love.graphics.setFont(smallFont)
    love.graphics.printf("SPACE play/pause   <-/-> track   up/down volume", 0, 660, 460, "center")
end
 
-- ================== Mouse ==================
 
function love.mousepressed(x, y, button)
 
    if button ~= 1 then return end
 
    for _, name in ipairs({ "prev", "play", "stop", "next" }) do
        local b = buttons[name]
        if b and x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h then
            pressedButton = name
            if name == "prev" then prevTrack()
            elseif name == "play" then togglePlay()
            elseif name == "stop" then stopCurrent()
            elseif name == "next" then nextTrack() end
            return
        end
    end
 
    local p = buttons.progress
    if p and source and x >= p.x and x <= p.x + p.w and y >= p.y - 6 and y <= p.y + p.h + 6 then
        local pct = clamp((x - p.x) / p.w, 0, 1)
        local dur = source:getDuration("seconds") or 0
        if dur == dur and dur < math.huge then
            source:seek(pct * dur, "seconds")
        end
        return
    end
 
    local v = buttons.volume
    if v and x >= v.x and x <= v.x + v.w and y >= v.y and y <= v.y + v.h then
        volume = clamp((x - v.x) / v.w, 0, 1)
        if source then source:setVolume(volume) end
        return
    end
 
    if buttons.playlistRows then
        for _, row in ipairs(buttons.playlistRows) do
            if x >= row.x and x <= row.x + row.w and y >= row.y and y <= row.y + row.h then
                loadTrack(row.index, true)
                return
            end
        end
    end
end
 
function love.mousereleased(x, y, button)
    pressedButton = nil
end
 
-- ================== Scroll ==================
 
function love.wheelmoved(dx, dy)
    scrollOffset = clamp(scrollOffset - dy * 20, 0, math.max(0, #playlist * 30 - 240))
end
 
-- ================== Keyboard ==================
 
function love.keypressed(key)
    if key == "space" then
        togglePlay()
    elseif key == "right" then
        nextTrack()
    elseif key == "left" then
        prevTrack()
    elseif key == "up" then
        volume = clamp(volume + 0.1, 0, 1)
        if source then source:setVolume(volume) end
    elseif key == "down" then
        volume = clamp(volume - 0.1, 0, 1)
        if source then source:setVolume(volume) end
    end
end
