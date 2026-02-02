-- =====================================================
-- MELHOR OT - MENU SIMPLES (v1.2)
-- By: Fire
-- Data dessa versão: 18/01/2026
-- PIX pra contribuir: 5d2158c4-f0cb-4719-bada-620c906b8b71
-- =====================================================

local rootWidget = modules.game_interface.getRootPanel()

-- =====================================================
-- CORES
-- =====================================================
local COLOR_BG     = "#000000"
local COLOR_BORDER = "#111111"
local COLOR_OFF    = "#AAAAAA"
local COLOR_ON     = "#00FF00"

-- =====================================================
-- POSIÇÃO
-- =====================================================
local BASE_X = 480
local BASE_Y = 360
local WIDTH  = 150
local HEIGHT = 20
local GAP_Y  = 6

-- =====================================================
-- UTIL
-- =====================================================
local function bringToFront(w)
  if not w then return end
  w:raise()
  w:focus()
end

local function setState(hud, label, isOn)
  hud:setText(label .. ": " .. (isOn and "ON" or "OFF"))
  hud:setColor(isOn and COLOR_ON or COLOR_TEXT)
end

-- =====================================================
-- LIMPA HUDS ANTIGOS
-- =====================================================
for _, id in ipairs({
  "MelhorOT_Main",
  "MelhorOT_CaveBot",
  "MelhorOT_Target",
  "MelhorOT_Sell",
  "MelhorOT_Bank",
  "MelhorOT_Stamina",
  "MelhorOT_Bless",
  "MelhorOT_Skill",
  "MelhorOT_Buff",
  "MelhorOT_Tasks",
  "MelhorOT_BuffsExtra",
  "MelhorOT_Cooldown",
  "MelhorOT_Fly"
}) do
  local w = rootWidget:recursiveGetChildById(id)
  if w then w:destroy() end
end

-- =====================================================
-- MACROS (45 SEGUNDOS)
-- =====================================================
local SELL_ITEM_ID    = 54995
local BANK_ITEM_ID    = 54991
local STAMINA_ITEM_ID = 36725  --  ajuste com o ID 
local BLESS_ITEM_ID   = 54981  --  ajuste com o ID

local sellMacro = macro(45000, function() use(SELL_ITEM_ID) end)
local bankMacro = macro(45000, function() use(BANK_ITEM_ID) end)
local staminaMacro = macro(200, function() if not staminaOn then return end if player:getStamina() < 2401 then use(STAMINA_ITEM_ID)end end)
-- BLESS
local blessEnabled = false

local function executeAutoBless()
    if not blessEnabled then return end

    if player:getBlessings() == 0 then
        print("[AUTO BLESS] Nenhuma bless detectada, usando item...")

        use(BLESS_ITEM_ID)

        schedule(2000, function()
            if not blessEnabled then return end

            if player:getBlessings() == 0 then
                print("[AUTO BLESS] ERRO: Bless não foi aplicada!")
            else
                print("[AUTO BLESS] Bless aplicada com sucesso.")
            end
        end)
    else
        print("[AUTO BLESS] Bless já ativa.")
    end
end

-- Executa a cada 45 segundos
local blessMacro = macro(45000, executeAutoBless)
blessMacro:setOff()
------------------------------------------------------------------------------------------------------------
-- =====================================================
-- TASK
-- =====================================================
local taskOn = false
local taskCurrent = 0
local taskTotal = 0

local taskMacro = macro(1000, function()
  if not taskOn then return end
  say("!taskrenew")
end)
-- taskOn = taskMacro:isOn()
onTextMessage(function(mode, text)
  if not taskOn then return end
  if not text:lower():find("progresso") then return end

  local current, total = text:match("(%d+)%s*/%s*(%d+)")
  if current and total then
    taskCurrent = tonumber(current)
    taskTotal = tonumber(total)
  end
end)
-- =====================================================
-- CONFIGURAÇÃO DE SKILLS
-- =====================================================


local spellOn = false

