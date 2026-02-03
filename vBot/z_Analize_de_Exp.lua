schedule(1, function() setDefaultTab("Main") end)

local HUD_ID = "AnalyzeExpHud"
local LEGACY_HUD_ID = "AnalizeExpHud" -- kept for legacy cleanup (misspelling)
local storageKey = "analyze_exp"
local legacyStorageKey = "analize_exp" -- legacy key (misspelling)
local HUD_UPDATE_INTERVAL_MS = 1000
local BALANCE_POLL_INTERVAL_MS = 60000
local rootWidget = g_ui.getRootWidget()
if rootWidget then
  local oldHud = rootWidget:recursiveGetChildById(HUD_ID)
  if oldHud then oldHud:destroy() end
  local legacyHud = rootWidget:recursiveGetChildById(LEGACY_HUD_ID)
  if legacyHud then legacyHud:destroy() end
end
local playerName = (player and player:getName()) or (name and name()) or "default"

storage[storageKey] = storage[storageKey] or storage[legacyStorageKey] or {}
storage[storageKey][playerName] = storage[storageKey][playerName] or {
  enabled = false,
  targetLevel = lvl() + 1,
  pos = { x = 200, y = 200 }
}
storage[legacyStorageKey] = nil

local config = storage[storageKey][playerName]

local function addLabel(text)
  local label = UI.Label(text)
  label:setFont('verdana-11px-rounded')
  label:setColor('#9dd1ce')
  return label
end

local function addTextEdit(text, value, callback)
  local label = UI.Label(text)
  label:setFont('verdana-11px-rounded')
  label:setColor('#9dd1ce')
  local edit = UI.TextEdit(value or "")
  edit:setFont('verdana-11px-rounded')
  edit.onTextChange = callback
  return label, edit
end

local function addButton(text, callback)
  local button = UI.Button(text, callback)
  button:setFont('verdana-11px-rounded')
  return button
end

local function formatNumber(value)
  if value == nil then return "0" end
  local number = tonumber(value) or 0
  local sign = number < 0 and "-" or ""
  number = math.abs(number)
  local suffix = ""
  local divider = 1
  if number >= 1000000000000 then
    suffix = "kkkk"
    divider = 1000000000000
  elseif number >= 1000000000 then
    suffix = "kkk"
    divider = 1000000000
  elseif number >= 1000000 then
    suffix = "kk"
    divider = 1000000
  elseif number >= 1000 then
    suffix = "k"
    divider = 1000
  end
  if divider == 1 then
    return sign .. tostring(math.floor(number))
  end
  local formatted = string.format("%.2f", number / divider):gsub("%.?0+$", "")
  return sign .. formatted .. suffix
end

local function parseXP(value)
  if not value or value == "" then return 0 end
  local text = tostring(value):lower()
  local number, suffix = text:match("([%d%.,]+)%s*(kk|[km])")
  if not number then
    number = text:match("([%d%.,]+)")
  end
  if not number then return 0 end
  local sanitized = number:gsub(",", "")
  number = tonumber(sanitized) or 0
  local multiplier = 1
  if suffix == "kk" then
    multiplier = 1000000
  elseif suffix == "k" then
    multiplier = 1000
  elseif suffix == "m" then
    multiplier = 1000000
  end
  return math.floor(number * multiplier)
end

local function getExpForLevel(level)
  if not level or level < 1 then return 0 end
  return math.floor((50 * level * level * level) / 3 - 100 * level * level + (850 * level) / 3 - 200)
end

local function formatTime(seconds)
  if not seconds or seconds < 0 or seconds == math.huge then return "-" end
  local hours = math.floor(seconds / 3600)
  local mins = math.floor((seconds % 3600) / 60)
  local secs = math.floor(seconds % 60)
  return string.format("%02d:%02d:%02d", hours, mins, secs)
end

local function getNowMillis()
  return now or (os.time() * 1000)
end

local function getXpHour(expAmount, elapsedSeconds)
  if not expAmount or expAmount <= 0 then return 0 end
  if not elapsedSeconds or elapsedSeconds <= 0 then return 0 end
  return math.floor((expAmount / elapsedSeconds) * 3600)
end

local hudWindow
local hudLabels = {}

