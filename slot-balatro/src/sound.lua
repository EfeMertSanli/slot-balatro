------------------------------------------------------------
-- SOUND MODULE
-- Music playback and procedural sound effects
------------------------------------------------------------

local Sound = {}

------------------------------------------------------------
-- STATE
------------------------------------------------------------
local music_tracks = {}
local current_music = nil
local music_volume = 0.5
local sfx_volume = 0.7
local sounds = {}  -- Generated sound effects

------------------------------------------------------------
-- PROCEDURAL SOUND GENERATION
------------------------------------------------------------

-- Generate a simple sine wave tone
local function generate_tone(frequency, duration, volume, attack, decay)
    local sample_rate = 44100
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    volume = volume or 0.5
    attack = attack or 0.01
    decay = decay or 0.1

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = 1.0

        -- Attack
        if t < attack then
            envelope = t / attack
        -- Decay
        elseif t > duration - decay then
            envelope = (duration - t) / decay
        end

        local sample = math.sin(2 * math.pi * frequency * t) * volume * envelope
        sound_data:setSample(i, sample)
    end

    return love.audio.newSource(sound_data, "static")
end

-- Generate a coin/ding sound (high pitched with harmonics)
local function generate_coin_sound()
    local sample_rate = 44100
    local duration = 0.15
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = math.exp(-t * 20)  -- Quick decay

        -- Multiple harmonics for metallic sound
        local sample = 0
        sample = sample + math.sin(2 * math.pi * 1200 * t) * 0.5
        sample = sample + math.sin(2 * math.pi * 2400 * t) * 0.3
        sample = sample + math.sin(2 * math.pi * 3600 * t) * 0.2

        sound_data:setSample(i, sample * envelope * 0.4)
    end

    return love.audio.newSource(sound_data, "static")
end

-- Generate a cash register / money sound
local function generate_cash_sound()
    local sample_rate = 44100
    local duration = 0.3
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = math.exp(-t * 8)

        -- Jingly harmonics
        local sample = 0
        sample = sample + math.sin(2 * math.pi * 800 * t) * 0.3
        sample = sample + math.sin(2 * math.pi * 1000 * t) * 0.25
        sample = sample + math.sin(2 * math.pi * 1200 * t) * 0.2
        sample = sample + math.sin(2 * math.pi * 1500 * t) * 0.15
        sample = sample + math.sin(2 * math.pi * 1800 * t) * 0.1

        -- Add some noise for texture
        sample = sample + (math.random() - 0.5) * 0.05 * envelope

        sound_data:setSample(i, sample * envelope * 0.5)
    end

    return love.audio.newSource(sound_data, "static")
end

-- Generate a win fanfare sound
local function generate_win_sound()
    local sample_rate = 44100
    local duration = 0.5
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = 1.0

        if t < 0.02 then
            envelope = t / 0.02
        elseif t > 0.35 then
            envelope = (duration - t) / 0.15
        end

        -- Ascending arpeggio effect
        local freq = 400
        if t > 0.1 then freq = 500 end
        if t > 0.2 then freq = 600 end
        if t > 0.3 then freq = 800 end

        local sample = 0
        sample = sample + math.sin(2 * math.pi * freq * t) * 0.4
        sample = sample + math.sin(2 * math.pi * freq * 2 * t) * 0.2
        sample = sample + math.sin(2 * math.pi * freq * 3 * t) * 0.1

        sound_data:setSample(i, sample * envelope * 0.5)
    end

    return love.audio.newSource(sound_data, "static")
end

