# Slot Balatro - Assets Reference

---

## Mascot Character - "Luna" the Dealer

A PC-98 style anime girl casino dealer who serves as the game's mascot and guide. She reacts dynamically to the player's wins and losses, creating an emotional connection to the gameplay.

### Character Design Specification

**Base Appearance:**
- Young woman (early 20s aesthetic), elegant casino dealer
- Hair: Long, flowing dark purple/violet hair with subtle blue highlights, styled with gentle waves
- Eyes: Large, expressive amber/gold eyes with visible highlights (PC-98 style bright eye reflections)
- Outfit: Fitted black dealer's vest over crisp white dress shirt, gold trim accents, small gold "7" pin on lapel
- Accessories: Delicate gold earrings (lucky dice or card suit shapes), thin black choker with small gem
- Makeup: Subtle blush, defined eyelashes, soft pink lips
- Pose: Upper body portrait (bust-up), hands occasionally visible holding cards or chips

**Art Style Requirements:**
- PC-98/FM Towns aesthetic: Limited but vibrant color palette, dithering for gradients
- Pixel art with smooth anti-aliasing on edges
- 256x256 or 512x512 resolution
- Dark gradient background (deep purple to black) with subtle neon glow accents
- Scanline-friendly contrast levels
- Anime proportions with expressive features

---

### Expression Sprites

| State | Trigger | Expression | Detailed Image Prompt |
|-------|---------|------------|----------------------|
| **idle** | Default/waiting | Calm, professional | `PC-98 style pixel art anime girl, casino dealer, dark purple flowing hair with blue highlights, large amber eyes with bright reflections, black vest white shirt gold trim, calm professional smile, slight head tilt, one hand near chin thoughtfully, dark purple gradient background, 256x256, retro Japanese computer game aesthetic, limited color palette with dithering, neon cyan and gold accent lighting` |
| **watching** | Reels spinning | Curious, anticipating | `PC-98 style pixel art anime girl casino dealer, dark purple hair flowing, amber eyes wide with curiosity, watching intently, slight lean forward, eyebrows raised in anticipation, excited but contained expression, sparkle effects near eyes, dark background with spinning motion blur hints, 256x256, retro anime aesthetic, vibrant limited palette` |
| **neutral** | No win (0 credits) | Sympathetic, encouraging | `PC-98 style pixel art anime girl casino dealer, dark purple hair, amber eyes soft and sympathetic, gentle encouraging smile, slight head tilt, one hand in supportive gesture, warm expression saying "try again", dark moody background, 256x256, PC-98 aesthetic, muted but warm color tones` |
| **small_win** | Win < 20 credits | Pleasant, light smile | `PC-98 style pixel art anime girl casino dealer, dark purple hair with subtle movement, amber eyes happy with curved smile, cheerful closed-mouth smile, small sparkles near face, one hand giving subtle thumbs up or clap, light gold glow accents, 256x256, retro anime style, warm color palette` |
| **good_win** | Win 20-50 credits | Happy, genuine joy | `PC-98 style pixel art anime girl casino dealer, dark purple hair bouncing slightly, amber eyes bright and joyful with visible highlights, open mouth smile showing happiness, light blush on cheeks, hands clasped together in delight, gold and cyan sparkle effects around her, bright celebratory lighting, 256x256, PC-98 vibrant style` |
| **big_win** | Win 50-100 credits | Excited, impressed | `PC-98 style pixel art anime girl casino dealer, dark purple hair with dynamic flow, amber eyes wide with excitement and stars/sparkles in them, big open smile, visible blush, hands raised in excited celebration, one eye slightly closed in joy, coins and sparkles floating around, golden glow background, 256x256, high energy PC-98 anime aesthetic` |
| **jackpot** | Win > 100 credits / Triple 7s | Ecstatic, overwhelmed | `PC-98 style pixel art anime girl casino dealer, dark purple hair flowing dramatically upward with energy, amber eyes enormous with multiple highlight sparkles and tears of joy, huge open mouth smile laughing with joy, deep blush across face, both hands raised in victory pose, surrounded by explosion of gold coins confetti and rainbow sparkles, intense golden magenta background glow, screen shake energy, 256x256, maximum celebration PC-98 style, chromatic aberration effect` |
| **mega_jackpot** | Legendary win (500+) | Absolutely stunned | `PC-98 style pixel art anime girl casino dealer, dark purple hair turned partially gold from sheer luck energy, amber eyes replaced with spinning lucky 7s or stars, jaw dropped in disbelief, face completely red with blush, hands on cheeks in shock pose, entire background is explosion of coins diamonds and neon lights, rainbow aura emanating from her, legendary jackpot energy, 256x256, over-the-top PC-98 celebration, every pixel glowing` |
| **losing_streak** | 3+ losses in a row | Worried, concerned | `PC-98 style pixel art anime girl casino dealer, dark purple hair slightly drooping, amber eyes with worried slant and small sweat drop, nervous smile trying to encourage, hands fidgeting with chips, slight lean toward player sympathetically, darker muted background, 256x256, PC-98 style with cooler worried tones` |
| **broke** | Credits near 0 | Deeply concerned | `PC-98 style pixel art anime girl casino dealer, dark purple hair hanging low, amber eyes large and watery with concern, hands clasped pleadingly, worried frown, offering emotional support, very dark somber background with faint hope glimmer, 256x256, emotional PC-98 anime style` |
| **comeback** | Win after losing streak | Relieved, triumphant | `PC-98 style pixel art anime girl casino dealer, dark purple hair with renewed energy flow, amber eyes bright with relieved tears and wide smile, laughing with relief, one fist pumped in victory, the other wiping happy tear, warm golden comeback glow, rising sun effect behind her, 256x256, emotional triumph PC-98 aesthetic` |
| **shop** | In shop screen | Helpful, merchant-like | `PC-98 style pixel art anime girl casino dealer, dark purple hair neatly arranged, amber eyes warm and inviting, professional saleswoman smile, one hand gesturing to display items, other hand holding golden tray with joker cards, shop keeper aesthetic, warm inviting purple and gold background, 256x256, helpful merchant PC-98 style` |
| **round_end** | Round complete | Proud, accomplished | `PC-98 style pixel art anime girl casino dealer, dark purple hair with satisfied wave, amber eyes content and proud, closed-eye smile with slight bow, hands folded professionally, elegant accomplished pose, soft gold and purple gradient background, 256x256, dignified PC-98 anime style` |