local function destroyHud()
  if hudWindow then
    hudWindow:destroy()
    hudWindow = nil
    hudLabels = {}
  end
end

local function createHud()
  if not rootWidget then return end
  destroyHud()

  local old = rootWidget:recursiveGetChildById(HUD_ID)
  if old then old:destroy() end

  hudWindow = setupUI([[
UIWindow
  id: AnalyzeExpHud
  size: 260 236
  draggable: true
  focusable: false
  image-source: /images/ui/panel_flat
  image-border: 4
  opacity: 0.95

  Label
    id: targetTime
    text: "Target Level Time: -"
    text-align: left
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 6
    margin-left: 6
    font: verdana-11px-rounded
    color: #ffffff

  Label
    id: sessionTime
    text: "Session Time: -"
    text-align: left
    anchors.top: targetTime.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    color: #ffffff

  Label
    id: expHour
    text: "Exp/h: -"
    text-align: left
    anchors.top: sessionTime.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    color: #ffffff

  Label
    id: rawExpHour
    text: "Raw Exp/h: -"
    text-align: left
    anchors.top: expHour.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    color: #ffffff

  Label
    id: expSession
    text: "Exp Session: -"
    text-align: left
    anchors.top: rawExpHour.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    color: #ffffff

  Label
    id: expMob
    text: "Exp Mob: -"
    text-align: left
    anchors.top: expSession.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    color: #ffffff

  Label
    id: initialLevel
    text: "Initial Level: -"
    text-align: left
    anchors.top: expMob.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    color: #ffffff

  Label
    id: levelsGained
    text: "Levels Gained: -"
    text-align: left
    anchors.top: initialLevel.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    color: #ffffff

  Label
    id: levelsHour
    text: "Levels/h: -"
    text-align: left
    anchors.top: levelsGained.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    color: #ffffff

  Label
    id: levelsDay
    text: "Levels/day: -"
    text-align: left
    anchors.top: levelsHour.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    color: #ffffff

  Label
    id: nextLevelTime
    text: "Next Level Time: -"
    text-align: left
    anchors.top: levelsDay.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    color: #ffffff

  Label
    id: balanceCurrent
    text: "Balance Current: -"
    text-align: left
    anchors.top: nextLevelTime.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    color: #ffffff

  Label
    id: balanceSession
    text: "Balance Session: -"
    text-align: left
    anchors.top: balanceCurrent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    color: #ffffff

  Label
    id: balanceHour
    text: "Balance/h: -"
    text-align: left
    anchors.top: balanceSession.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    color: #ffffff

  Label
    id: balanceDay
    text: "Balance/day: -"
    text-align: left
    anchors.top: balanceHour.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 2
    margin-left: 6
    font: verdana-11px-rounded
    color: #ffffff
]], modules.game_interface.getRootPanel())
  if not hudWindow then
    return
  end
  hudWindow:setPosition(config.pos)
  hudWindow.onGeometryChange = function(widget)
    config.pos = widget:getPosition()
  end
  hudLabels = {
    targetTime = hudWindow.targetTime,
    sessionTime = hudWindow.sessionTime,
    expHour = hudWindow.expHour,
    rawExpHour = hudWindow.rawExpHour,
    expSession = hudWindow.expSession,
    expMob = hudWindow.expMob,
    initialLevel = hudWindow.initialLevel,
    levelsGained = hudWindow.levelsGained,
    levelsHour = hudWindow.levelsHour,
    levelsDay = hudWindow.levelsDay,
    nextLevelTime = hudWindow.nextLevelTime,
    balanceCurrent = hudWindow.balanceCurrent,
    balanceSession = hudWindow.balanceSession,
    balanceHour = hudWindow.balanceHour,
    balanceDay = hudWindow.balanceDay
  }
end

local sessionStart = getNowMillis()
local expSession = 0
local expMob = 0
local initialLevel = lvl()
local balanceCurrent
local balanceInitial
local balanceReset = true

local function resetSession()
  sessionStart = getNowMillis()
  expSession = 0
  expMob = 0
  initialLevel = lvl()
  balanceInitial = nil
  balanceReset = true
end

local function updateToggleButton(button)
  if not button then return end
  local state = config.enabled and "ON" or "OFF"
  button:setText("Exp/Balance HUD: " .. state)
  button:setColor(config.enabled and "#9dd1ce" or "#d9534f")
  button:setImageColor(config.enabled and "#9dd1ce" or "#d9534f")