-- Generate a big win sound (longer, more dramatic)
local function generate_big_win_sound()
    local sample_rate = 44100
    local duration = 0.8
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = 1.0

        if t < 0.02 then
            envelope = t / 0.02
        elseif t > 0.6 then
            envelope = (duration - t) / 0.2
        end

        -- Major chord arpeggio
        local freq_base = 300 + t * 200  -- Rising pitch

        local sample = 0
        sample = sample + math.sin(2 * math.pi * freq_base * t) * 0.35
        sample = sample + math.sin(2 * math.pi * freq_base * 1.25 * t) * 0.25  -- Major third
        sample = sample + math.sin(2 * math.pi * freq_base * 1.5 * t) * 0.2   -- Fifth
        sample = sample + math.sin(2 * math.pi * freq_base * 2 * t) * 0.15    -- Octave

        sound_data:setSample(i, sample * envelope * 0.5)
    end

    return love.audio.newSource(sound_data, "static")
end

-- Generate a jackpot sound (very dramatic)
local function generate_jackpot_sound()
    local sample_rate = 44100
    local duration = 1.2
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = 1.0

        if t < 0.02 then
            envelope = t / 0.02
        elseif t > 0.9 then
            envelope = (duration - t) / 0.3
        end

        -- Sweeping frequency with harmonics
        local sweep = 200 + t * 600

        local sample = 0
        sample = sample + math.sin(2 * math.pi * sweep * t) * 0.3
        sample = sample + math.sin(2 * math.pi * sweep * 1.5 * t) * 0.2
        sample = sample + math.sin(2 * math.pi * sweep * 2 * t) * 0.15
        sample = sample + math.sin(2 * math.pi * sweep * 3 * t) * 0.1

        -- Add shimmer
        sample = sample + math.sin(2 * math.pi * 2000 * t) * 0.05 * math.sin(t * 30)

        sound_data:setSample(i, sample * envelope * 0.5)
    end

    return love.audio.newSource(sound_data, "static")
end

-- Generate a lose/fail sound
local function generate_lose_sound()
    local sample_rate = 44100
    local duration = 0.4
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = math.exp(-t * 5)

        -- Descending tone
        local freq = 400 - t * 200

        local sample = 0
        sample = sample + math.sin(2 * math.pi * freq * t) * 0.4
        sample = sample + math.sin(2 * math.pi * freq * 0.5 * t) * 0.2  -- Sub bass

        sound_data:setSample(i, sample * envelope * 0.4)
    end

    return love.audio.newSource(sound_data, "static")
end

-- Generate spin start sound (whoosh)
local function generate_spin_start_sound()
    local sample_rate = 44100
    local duration = 0.3
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = 1.0

        if t < 0.05 then
            envelope = t / 0.05
        else
            envelope = math.exp(-(t - 0.05) * 8)
        end

        -- Noise-based whoosh with rising filter
        local noise = (math.random() - 0.5) * 2
        local filter = math.sin(t * 50) * 0.5 + 0.5

        local sample = noise * filter * envelope * 0.3

        sound_data:setSample(i, sample)
    end

    return love.audio.newSource(sound_data, "static")
end

-- Generate reel stop sound (thunk)
local function generate_reel_stop_sound()
    local sample_rate = 44100
    local duration = 0.1
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = math.exp(-t * 40)

        -- Low thump with click
        local sample = 0
        sample = sample + math.sin(2 * math.pi * 100 * t) * 0.5 * envelope
        sample = sample + math.sin(2 * math.pi * 200 * t) * 0.3 * envelope

        -- Click transient
        if t < 0.005 then
            sample = sample + (math.random() - 0.5) * 0.5
        end

        sound_data:setSample(i, sample * 0.5)
    end

    return love.audio.newSource(sound_data, "static")
end

-- Generate chip appear sound
local function generate_chip_sound()
    local sample_rate = 44100
    local duration = 0.12
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = math.exp(-t * 25)

        -- Bright pop
        local sample = 0
        sample = sample + math.sin(2 * math.pi * 600 * t) * 0.4
        sample = sample + math.sin(2 * math.pi * 900 * t) * 0.3
        sample = sample + math.sin(2 * math.pi * 1200 * t) * 0.2

        sound_data:setSample(i, sample * envelope * 0.4)
    end

    return love.audio.newSource(sound_data, "static")
