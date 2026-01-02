------------------------------------------------------------
-- EFFECTS MODULE
-- Particle system, screen shake, and visual effects
------------------------------------------------------------

local Colors = require("src.colors")

local Effects = {}

------------------------------------------------------------
-- STATE
------------------------------------------------------------
local particles = {}
local floating_texts = {}
local screen_shake = {x = 0, y = 0, intensity = 0}
local symbol_glows = {}  -- For glowing symbols
local reel_trails = {}   -- For spinning trail effects

------------------------------------------------------------
-- PARTICLE SPAWNING
------------------------------------------------------------
function Effects.spawn_explosion(x, y, color, count, speed)
    count = count or 30
    speed = speed or 300
    for i = 1, count do
        local angle = math.random() * math.pi * 2
        local vel = speed * (0.5 + math.random() * 0.5)
        table.insert(particles, {
            x = x,
            y = y,
            vx = math.cos(angle) * vel,
            vy = math.sin(angle) * vel,
            life = 1.0,
            decay = 0.8 + math.random() * 0.4,
            size = 4 + math.random() * 8,
            color = color,
            type = "explosion"
        })
    end
end

function Effects.spawn_sparkles(x, y, color, count)
    count = count or 15
    for i = 1, count do
        local angle = math.random() * math.pi * 2
        local dist = math.random() * 50
        table.insert(particles, {
            x = x + math.cos(angle) * dist,
            y = y + math.sin(angle) * dist,
            vx = (math.random() - 0.5) * 100,
            vy = -50 - math.random() * 100,
            life = 1.0,
            decay = 1.5 + math.random() * 0.5,
            size = 2 + math.random() * 4,
            color = color,
            type = "sparkle"
        })
    end
end

-- NEW: Star burst effect
function Effects.spawn_starburst(x, y, color, count)
    count = count or 20
    for i = 1, count do
        local angle = (i / count) * math.pi * 2
        local vel = 200 + math.random() * 150
        table.insert(particles, {
            x = x,
            y = y,
            vx = math.cos(angle) * vel,
            vy = math.sin(angle) * vel,
            life = 1.2,
            decay = 1.0,
            size = 6 + math.random() * 4,
            color = color,
            type = "star",
            rotation = math.random() * math.pi * 2,
            rot_speed = (math.random() - 0.5) * 10
        })
    end
end

-- NEW: Rising coins effect
function Effects.spawn_coins(x, y, count)
    count = count or 10
    for i = 1, count do
        table.insert(particles, {
            x = x + (math.random() - 0.5) * 100,
            y = y,
            vx = (math.random() - 0.5) * 80,
            vy = -300 - math.random() * 200,
            life = 1.5,
            decay = 0.7,
            size = 12 + math.random() * 8,
            color = Colors.gold,
            type = "coin",
            rotation = 0,
            rot_speed = 8 + math.random() * 4
        })
    end
end

-- NEW: Spawn coins at specific payline position
function Effects.spawn_coins_at_payline(reel_x, payline_y, count, spread_x)
    count = count or 8
    spread_x = spread_x or 150
    for i = 1, count do
        table.insert(particles, {
            x = reel_x + (math.random() - 0.5) * spread_x,
            y = payline_y + (math.random() - 0.5) * 30,
            vx = (math.random() - 0.5) * 120,
            vy = -350 - math.random() * 250,
            life = 1.8,
            decay = 0.6,
            size = 14 + math.random() * 10,
            color = Colors.gold,
            type = "coin",
            rotation = math.random() * math.pi * 2,
            rot_speed = 6 + math.random() * 6
        })
    end
end

-- NEW: Spawn coins across multiple reels for a payline win
function Effects.spawn_payline_coins(reel_positions, payline_y, count_per_reel)
    count_per_reel = count_per_reel or 5
    for _, rx in ipairs(reel_positions) do
        Effects.spawn_coins_at_payline(rx, payline_y, count_per_reel, 80)
    end
end

-- NEW: Spawn diagonal payline coins
function Effects.spawn_diagonal_coins(reel_positions, payline_ys, count_per_reel)
    count_per_reel = count_per_reel or 4
    for i, rx in ipairs(reel_positions) do
        local py = payline_ys[i] or payline_ys[1]
        Effects.spawn_coins_at_payline(rx, py, count_per_reel, 60)
    end