end

addLabel("Exp/Balance HUD")
local targetLabel, targetEdit = addTextEdit("Target Level", tostring(config.targetLevel), function(widget, text)
  local value = tonumber(text)
  if value and value > 0 then
    config.targetLevel = math.floor(value)
  end
end)
targetEdit:setTextAlign(AlignCenter)
addLabel("")

local toggleButton = addButton("Exp/Balance HUD: OFF", function()
  config.enabled = not config.enabled
  if config.enabled then
    resetSession()
    createHud()
  else
    destroyHud()
  end
  updateToggleButton(toggleButton)
end)

updateToggleButton(toggleButton)

if config.enabled then
  resetSession()
  createHud()
end

onTextMessage(function(mode, text)
  local lower = text:lower()
  if lower:find("experience") then
    local gained = parseXP(text)
    if gained > 0 then
      expMob = gained
      expSession = expSession + gained
    end
  end

  if lower:find("balance") then
    local value = parseXP(text)
    if value > 0 then
      balanceCurrent = value
      if balanceInitial == nil or balanceReset then
        balanceInitial = value
        balanceReset = false
      end
    end
  end
end)

macro(HUD_UPDATE_INTERVAL_MS, function()
  if not config.enabled or not hudWindow then
    createHud()
    if not hudWindow then return end
  end

  local elapsedSeconds = math.floor((getNowMillis() - sessionStart) / 1000)
  if elapsedSeconds < 1 then return end
  local elapsedHours = elapsedSeconds / 3600
  local expHour = getXpHour(expSession, elapsedSeconds)
  local rawExpHour = elapsedHours > 0 and (expSession / elapsedHours) or 0
  local sessionTime = formatTime(elapsedSeconds)
  local levelsGained = lvl() - initialLevel
  local levelsHour = elapsedHours > 0 and (levelsGained / elapsedHours) or 0
  local levelsDay = levelsHour * 24
  local expToNext = getExpForLevel(lvl() + 1) - exp()
  local nextLevelTime = expHour > 0 and formatTime(expToNext / expHour * 3600) or "-"
  local targetLevel = tonumber(config.targetLevel) or 0
  local expToTarget = targetLevel > 0 and getExpForLevel(targetLevel) - exp() or 0
  local targetTime = expHour > 0 and expToTarget > 0 and formatTime(expToTarget / expHour * 3600) or "-"

  local balanceSession = 0
  if balanceInitial and balanceCurrent then
    balanceSession = balanceCurrent - balanceInitial
  end
  local balanceHour = elapsedHours > 0 and (balanceSession / elapsedHours) or 0
  local balanceDay = balanceHour * 24

  hudLabels.targetTime:setText("Target Level Time: " .. targetTime)
  hudLabels.sessionTime:setText("Session Time: " .. sessionTime)
  hudLabels.expHour:setText("Exp/h: " .. formatNumber(expHour))
  hudLabels.rawExpHour:setText("Raw Exp/h: " .. formatNumber(rawExpHour))
  hudLabels.expSession:setText("Exp Session: " .. formatNumber(expSession))
  hudLabels.expMob:setText("Exp Mob: " .. formatNumber(expMob))
  hudLabels.initialLevel:setText("Initial Level: " .. initialLevel)
  hudLabels.levelsGained:setText("Levels Gained: " .. levelsGained)
  hudLabels.levelsHour:setText(string.format("Levels/h: %.2f", levelsHour))
  hudLabels.levelsDay:setText(string.format("Levels/day: %.2f", levelsDay))
  hudLabels.nextLevelTime:setText("Next Level Time: " .. nextLevelTime)
  hudLabels.balanceCurrent:setText("Balance Current: " .. formatNumber(balanceCurrent or 0))
  hudLabels.balanceSession:setText("Balance Session: " .. formatNumber(balanceSession))
  hudLabels.balanceHour:setText("Balance/h: " .. formatNumber(balanceHour))
  hudLabels.balanceDay:setText("Balance/day: " .. formatNumber(balanceDay))
end)

macro(BALANCE_POLL_INTERVAL_MS, function()
  if not config.enabled then return end
  say("!balance")
end)