end

-- Generate button click sound
local function generate_click_sound()
    local sample_rate = 44100
    local duration = 0.05
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = math.exp(-t * 80)

        local sample = math.sin(2 * math.pi * 800 * t) * envelope * 0.3

        sound_data:setSample(i, sample)
    end

    return love.audio.newSource(sound_data, "static")
end

-- Generate payline hit sound (satisfying ding that escalates)
local function generate_line_hit_sound(pitch_mult)
    pitch_mult = pitch_mult or 1.0
    local sample_rate = 44100
    local duration = 0.2
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    local base_freq = 880 * pitch_mult  -- A5, can escalate

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = math.exp(-t * 12)

        -- Bright bell-like tone
        local sample = 0
        sample = sample + math.sin(2 * math.pi * base_freq * t) * 0.4
        sample = sample + math.sin(2 * math.pi * base_freq * 2 * t) * 0.25
        sample = sample + math.sin(2 * math.pi * base_freq * 3 * t) * 0.15
        sample = sample + math.sin(2 * math.pi * base_freq * 4 * t) * 0.1

        -- Add shimmer
        sample = sample + math.sin(2 * math.pi * base_freq * 5.5 * t) * 0.05 * math.exp(-t * 20)

        sound_data:setSample(i, sample * envelope * 0.4)
    end

    return love.audio.newSource(sound_data, "static")
end

-- Generate multiplier sound (whooshy power-up feel)
local function generate_mult_sound()
    local sample_rate = 44100
    local duration = 0.25
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = 1.0

        if t < 0.02 then
            envelope = t / 0.02
        elseif t > 0.15 then
            envelope = (duration - t) / 0.1
        end

        -- Rising sweep with harmonics
        local freq = 300 + t * 1200  -- Sweep up

        local sample = 0
        sample = sample + math.sin(2 * math.pi * freq * t) * 0.35
        sample = sample + math.sin(2 * math.pi * freq * 1.5 * t) * 0.2
        sample = sample + math.sin(2 * math.pi * freq * 2 * t) * 0.15

        -- Add some grit
        sample = sample + math.sin(2 * math.pi * freq * 0.5 * t) * 0.1

        sound_data:setSample(i, sample * envelope * 0.45)
    end

    return love.audio.newSource(sound_data, "static")
end

-- Generate score tick sound (quick counting sound)
local function generate_tick_sound()
    local sample_rate = 44100
    local duration = 0.04
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = math.exp(-t * 100)

        local sample = math.sin(2 * math.pi * 1400 * t) * 0.3 * envelope
        sample = sample + math.sin(2 * math.pi * 2100 * t) * 0.2 * envelope

        sound_data:setSample(i, sample)
    end

    return love.audio.newSource(sound_data, "static")
end

-- Generate score add sound (satisfying chunk when points add)
local function generate_score_add_sound()
    local sample_rate = 44100
    local duration = 0.15
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = math.exp(-t * 18)

        -- Chunky satisfying sound
        local sample = 0
        sample = sample + math.sin(2 * math.pi * 500 * t) * 0.3
        sample = sample + math.sin(2 * math.pi * 750 * t) * 0.25
        sample = sample + math.sin(2 * math.pi * 1000 * t) * 0.2
        sample = sample + math.sin(2 * math.pi * 1500 * t) * 0.15

        -- Punch transient
        if t < 0.01 then
            sample = sample + (math.random() - 0.5) * 0.3
        end

        sound_data:setSample(i, sample * envelope * 0.5)
    end

    return love.audio.newSource(sound_data, "static")
end