local spellMacro = macro(200,"Spells", function()
    if not spellOn then return end
    if not g_game.isAttacking() then return end

    if storage.Spell1 and storage.Spell1 ~= "" then
        say(storage.Spell1)
    end

    if storage.Spell2 and storage.Spell2 ~= "" then
        say(storage.Spell2)
    end
    
end)
addTextEdit("Spell1", storage.Spell1 or "Digite a magia 1", function(widget, text)
    storage.Spell1 = text
end)

addTextEdit("Spell2", storage.Spell2 or "Digite a magia 2", function(widget, text)
    storage.Spell2 = text
end)


local buffOn = false

local buffMacro = macro(200, function()
    if not buffOn then return end
    if not storage.BuffSpell or storage.BuffSpell == "" then return end

    say(storage.BuffSpell)
end)
addTextEdit("Buff Spell", storage.BuffSpell or "Digite o buff", function(widget, text)
    storage.BuffSpell = text
end)

sellMacro:setOff()
bankMacro:setOff()
staminaMacro:setOff()
blessMacro:setOff()
taskMacro:setOff()
spellMacro:setOff()
buffMacro:setOff()

-- =====================================================
-- HUD PRINCIPAL
-- =====================================================
local mainHud = g_ui.createWidget("UIButton", rootWidget)
mainHud:setId("MelhorOT_Main")
mainHud:setPosition({x=BASE_X, y=BASE_Y})
mainHud:setSize({width=WIDTH, height=HEIGHT})
mainHud:setText("MELHOR OT")
mainHud:setFont("verdana-11px-rounded")
mainHud:setColor("#F3F500")
mainHud:setBackgroundColor(COLOR_BG)
mainHud:setBorderWidth(1)
mainHud:setBorderColor(COLOR_BORDER)
mainHud:setDraggable(true)

bringToFront(mainHud)

-- =====================================================
-- FUNÇÃO CRIAR HUD BOTÃO
-- =====================================================
local function createButton(id, label, index, onClick)
  local hud = g_ui.createWidget("UIButton", rootWidget)
  hud:setId(id)
  hud:setPosition({x=BASE_X, y=BASE_Y + (HEIGHT + GAP_Y) * index})
  hud:setSize({width=WIDTH, height=HEIGHT})
  hud:setFont("verdana-11px-rounded")
  hud:setBackgroundColor(COLOR_BG)
  hud:setBorderWidth(1)
  hud:setBorderColor(COLOR_BORDER)
  hud:setVisible(false)
  hud.onClick = onClick
  return hud
end

-- =====================================================
-- CRIA BOTÕES
-- =====================================================
local caveHud = createButton("MelhorOT_CaveBot", "CaveBot", 1, function()
  if CaveBot.isOn() then CaveBot.setOff() else CaveBot.setOn() end
end)

local targetHud = createButton("MelhorOT_Target", "Target", 2, function()
  if TargetBot.isOn() then TargetBot.setOff() else TargetBot.setOn() end
end)

local sellHud = createButton("MelhorOT_Sell", "Sell", 3, function()
  if sellMacro:isOn() then sellMacro:setOff() else sellMacro:setOn() end
end)

local bankHud = createButton("MelhorOT_Bank", "Bank", 4, function()
  if bankMacro:isOn() then
    bankMacro:setOff()
  else
    bankMacro:setOn()
  end
end)

local staminaHud = createButton("MelhorOT_Stamina", "Stamina", 5, function()
  if staminaMacro:isOn() then staminaMacro:setOff() else staminaMacro:setOn() end
end)

local blessHud = createButton("MelhorOT_Bless", "Bless", 6, function()
  if blessMacro:isOn() then
    blessEnabled = false
    blessMacro:setOff()
    print("[AUTO BLESS] Desativado.")
  else
    blessEnabled = true
    blessMacro:setOn()
    executeAutoBless() -- executa imediatamente
    print("[AUTO BLESS] Ativado.")
  end
end)

local skillHud = createButton("MelhorOT_Skill", "Skill", 11, function()
  spellOn = not spellOn
  spellMacro:setOn(spellOn)
end)