end

-- NEW: Lightning effect
function Effects.spawn_lightning(x1, y1, x2, y2, color)
    local segments = 8
    local points = {{x = x1, y = y1}}
    for i = 1, segments - 1 do
        local t = i / segments
        local px = x1 + (x2 - x1) * t + (math.random() - 0.5) * 40
        local py = y1 + (y2 - y1) * t + (math.random() - 0.5) * 40
        table.insert(points, {x = px, y = py})
    end
    table.insert(points, {x = x2, y = y2})

    table.insert(particles, {
        type = "lightning",
        points = points,
        color = color or Colors.cyan,
        life = 0.3,
        decay = 3.0,
        width = 4
    })
end

-- NEW: Ring expansion effect
function Effects.spawn_ring(x, y, color)
    table.insert(particles, {
        x = x,
        y = y,
        type = "ring",
        color = color,
        life = 1.0,
        decay = 1.5,
        radius = 10,
        max_radius = 150
    })
end

-- ENHANCED floating text with more options
function Effects.spawn_floating_text(x, y, text, color, size, style)
    style = style or "normal"
    table.insert(floating_texts, {
        x = x,
        y = y,
        text = text,
        color = color,
        size = size or 32,
        life = 2.0,
        max_life = 2.0,
        vy = -60,
        style = style,  -- "normal", "mega", "rainbow"
        scale = style == "mega" and 1.5 or 1.0,
        pulse = 0,
        glow_intensity = style == "mega" and 1.0 or 0.5
    })
end

-- NEW: Mega win text with rainbow effect
function Effects.spawn_mega_win_text(x, y, text, size)
    table.insert(floating_texts, {
        x = x,
        y = y,
        text = text,
        color = Colors.gold,
        size = size or 72,
        life = 3.0,
        max_life = 3.0,
        vy = -40,
        style = "mega",
        scale = 1.0,
        pulse = 0,
        glow_intensity = 1.5,
        rainbow = true
    })
end

------------------------------------------------------------
-- SCREEN SHAKE
------------------------------------------------------------
function Effects.trigger_screen_shake(intensity)
    screen_shake.intensity = intensity
end

function Effects.get_screen_shake()
    return screen_shake.x, screen_shake.y
end

------------------------------------------------------------
-- WIN EFFECTS
------------------------------------------------------------
function Effects.trigger_win_effects(score, win_type, cx, cy)
    -- Screen shake based on win amount
    if score > 50 then
        screen_shake.intensity = math.min(score / 30, 20)
    end

    -- Spawn effects based on win type
    if win_type:find("TRIPLE") then
        -- MEGA effects for triple!
        Effects.spawn_explosion(cx, cy, Colors.gold, 80, 600)
        Effects.spawn_explosion(cx, cy, Colors.cyan, 60, 500)
        Effects.spawn_explosion(cx, cy, Colors.highlight, 40, 400)
        Effects.spawn_starburst(cx, cy, Colors.yellow, 30)
        Effects.spawn_coins(cx, cy, 20)
        Effects.spawn_ring(cx, cy, Colors.gold)
        Effects.spawn_ring(cx, cy, Colors.cyan)

        -- Lightning effects
        for i = 1, 5 do
            local angle = math.random() * math.pi * 2
            local dist = 150 + math.random() * 100
            Effects.spawn_lightning(cx, cy, cx + math.cos(angle) * dist, cy + math.sin(angle) * dist, Colors.yellow)
        end

        -- Mega win text
        Effects.spawn_mega_win_text(cx, cy - 80, "+" .. score, 96)
        Effects.spawn_floating_text(cx, cy - 150, win_type, Colors.cyan, 48, "mega")

    elseif win_type:find("PAIR") then
        -- Good effects for pair
        Effects.spawn_explosion(cx, cy, Colors.highlight, 40, 400)
        Effects.spawn_explosion(cx, cy, Colors.gold, 30, 350)
        Effects.spawn_starburst(cx, cy, Colors.yellow, 15)
        Effects.spawn_coins(cx, cy, 8)
        Effects.spawn_ring(cx, cy, Colors.highlight)

        -- Flashy floating text
        Effects.spawn_floating_text(cx, cy - 60, "+" .. score, Colors.gold, 72, "mega")
    else
        -- Basic win effects
        Effects.spawn_explosion(cx, cy, Colors.yellow, 20, 300)
        Effects.spawn_sparkles(cx, cy, Colors.gold, 25)
        Effects.spawn_floating_text(cx, cy - 50, "+" .. score, Colors.gold, 64, "normal")
    end

    -- Always spawn extra sparkles for any win
    Effects.spawn_sparkles(cx, cy, Colors.yellow, 30)
    Effects.spawn_sparkles(cx - 100, cy, Colors.cyan, 15)
    Effects.spawn_sparkles(cx + 100, cy, Colors.highlight, 15)