---

### Speech Bubble Lines (for text display)

| State | Sample Lines |
|-------|--------------|
| idle | "Ready when you are~" / "Feeling lucky?" / "Take your time..." |
| watching | "Here we go..." / "Come on..." / "..." |
| neutral | "Better luck next spin!" / "Don't give up!" / "The reels are fickle..." |
| small_win | "Nice one!" / "There you go!" / "Good start~" |
| good_win | "Well played!" / "Looking good!" / "Keep it up!" |
| big_win | "Amazing!!" / "Incredible spin!" / "You're on fire!" |
| jackpot | "JACKPOT!!!" / "UNBELIEVABLE!!" / "MASSIVE WIN!!!" |
| mega_jackpot | "LEGENDARY!!!" / "I CAN'T BELIEVE IT!!!" / "HISTORY MADE!!!" |
| losing_streak | "Hang in there..." / "Luck will turn..." / "I believe in you..." |
| broke | "Maybe take a break?" / "It's just a game..." / "You'll bounce back..." |
| shop | "See anything you like?" / "Great choices today~" / "Invest wisely!" |

---

## Symbols (Reel Icons)

| ID | Name | Icon | Value | Image Prompt |
|----|------|------|-------|--------------|
| cherry | CHERRY | CHRRY | 3 | `Pixel art cherry icon, bright red glossy cherries with green stem, retro slot machine style, 64x64, transparent background, neon red glow effect, PC-98 limited palette` |
| lemon | LEMON | LEMN | 4 | `Pixel art lemon icon, bright yellow citrus fruit with highlight shine, retro slot machine style, 64x64, transparent background, neon yellow glow effect` |
| bell | BELL | BELL | 5 | `Pixel art golden liberty bell icon, shiny metallic with gleam, retro slot machine style, 64x64, transparent background, golden neon glow` |
| star | STAR | STAR | 7 | `Pixel art 5-pointed star icon, cyan/teal sparkling star, retro slot machine style, 64x64, transparent background, cyan neon glow, twinkle effect` |
| clover | CLOVER | CLOVR | 10 | `Pixel art four-leaf clover icon, bright lucky green with golden shimmer, retro slot machine style, 64x64, transparent background, green neon glow` |
| diamond | DIAMOND | DIAM | 15 | `Pixel art brilliant cut diamond icon, blue sparkling gem with facets, retro slot machine style, 64x64, transparent background, blue neon glow, prismatic effect` |
| seven | SEVEN | 7777 | 25 | `Pixel art lucky number 7 icon, golden metallic with red outline, sparkles and stars around it, retro slot machine style, 64x64, transparent background, gold and red neon glow, jackpot feeling` |
| skull | WILD | SKULL | 0 (wild) | `Pixel art mystical skull icon, purple glowing wild symbol, magical energy wisps, retro slot machine style, 64x64, transparent background, purple neon glow, mysterious aura` |