local buffHudSpell = createButton("MelhorOT_Buff", "Buff", 12, function()
  buffOn = not buffOn
  buffMacro:setOn(buffOn)
end)

local taskHud = createButton("MelhorOT_Task", "Task", 7, function()
  taskOn = not taskOn
  taskMacro:setOn(taskOn)
end)

local buffsHud = createButton("MelhorOT_BuffsExtra", "Buffs Extra", 8, function()
  say("!buffsextra")
end)

local cooldownHud = createButton("MelhorOT_Cooldown", "Cooldown", 9, function()
  say("!cooldown")
end)

local flyHud = createButton("MelhorOT_Fly", "Fly", 10, function()
  say("!fly")
end)




-- =====================================================
-- SINCRONIZA TEXTO E COR
-- =====================================================
macro(300, function()
  setState(caveHud,    "CaveBot",  CaveBot.isOn())
  setState(targetHud,  "Target",   TargetBot.isOn())
  setState(sellHud,    "Sell",     sellMacro:isOn())
  setState(bankHud,    "Bank",     bankMacro:isOn())
  setState(staminaHud, "Stamina",  staminaMacro:isOn())
  setState(blessHud,   "Bless",    blessMacro:isOn())
  if taskOn then
  taskHud:setText("Task: " .. taskCurrent .. "/" .. taskTotal)
  taskHud:setColor(COLOR_ON)
else
  taskHud:setText("Task: OFF")
  taskHud:setColor(COLOR_TEXT)
end
  setState(skillHud, "Skill", spellOn)
  setState(buffHudSpell, "Buff", buffOn)
    buffsHud:setText("Buffs Extra")
    buffsHud:setColor(COLOR_TEXT)

    cooldownHud:setText("Cooldown")
    cooldownHud:setColor(COLOR_TEXT)

    flyHud:setText("Fly")
    flyHud:setColor(COLOR_TEXT)

end)

-- =====================================================
-- TOGGLE MENU
-- =====================================================
local menuOpen = false

mainHud.onClick = function()
  menuOpen = not menuOpen

  caveHud:setVisible(menuOpen)
  targetHud:setVisible(menuOpen)
  sellHud:setVisible(menuOpen)
  bankHud:setVisible(menuOpen)
  staminaHud:setVisible(menuOpen)
  blessHud:setVisible(menuOpen)
  skillHud:setVisible(menuOpen)
  buffHudSpell:setVisible(menuOpen)
  taskHud:setVisible(menuOpen)
  buffsHud:setVisible(menuOpen)
  cooldownHud:setVisible(menuOpen)
  flyHud:setVisible(menuOpen)

  bringToFront(caveHud)
  bringToFront(targetHud)
  bringToFront(sellHud)
  bringToFront(bankHud)
  bringToFront(staminaHud)
  bringToFront(blessHud)
  bringToFront(skillHud)
  bringToFront(taskHud)
  bringToFront(buffsHud)
  bringToFront(cooldownHud)
  bringToFront(flyHud)

end

-- =========================
-- CONFIGURAÇÃO
-- =========================
local HUD_X = 1325
local HUD_Y = 60
local UPDATE_INTERVAL = 1000 -- 1 segundo

local SAVE_INTERVAL_MIN = 15 -- próximo save após completar

-- =========================
-- VARIÁVEIS
-- =========================
local nextSaveTimestamp = nil
local statusText = "Aguardando server..."

-- =========================
-- FUNÇÕES DE TEMPO
-- =========================
local function now()
  return os.time()
end

local function secondsToClock(seconds)
  if seconds < 0 then seconds = 0 end
  local m = math.floor(seconds / 60)
  local s = seconds % 60
  return string.format("%02d:%02d", m, s)
end

