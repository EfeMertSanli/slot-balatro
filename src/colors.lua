------------------------------------------------------------
-- COLORS MODULE
-- PC-98 style color palette with neon glow capability
------------------------------------------------------------

local Colors = {
    -- Backgrounds (PC-98 style)
    bg =         {0.04, 0.02, 0.12},      -- Near black with purple tint
    bg2 =        {0.08, 0.05, 0.18},      -- Dark purple
    bg3 =        {0.12, 0.08, 0.22},      -- Lighter purple
    bg_panel =   {0.06, 0.12, 0.24},      -- Dark blue for panels (PC-98)
    reel_bg =    {0.02, 0.04, 0.10},      -- Very dark blue

    -- Text colors
    symbol =     {1.00, 1.00, 1.00},
    white =      {1.00, 1.00, 1.00},
    black =      {0.00, 0.00, 0.00},
    dim =        {0.60, 0.60, 0.70},      -- PC-98 gray
    text_gold =  {1.00, 0.85, 0.30},      -- Score, currency

    -- PC-98 iconic colors
    cyan =       {0.00, 0.90, 0.95},      -- Iconic PC-98 cyan (borders)
    cyan_dim =   {0.00, 0.50, 0.55},      -- Dimmed cyan for inactive

    -- Accent colors (with neon intensity for glow)
    highlight =  {1.00, 0.30, 0.60},      -- Magenta/pink
    highlight2 = {1.00, 0.50, 0.75},      -- Soft pink
    magenta =    {1.00, 0.30, 0.60},      -- PC-98 magenta
    win =        {0.20, 0.90, 0.40},      -- Success green
    gold =       {1.00, 0.85, 0.30},      -- Gold for currency
    red =        {0.95, 0.20, 0.25},      -- Danger red
    orange =     {1.00, 0.60, 0.20},      -- Warm orange
    purple =     {0.70, 0.40, 1.00},      -- Purple accent
    yellow =     {1.00, 1.00, 0.40},      -- Wins, alerts
    blue =       {0.40, 0.70, 1.00},      -- Diamond blue

    -- UI elements
    frame =      {0.00, 0.90, 0.95},      -- Cyan border (PC-98 style)
    frame_light= {0.40, 1.00, 1.00},      -- Bright cyan
    frame_dim =  {0.00, 0.50, 0.55},      -- Dim cyan
    button =     {0.06, 0.12, 0.24},      -- Dark blue panel
    button_hover={0.10, 0.20, 0.35},      -- Lighter blue
    button_press={0.04, 0.08, 0.18},      -- Darker blue
}

return Colors