-- Generate total reveal sound (big dramatic finale)
local function generate_total_sound()
    local sample_rate = 44100
    local duration = 0.6
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = 1.0

        if t < 0.02 then
            envelope = t / 0.02
        elseif t > 0.4 then
            envelope = (duration - t) / 0.2
        end

        -- Big chord with shimmer
        local sample = 0
        -- C major chord rising
        sample = sample + math.sin(2 * math.pi * 523 * t) * 0.25  -- C5
        sample = sample + math.sin(2 * math.pi * 659 * t) * 0.2   -- E5
        sample = sample + math.sin(2 * math.pi * 784 * t) * 0.2   -- G5
        sample = sample + math.sin(2 * math.pi * 1046 * t) * 0.15 -- C6

        -- Add sparkle
        sample = sample + math.sin(2 * math.pi * 2093 * t) * 0.08 * math.sin(t * 25)
        sample = sample + math.sin(2 * math.pi * 2637 * t) * 0.05 * math.sin(t * 30)

        -- Sub bass for weight
        sample = sample + math.sin(2 * math.pi * 130 * t) * 0.1

        sound_data:setSample(i, sample * envelope * 0.5)
    end

    return love.audio.newSource(sound_data, "static")
end

-- Generate combo sound (escalating excitement)
local function generate_combo_sound()
    local sample_rate = 44100
    local duration = 0.3
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = 1.0

        if t < 0.01 then
            envelope = t / 0.01
        elseif t > 0.2 then
            envelope = (duration - t) / 0.1
        end

        -- Exciting arpeggio sweep
        local freq = 400 + math.sin(t * 40) * 200 + t * 600

        local sample = 0
        sample = sample + math.sin(2 * math.pi * freq * t) * 0.35
        sample = sample + math.sin(2 * math.pi * freq * 1.5 * t) * 0.25
        sample = sample + math.sin(2 * math.pi * freq * 2 * t) * 0.15

        sound_data:setSample(i, sample * envelope * 0.45)
    end

    return love.audio.newSource(sound_data, "static")
end

-- Generate shop purchase sound
local function generate_purchase_sound()
    local sample_rate = 44100
    local duration = 0.25
    local samples = math.floor(sample_rate * duration)
    local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sample_rate
        local envelope = 1.0

        if t < 0.01 then
            envelope = t / 0.01
        elseif t > 0.15 then
            envelope = (duration - t) / 0.1
        end

        -- Ka-ching!
        local sample = 0
        sample = sample + math.sin(2 * math.pi * 1000 * t) * 0.3
        sample = sample + math.sin(2 * math.pi * 1500 * t) * 0.25
        sample = sample + math.sin(2 * math.pi * 2000 * t) * 0.2

        -- Second hit
        if t > 0.08 then
            local t2 = t - 0.08
            local env2 = math.exp(-t2 * 15)
            sample = sample + math.sin(2 * math.pi * 1200 * t2) * 0.3 * env2
            sample = sample + math.sin(2 * math.pi * 1800 * t2) * 0.2 * env2
        end

        sound_data:setSample(i, sample * envelope * 0.4)
    end

    return love.audio.newSource(sound_data, "static")
end

------------------------------------------------------------
-- INITIALIZATION
------------------------------------------------------------
function Sound.load()
    -- Load music tracks
    local music_files = {
        "src/sound/music_1.mp3",
        "src/sound/music_2.mp3",
    }

    for i, file in ipairs(music_files) do
        local success, source = pcall(function()
            return love.audio.newSource(file, "stream")
        end)
        if success and source then
            source:setLooping(true)
            source:setVolume(music_volume)
            table.insert(music_tracks, source)
        end
    end

    -- Generate procedural sound effects
    sounds.coin = generate_coin_sound()
    sounds.cash = generate_cash_sound()
    sounds.win = generate_win_sound()
    sounds.big_win = generate_big_win_sound()
    sounds.jackpot = generate_jackpot_sound()
    sounds.lose = generate_lose_sound()
    sounds.spin_start = generate_spin_start_sound()
    sounds.reel_stop = generate_reel_stop_sound()
    sounds.chip = generate_chip_sound()
    sounds.click = generate_click_sound()
    sounds.purchase = generate_purchase_sound()

    -- Scoring sounds (escalating pitches for multiple paylines)
    sounds.line_hit_1 = generate_line_hit_sound(1.0)
    sounds.line_hit_2 = generate_line_hit_sound(1.12)  -- Up a whole step
    sounds.line_hit_3 = generate_line_hit_sound(1.25)  -- Up a major third
    sounds.line_hit_4 = generate_line_hit_sound(1.33)  -- Up a fourth
    sounds.line_hit_5 = generate_line_hit_sound(1.5)   -- Up a fifth
    sounds.multiplier = generate_mult_sound()
    sounds.tick = generate_tick_sound()
    sounds.score_add = generate_score_add_sound()
    sounds.total_reveal = generate_total_sound()
    sounds.combo = generate_combo_sound()

    -- Set volumes
    for name, sound in pairs(sounds) do
        sound:setVolume(sfx_volume)
    end
