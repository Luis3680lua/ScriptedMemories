local Themes = {}

Themes.Default = {
    Background = Color3.fromRGB(20, 20, 25),
    Secondary = Color3.fromRGB(30, 30, 38),
    Tertiary = Color3.fromRGB(42, 42, 50),
    Hover = Color3.fromRGB(55, 55, 65),
    Text = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(180, 180, 195),
    Accent = Color3.fromRGB(70, 150, 255),
    Green = Color3.fromRGB(70, 210, 110),
    Red = Color3.fromRGB(220, 80, 80),
    Border = Color3.fromRGB(60, 60, 75),
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    TitleSize = 22, TextSize = 14, SmallSize = 12,
    Radius = 6, Width = 560, Height = 440, Alpha = 0.7, Speed = 0.3,
}

Themes.Ocean = {
    Background = Color3.fromRGB(12, 20, 28),
    Secondary = Color3.fromRGB(18, 30, 42),
    Tertiary = Color3.fromRGB(26, 42, 58),
    Hover = Color3.fromRGB(36, 58, 78),
    Text = Color3.fromRGB(230, 240, 245),
    TextDim = Color3.fromRGB(160, 185, 200),
    Accent = Color3.fromRGB(60, 190, 220),
    Green = Color3.fromRGB(70, 210, 150),
    Red = Color3.fromRGB(220, 90, 90),
    Border = Color3.fromRGB(40, 60, 80),
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    TitleSize = 22, TextSize = 14, SmallSize = 12,
    Radius = 6, Width = 560, Height = 440, Alpha = 0.7, Speed = 0.3,
}

return {
    Themes = Themes,
    Active = "Default",
}