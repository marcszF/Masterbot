-- local version = "4.8"
-- local currentVersion
-- local available = false

-- storage.checkVersion = storage.checkVersion or 0

-- -- check max once per 12hours
-- if os.time() > storage.checkVersion + (12 * 60 * 60) then

--     storage.checkVersion = os.time()
    
--     HTTP.get("https://raw.githubusercontent.com/Vithrax/vBot/main/vBot/version.txt", function(data, err)
--         if err then
--           warn("[vBot updater]: Unable to check version:\n" .. err)
--           return
--         end

--         currentVersion = data
--         available = true
--     end)

-- end

-- UI.Label("vBot v".. version .." \n Vithrax#5814")
-- UI.Button("Official OTCv8 Discord!", function() g_platform.openUrl("https://discord.gg/yhqBE4A") end)
-- UI.Separator()

-- schedule(5000, function()

--     if not available then return end
--     if currentVersion ~= version then
        
--         UI.Separator()
--         UI.Label("New vBot is available for download! v"..currentVersion)
--         UI.Button("Go to vBot GitHub Page", function() g_platform.openUrl("https://github.com/Vithrax/vBot") end)
--         UI.Separator()
        
--     end

-- end)

local texts = {'MarcszBot'}
for e, entry in pairs(texts) do
  local label = UI.Label(entry)
  label:setFont('verdana-11px-rounded')
  label:setColor('#9dd1ce')
end

local btDisc = UI.Button("Server Da Putaria", function() g_platform.openUrl("https://discord.gg/CkT8SSH5AY") end)
btDisc:setColor("#9dd1ce")
btDisc:setFont('verdana-11px-rounded')
UI.Separator()


Global = {}
Global.items = {
  use = { 34847, 1764, 21051, 30823, 6264, 5282, 20453, 20454, 20474, 11708, 11705,
    6257, 6256, 2772, 27260, 2773, 1632, 1633, 1948, 435, 6252, 6253, 5007, 4911,
    1629, 1630, 5108, 5107, 5281, 1968, 435, 1948, 5542, 31116, 31120, 30742, 31115,
    31118, 20474, 5737, 5736, 5734, 5733, 31202, 31228, 31199, 31200, 33262, 30824,
    5125, 5126, 5116, 5117, 8257, 8258, 8255, 8256, 5120, 30777, 30776, 23873, 23877,
    5736, 6264, 31262, 31130, 31129, 6250, 6249, 5122, 30049, 7131, 7132, 7727 },
  holes = { 606, 593, 867, 608 },
  ropeSpots = { 17238, 12202, 12935, 386, 421, 21966, 14238 },
  machete = { 2130, 3696 },
  scythe = { 3653 },
  doors = { 5007, 8265, 1629, 1632, 5129, 6252, 6249, 7715, 7712, 7714,
    7719, 6256, 1669, 1672, 5125, 5115, 5124, 17701, 17710, 1642,
    6260, 5107, 4912, 6251, 5291, 1683, 1696, 1692, 5006, 2179, 5116,
    1632, 11705, 30772, 30774, 6248, 5735, 5732, 5120, 23873, 5736,
    6264, 5122, 30049, 30042, 7727 }
}
Global.useIds = Global.items.use
Global.shovelIds = Global.items.holes
Global.ropeIds = Global.items.ropeSpots
Global.macheteIds = Global.items.machete
Global.scytheIds = Global.items.scythe
Global.doorIds = Global.items.doors

Global.PVPoffsetDirections = {
  [North] = { 0, -2 },
  [East] = { 2, 0 },
  [South] = { 0, 2 },
  [West] = { -2, 0 },
  [NorthEast] = { 1, -1 },
  [SouthEast] = { 1, 1 },
  [SouthWest] = { -1, 1 },
  [NorthWest] = { -1, -1 }
}