---

## Jokers (Charms)

### Common Jokers

| ID | Name | Icon | Cost | Effect | Image Prompt |
|----|------|------|------|--------|--------------|
| greedy | Golden Touch | G$G | 40 | All wins +25% | `Pixel art golden hand with Midas touch, dripping gold coins, magical aura, tarot card style, 128x128, dark background with gold glow, PC-98 aesthetic` |
| lucky_clover | Lucky Clover | ^.^ | 35 | +15 bonus on any win | `Pixel art four-leaf clover, bright green with golden sparkles, lucky charm, tarot card style, 128x128, dark background with green glow` |
| cherry_bomb | Cherry Bomb | *!* | 45 | +20 per cherry shown | `Pixel art cherry with lit fuse like a bomb, explosive red cherries, tarot card style, 128x128, dark background with red explosion glow` |
| lemon_squeeze | Lemon Squeeze | L%L | 45 | Lemons pay x2 | `Pixel art lemon being squeezed with gold coins coming out, juicy effect, tarot card style, 128x128, dark background with yellow glow` |

### Uncommon Jokers

| ID | Name | Icon | Cost | Effect | Image Prompt |
|----|------|------|------|--------|--------------|
| lucky_seven | Lucky Seven | 777 | 75 | Sevens pay triple | `Pixel art triple 7s with rainbow jackpot effect, casino lights, tarot card style, 128x128, dark background with rainbow glow` |
| clover_collector | Clover Hunter | ^.^ | 60 | Clovers give +40 bonus | `Pixel art leprechaun hand reaching for glowing clovers, lucky hunter, tarot card style, 128x128, dark background with green gold glow` |
| diamond_cutter | Diamond Cutter | <> | 70 | Diamonds pay x2.5 | `Pixel art jeweler cutting a brilliant diamond, precision tools, gems scattered, tarot card style, 128x128, dark background with blue sparkle` |
| star_power | Star Power | *+* | 65 | Stars grant extra spin | `Pixel art shooting star with cosmic trail, space magic, grants wishes, tarot card style, 128x128, dark background with cyan cosmic glow` |
| bell_ringer | Bell Ringer | BEL | 55 | Bells add +30 always | `Pixel art bell ringer character pulling rope, golden bells chiming, tarot card style, 128x128, dark background with golden sound waves` |

### Rare Jokers

| ID | Name | Icon | Cost | Effect | Image Prompt |
|----|------|------|------|--------|--------------|
| necromancer | Skull Lord | S+S | 90 | Each wild doubles score | `Pixel art necromancer with floating skulls, purple dark magic, skeleton king, tarot card style, 128x128, dark background with purple death aura` |
| high_roller | High Roller | MAX | 100 | Max bet: wins x2 | `Pixel art high roller gambler with stacks of chips, VIP casino whale, sunglasses, tarot card style, 128x128, dark background with gold luxury glow` |
| combo_king | Combo King | CMB | 85 | +50% per consecutive win | `Pixel art king with combo counter crown, chain lightning between symbols, tarot card style, 128x128, dark background with electric blue chains` |
| insurance | Safety Net | NET | 80 | Refund bet on no match | `Pixel art safety net catching falling coins, circus net below trapeze, protective aura, tarot card style, 128x128, dark background with blue safe glow` |

### Legendary Jokers