end

------------------------------------------------------------
-- UPDATE
------------------------------------------------------------
function Effects.update(dt)
    -- Update particles
    for i = #particles, 1, -1 do
        local p = particles[i]

        if p.type == "lightning" then
            -- Lightning just fades
            p.life = p.life - p.decay * dt
        elseif p.type == "ring" then
            -- Ring expands
            p.radius = p.radius + (p.max_radius - p.radius) * dt * 3
            p.life = p.life - p.decay * dt
        else
            -- Normal physics
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt

            -- Different gravity for different types
            if p.type == "coin" then
                p.vy = p.vy + 600 * dt  -- heavier
                p.rotation = (p.rotation or 0) + (p.rot_speed or 0) * dt
            elseif p.type == "star" then
                p.vy = p.vy + 200 * dt  -- lighter
                p.rotation = (p.rotation or 0) + (p.rot_speed or 0) * dt
            else
                p.vy = p.vy + 400 * dt
            end

            p.life = p.life - p.decay * dt
        end

        if p.life <= 0 then
            table.remove(particles, i)
        end
    end

    -- Update floating texts
    for i = #floating_texts, 1, -1 do
        local ft = floating_texts[i]
        ft.y = ft.y + ft.vy * dt
        ft.vy = ft.vy * 0.97

        -- Pulse effect for mega style
        if ft.style == "mega" then
            ft.pulse = (ft.pulse or 0) + dt * 8
            ft.scale = 1.0 + math.sin(ft.pulse) * 0.15
        end

        ft.life = ft.life - dt

        if ft.life <= 0 then
            table.remove(floating_texts, i)
        end
    end

    -- Update screen shake
    if screen_shake.intensity > 0 then
        screen_shake.x = (math.random() - 0.5) * screen_shake.intensity * 2
        screen_shake.y = (math.random() - 0.5) * screen_shake.intensity * 2
        screen_shake.intensity = screen_shake.intensity * 0.9
        if screen_shake.intensity < 0.5 then
            screen_shake.intensity = 0
            screen_shake.x = 0
            screen_shake.y = 0
        end
    end
end