end

------------------------------------------------------------
-- MUSIC CONTROL
------------------------------------------------------------
function Sound.play_music(track_index)
    track_index = track_index or 1

    -- Stop current music
    if current_music then
        current_music:stop()
    end

    -- Play new track
    if music_tracks[track_index] then
        current_music = music_tracks[track_index]
        current_music:setVolume(music_volume)
        current_music:play()
    end
end

function Sound.stop_music()
    if current_music then
        current_music:stop()
        current_music = nil
    end
end

function Sound.pause_music()
    if current_music then
        current_music:pause()
    end
end

function Sound.resume_music()
    if current_music then
        current_music:play()
    end
end

function Sound.set_music_volume(vol)
    music_volume = math.max(0, math.min(1, vol))
    if current_music then
        current_music:setVolume(music_volume)
    end
end

function Sound.next_track()
    local current_index = 1
    for i, track in ipairs(music_tracks) do
        if track == current_music then
            current_index = i
            break
        end
    end

    local next_index = (current_index % #music_tracks) + 1
    Sound.play_music(next_index)
end

------------------------------------------------------------
-- SOUND EFFECTS
------------------------------------------------------------
function Sound.play(name, volume_mult)
    if sounds[name] then
        -- Clone the sound for overlapping playback
        local sound = sounds[name]:clone()
        sound:setVolume(sfx_volume * (volume_mult or 1.0))
        sound:play()
    end
end

-- Convenience functions
function Sound.coin()
    Sound.play("coin")
end

function Sound.cash()
    Sound.play("cash")
end

function Sound.win()
    Sound.play("win")
end

function Sound.big_win()
    Sound.play("big_win")
end

function Sound.jackpot()
    Sound.play("jackpot")
end

function Sound.lose()
    Sound.play("lose")
end

function Sound.spin_start()
    Sound.play("spin_start")
end

function Sound.reel_stop()
    Sound.play("reel_stop", 0.7)
end

function Sound.chip()
    Sound.play("chip")
end

function Sound.click()
    Sound.play("click", 0.5)
end

function Sound.purchase()
    Sound.play("purchase")
end

-- Scoring sounds with escalation
function Sound.line_hit(index)
    -- Escalate pitch based on which payline (1-5, wraps)
    index = ((index - 1) % 5) + 1
    Sound.play("line_hit_" .. index)
end

function Sound.multiplier()
    Sound.play("multiplier")
end

function Sound.tick()
    Sound.play("tick", 0.6)
end

function Sound.score_add()
    Sound.play("score_add")
end

function Sound.total_reveal()
    Sound.play("total_reveal")
end

function Sound.combo()
    Sound.play("combo")
end

------------------------------------------------------------
-- VOLUME CONTROL
------------------------------------------------------------
function Sound.set_sfx_volume(vol)
    sfx_volume = math.max(0, math.min(1, vol))
end

function Sound.get_sfx_volume()
    return sfx_volume
end

function Sound.get_music_volume()
    return music_volume
end

return Sound