| ID | Name | Icon | Cost | Effect | Image Prompt |
|----|------|------|------|--------|--------------|
| jackpot | Jackpot Joker | J!P | 150 | Pure triple = x5 | `Pixel art classic joker card with JACKPOT text, confetti explosion, ultimate prize, tarot card style, 128x128, dark background with golden rainbow jackpot glow` |
| chaos_dealer | Chaos Dealer | ??? | 120 | Random x1 to x4 multiplier | `Pixel art mysterious dealer with chaos cards, question marks floating, unpredictable magic, tarot card style, 128x128, dark background with swirling chaos colors` |
| midas | Midas Touch | AU! | 200 | All symbols +5 value | `Pixel art King Midas with everything turning gold, golden throne, ultimate wealth, tarot card style, 128x128, dark background with brilliant gold aura` |
| time_warp | Time Warp | <-> | 130 | +2 spins per round | `Pixel art clock bending through portal, time manipulation, hourglass sand flowing backward, tarot card style, 128x128, dark background with cyan time vortex` |

---

## Slot Changers (Machine Upgrades)

### Payline Upgrades - Horizontal

| ID | Name | Icon | Cost | Effect | Image Prompt |
|----|------|------|------|--------|--------------|
| payline_top | Top Line | --- | 150 | Adds top row payline | `Pixel art horizontal cyan neon line, slot machine payline indicator, 64x64, transparent background` |
| payline_bottom | Bottom Line | ___ | 150 | Adds bottom row payline | `Pixel art horizontal gold neon line, slot machine payline indicator, 64x64, transparent background` |
| payline_all_horizontal | All Rows | === | 250 | Adds top AND bottom paylines | `Pixel art three horizontal neon lines stacked, green glow, 64x64, transparent background` |

### Payline Upgrades - Diagonal

| ID | Name | Icon | Cost | Effect | Image Prompt |
|----|------|------|------|--------|--------------|
| payline_diag_down | Diagonal \ | \\\ | 300 | Top-left to bottom-right | `Pixel art diagonal orange neon line going down-right, 64x64, transparent background` |
| payline_diag_up | Diagonal / | /// | 300 | Bottom-left to top-right | `Pixel art diagonal purple neon line going up-right, 64x64, transparent background` |
| payline_both_diag | X Pattern | X | 500 | Adds BOTH diagonals | `Pixel art X cross pattern yellow neon glow, 64x64, transparent background` |

### Reel & Row Upgrades

| ID | Name | Icon | Cost | Effect | Image Prompt |
|----|------|------|------|--------|--------------|
| fourth_reel | Fourth Reel | +[4] | 500 | Adds 4th reel column | `Pixel art mechanical reel with number 4, magenta glow, gears, 64x64, transparent background` |
| fifth_reel | Fifth Reel | +[5] | 800 | Adds 5th reel column | `Pixel art mechanical reel with number 5, red glow, gears, 64x64, transparent background` |
| fourth_row | Fourth Row | +R4 | 350 | Adds 4th symbol row | `Pixel art upward expansion arrow, cyan glow, 64x64, transparent background` |
| fifth_row | Fifth Row | +R5 | 500 | Adds 5th symbol row | `Pixel art downward expansion arrow, orange glow, 64x64, transparent background` |
| payline_far_top | Far Top Line | ^^^ | 200 | Far top payline (4+ rows) | `Pixel art double horizontal blue neon line, 64x64, transparent background` |
| payline_far_bottom | Far Bottom Line | vvv | 200 | Far bottom payline (5 rows) | `Pixel art double horizontal red neon line, 64x64, transparent background` |

### Special Upgrades

| ID | Name | Icon | Cost | Effect | Image Prompt |
|----|------|------|------|--------|--------------|
| wild_magnet | Wild Magnet | W+W | 400 | Doubles wild frequency | `Pixel art magnet attracting skull wilds, purple magnetic field, 64x64, transparent background` |
| max_lines | Full Board | #=# | 750 | All remaining paylines | `Pixel art slot grid with all lines lit, cyan matrix pattern, 64x64, transparent background` |

---

## Visual Effects (Optional Assets)

Pre-made effect sprites that can enhance the game:

| Effect | Size | Description | Image Prompt |
|--------|------|-------------|--------------|
| coin_burst | 128x128 spritesheet | Coins exploding outward | `Pixel art spritesheet of gold coins bursting outward, 8 frames, explosion pattern, transparent background, golden glow` |
| sparkle_loop | 64x64 spritesheet | Twinkling sparkle effect | `Pixel art spritesheet of twinkling star sparkle, 6 frames loop, white and gold, transparent background` |
| glow_pulse | 64x64 spritesheet | Pulsing glow ring | `Pixel art spritesheet of neon glow ring pulsing, 4 frames, cyan color, transparent background` |
| win_flash | 256x256 | Full screen flash overlay | `Pixel art radial light burst, golden center fading to transparent, screen flash effect, 256x256` |
| confetti | 128x128 spritesheet | Falling confetti pieces | `Pixel art spritesheet of colorful confetti falling, 8 frames, rainbow colors, transparent background` |
| jackpot_text | 256x64 | "JACKPOT!" animated text | `Pixel art animated JACKPOT text, golden letters with rainbow outline, sparkling, 4 frame animation, PC-98 style` |
| lucky_aura | 96x96 spritesheet | Character luck glow | `Pixel art spritesheet of magical aura glow around character, 6 frames, purple and gold swirl, transparent` |
| reel_blur | 220x110 | Motion blur for spinning | `Pixel art vertical motion blur effect, slot reel spin blur, gray streaks, transparent background` |

---

## UI Elements

### Screen Layout
- **Resolution**: 1920x1080
- **Title Bar**: Top strip with round counter, game title "SLOT BALATRO", CRT intensity controls
- **Portrait Area**: Left panel (380x580) - Mascot display, speech bubble, paytable toggle
- **Reel Area**: Center panel (900x580) - Main slot machine with CRT bezel effect
- **Stats Panel**: Right panel (600x580) - Credits, bet, last win, joker cards
- **Info Bar**: Full width (1900x80) - Win messages and sub-messages
- **Action Bar**: Full width (1900x310) - Round progress, spin button, controls

### Button Styles

| Button | Colors | Effect |
|--------|--------|--------|
| Primary (SPIN) | Magenta border, dark fill | Outer glow, hover brightens |
| Normal | Cyan border, dark fill | Double-line box, hover highlights |
| Small | Cyan dim border | Compact style for controls |
| Fast Forward (Active) | Yellow border, magenta fill | Toggle indicator |

### Color Palette

| Name | Hex | Usage |
|------|-----|-------|
| Background | #0a0a12 | Main dark background |
| Panel BG | #12121a | Panel backgrounds |
| Cyan | #00ffff | Primary accent, borders |
| Magenta | #ff00aa | Highlight, primary buttons |
| Gold | #ffcc00 | Credits, wins, jackpots |
| Purple | #aa00ff | Wilds, special effects |
| Red | #ff3366 | Warnings, cherry |
| Green | #00ff66 | Success, clover |
| Blue | #3399ff | Diamond, info |

### CRT Effects
- Subtle scanlines (adjustable 0-100% intensity)
- Minimal RGB chromatic aberration
- Light vignette corners
- Curved corner shadow overlay
- Glass reflection highlight
- Very subtle flicker

---

## File Structure

```
src/assests/
├── symbols/
│   ├── symbol_cherry.png
│   ├── symbol_lemon.png
│   ├── symbol_bell.png
│   ├── symbol_star.png
│   ├── symbol_clover.png
│   ├── symbol_diamond.png
│   ├── symbol_seven.png
│   └── symbol_skull.png
├── mascot/
│   ├── luna_idle.png
│   ├── luna_watching.png
│   ├── luna_neutral.png
│   ├── luna_small_win.png
│   ├── luna_good_win.png
│   ├── luna_big_win.png
│   ├── luna_jackpot.png
│   ├── luna_mega_jackpot.png
│   ├── luna_losing_streak.png
│   ├── luna_broke.png
│   ├── luna_comeback.png
│   ├── luna_shop.png
│   └── luna_round_end.png
├── jokers/
│   └── [joker_id].png
├── effects/
│   ├── coin_burst.png
│   ├── sparkle_loop.png
│   ├── confetti.png
│   └── win_flash.png
└── ui/
    ├── button_primary.png
    ├── button_normal.png
    └── panel_border.png
```

---

## Style Guidelines

- **Aesthetic**: PC-98 / FM Towns Japanese computer game style (late 80s-90s)
- **Color Palette**: Limited but vibrant, heavy use of dithering for gradients
- **Resolution**: Crisp pixel art, nearest-neighbor scaling only
- **Glow Effects**: Neon bloom achieved through layered semi-transparent sprites
- **Animation**: Limited frames (4-8), smooth looping
- **Format**: PNG with transparency, indexed color when possible