------------------------------------------------------------
-- DRAW
------------------------------------------------------------
function Effects.draw_particles()
    for _, p in ipairs(particles) do
        local alpha = math.min(p.life, 1)

        if p.type == "lightning" then
            -- Draw lightning bolt
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
            love.graphics.setLineWidth(p.width * alpha)
            for i = 1, #p.points - 1 do
                love.graphics.line(p.points[i].x, p.points[i].y, p.points[i+1].x, p.points[i+1].y)
            end
            -- Glow
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha * 0.3)
            love.graphics.setLineWidth(p.width * alpha * 3)
            for i = 1, #p.points - 1 do
                love.graphics.line(p.points[i].x, p.points[i].y, p.points[i+1].x, p.points[i+1].y)
            end

        elseif p.type == "ring" then
            -- Draw expanding ring
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha * 0.8)
            love.graphics.setLineWidth(4)
            love.graphics.circle("line", p.x, p.y, p.radius)
            -- Inner glow
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha * 0.3)
            love.graphics.setLineWidth(12)
            love.graphics.circle("line", p.x, p.y, p.radius)

        elseif p.type == "coin" then
            -- Draw coin with rotation effect (oval)
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
            local w = p.size * math.abs(math.cos(p.rotation))
            local h = p.size
            love.graphics.ellipse("fill", p.x, p.y, math.max(w, 2), h)
            -- Shine
            love.graphics.setColor(1, 1, 1, alpha * 0.5)
            love.graphics.ellipse("fill", p.x - w * 0.2, p.y - h * 0.2, w * 0.3, h * 0.3)

        elseif p.type == "star" then
            -- Draw 4-point star
            love.graphics.push()
            love.graphics.translate(p.x, p.y)
            love.graphics.rotate(p.rotation or 0)
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
            local s = p.size * alpha
            love.graphics.polygon("fill", 0, -s, s*0.3, -s*0.3, s, 0, s*0.3, s*0.3, 0, s, -s*0.3, s*0.3, -s, 0, -s*0.3, -s*0.3)
            -- Glow center
            love.graphics.setColor(1, 1, 1, alpha * 0.8)
            love.graphics.circle("fill", 0, 0, s * 0.3)
            love.graphics.pop()

        elseif p.type == "sparkle" then
            -- Draw as glowing circle
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha * 0.3)
            love.graphics.circle("fill", p.x, p.y, p.size * alpha * 2)
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
            love.graphics.circle("fill", p.x, p.y, p.size * alpha)
            love.graphics.setColor(1, 1, 1, alpha * 0.8)
            love.graphics.circle("fill", p.x, p.y, p.size * alpha * 0.4)

        else
            -- Default explosion particle
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha * 0.4)
            local size = p.size * alpha * 1.5
            love.graphics.rectangle("fill", p.x - size/2, p.y - size/2, size, size)
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
            size = p.size * alpha
            love.graphics.rectangle("fill", p.x - size/2, p.y - size/2, size, size)
        end
    end
    love.graphics.setLineWidth(1)
end

function Effects.draw_floating_texts(get_font)
    local time = love.timer.getTime()

    for _, ft in ipairs(floating_texts) do
        local alpha = math.min(ft.life / (ft.max_life or 1.5), 1)
        local scale = ft.scale or 1.0
        local glow = ft.glow_intensity or 0.5

        -- Calculate color (rainbow effect for mega)
        local color = ft.color
        if ft.rainbow then
            local hue = (time * 2 + ft.y * 0.01) % 1
            color = Effects.hsv_to_rgb(hue, 0.8, 1.0)
        end

        -- Multiple glow layers for flashy effect
        local glow_layers = ft.style == "mega" and 6 or 3
        for i = glow_layers, 1, -1 do
            local offset = i * (ft.style == "mega" and 3 or 2)
            local glow_alpha = alpha * glow * (0.15 / i)
            love.graphics.setColor(color[1], color[2], color[3], glow_alpha)
            love.graphics.setFont(get_font(math.floor(ft.size * scale), true))
            love.graphics.printf(ft.text, ft.x - 300 + offset, ft.y + offset, 600, "center")
            love.graphics.printf(ft.text, ft.x - 300 - offset, ft.y - offset, 600, "center")
            love.graphics.printf(ft.text, ft.x - 300 + offset, ft.y - offset, 600, "center")
            love.graphics.printf(ft.text, ft.x - 300 - offset, ft.y + offset, 600, "center")
        end

        -- Outer glow
        love.graphics.setColor(color[1], color[2], color[3], alpha * 0.6)
        love.graphics.setFont(get_font(math.floor(ft.size * scale), true))
        love.graphics.printf(ft.text, ft.x - 300, ft.y, 600, "center")

        -- White inner highlight for extra pop
        if ft.style == "mega" then
            love.graphics.setColor(1, 1, 1, alpha * 0.9)
        else
            love.graphics.setColor(1, 1, 1, alpha * 0.7)
        end
        love.graphics.printf(ft.text, ft.x - 300, ft.y, 600, "center")
    end
end

-- Helper: HSV to RGB conversion for rainbow effect
function Effects.hsv_to_rgb(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end

    return {r, g, b}
end

------------------------------------------------------------
-- CLEAR
------------------------------------------------------------
function Effects.clear()
    particles = {}
    floating_texts = {}
    screen_shake = {x = 0, y = 0, intensity = 0}
end

return Effects