-- =========================
-- CAPTURA SERVER LOG
-- =========================
onTextMessage(function(mode, text)
  -- Aviso de 60 segundos
  if text:find("Server Save Anti%-RollBack em 60 segundos") then
    nextSaveTimestamp = now() + 60
    statusText = "Server Save em:"
  end

  -- Server save completo
  if text:find("Server save completo") then
    nextSaveTimestamp = now() + (SAVE_INTERVAL_MIN * 60)
    statusText = "Next Server Save:"
  end
end)

-- =========================
-- CRIA HUD
-- =========================
local oldHud = rootWidget:recursiveGetChildById("ServerSaveHUD")
if oldHud then
  oldHud:destroy()
end

local ssLabel = g_ui.createWidget("UILabel", rootWidget)
ssLabel:setId("ServerSaveHUD")
ssLabel:setPosition({ x = HUD_X, y = HUD_Y })
ssLabel:setSize({ width = 180, height = 30 })
ssLabel:setText("Server Save\nAguardando...")
ssLabel:setColor("#FFFFFF")
ssLabel:setBorderWidth(1)
ssLabel:setBorderColor("#00FFFF")
ssLabel:setBackgroundColor("#0B1E2D")
ssLabel:setFont("verdana-11px-rounded")
ssLabel:setTextWrap(true)
ssLabel:setVisible(true)
ssLabel:setFocusable(false)

-- =========================
-- MACRO TIMER
-- =========================
local ssTimerMacro = macro(UPDATE_INTERVAL, function()
  if not nextSaveTimestamp then
    ssLabel:setText("Server Save\nAguardando...")
    return
  end

  local remaining = nextSaveTimestamp - now()

  if remaining <= 0 then
    ssLabel:setText("Server Save\nSalvando...")
    return
  end

  ssLabel:setText(
    statusText .. "\n" ..
    secondsToClock(remaining)
  )
end)

ssTimerMacro.onChange = function(self, enabled)
  ssLabel:setVisible(enabled)
end

ssTimerMacro:setOn()
-- =====================================================
-- TRAIN DUMMY - UI.CONTAINER
-- =====================================================

local RANGE = 5

-- =========================
-- STORAGE
-- =========================
if type(storage.trainDummy) ~= "table" then
  storage.trainDummy = {}
end

-- =========================
-- UI
-- =========================
UI.Label("Varinha de Treino")

local exerciseContainer = UI.Container(function(widget, items)
  storage.trainDummy.exercise = items
end, false) -- false = apenas 1 item

exerciseContainer:setHeight(35)
exerciseContainer:setItems(storage.trainDummy.exercise or {})

UI.Separator()

UI.Label("Dummy (objeto)")

local dummyContainer = UI.Container(function(widget, items)
  storage.trainDummy.dummy = items
end, false) -- false = apenas 1 item

dummyContainer:setHeight(35)
dummyContainer:setItems(storage.trainDummy.dummy or {})

UI.Separator()

-- =========================
-- MACRO
-- =========================
macro(10000, "Train Dummy", function()
  if not isInPz() then return end

  if not storage.trainDummy.exercise
     or not storage.trainDummy.exercise[1]
     or not storage.trainDummy.dummy
     or not storage.trainDummy.dummy[1] then
    return
  end

  local exerciseId = storage.trainDummy.exercise[1].id
  local dummyId    = storage.trainDummy.dummy[1].id

  local exerciseItem = findItem(exerciseId)
  if not exerciseItem then return end

  local myPos = pos()

  for _, tile in pairs(g_map.getTiles(posz())) do
    local p = tile:getPosition()
    if getDistanceBetween(myPos, p) <= RANGE then
      for _, thing in pairs(tile:getThings()) do
        if thing:getId() == dummyId then
          useWith(exerciseItem, thing)
          return
        end
      end
    end
  end
end)

macro(5000, "Auto Reconnect", function()
    if g_game.isOnline() then return end
    local root = g_ui.getRootWidget()
    if root then
        local msgBox = root:recursiveGetChildById('msgBox')
        if msgBox then msgBox:destroy() end
    end
    if EnterGame and EnterGame.doLogin then EnterGame.doLogin()
    else if EnterGame then EnterGame.show() end end
end)


