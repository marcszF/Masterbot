-- =====================================================
-- MELHOR OT - MENU SIMPLES (v1.3 - Com Save System)
-- By: Fire
-- Data dessa versão: 18/01/2026
-- =====================================================

local rootWidget = modules.game_interface.getRootPanel()

-- =====================================================
-- SISTEMA DE SALVAMENTO (STORAGE)
-- =====================================================
-- Inicializa a tabela de salvamento se não existir
if not storage.MelhorOT_Save then
    storage.MelhorOT_Save = {
        cave = false, target = false, sell = false, bank = false,
        stamina = false, bless = false, task = false,
        skill = false, buff = false
    }
end

-- =====================================================
-- CORES
-- =====================================================
local COLOR_BG     = "#000000" -- Preto Puro
local COLOR_BORDER = "#111111" -- Borda quase invisível quando OFF
local COLOR_OFF    = "#AAAAAA" -- Cinza claro desligado
local COLOR_ON     = "#00FF00" -- Verde Matrix ligado

-- =====================================================
-- POSIÇÃO
-- =====================================================
local BASE_X = 480
local BASE_Y = 360
local WIDTH  = 140
local HEIGHT = 18
local GAP_Y  = 3

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
  "MelhorOT_Main", "MelhorOT_CaveBot", "MelhorOT_Target",
  "MelhorOT_Sell", "MelhorOT_Bank", "MelhorOT_Stamina",
  "MelhorOT_Bless", "MelhorOT_Skill", "MelhorOT_Buff",
  "MelhorOT_Tasks", "MelhorOT_BuffsExtra", "MelhorOT_Cooldown",
  "MelhorOT_Fly"
}) do
  local w = rootWidget:recursiveGetChildById(id)
  if w then w:destroy() end
end

-- =====================================================
-- MACROS
-- =====================================================
local SELL_ITEM_ID    = 54995
local BANK_ITEM_ID    = 54991
local STAMINA_ITEM_ID = 36725  
local BLESS_ITEM_ID   = 54531  

local sellMacro = macro(45000, function() use(SELL_ITEM_ID) end)
local bankMacro = macro(46000, function() use(BANK_ITEM_ID) end)
local staminaMacro = macro(1000, function() 
    if player:getStamina() < 2401 then 
        use(STAMINA_ITEM_ID)
    end 
end)

-- BLESS
local blessEnabled = storage.MelhorOT_Save.bless or false -- Carrega do save

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
        -- print("[AUTO BLESS] Bless já ativa.") -- Spam no console evitado
    end
end
local blessMacro = macro(47000, executeAutoBless)

-- TASK
local taskOn = storage.MelhorOT_Save.task or false -- Carrega do save
local taskCurrent = 0
local taskTotal = 0

local taskMacro = macro(1000, function()
  if not taskOn then return end
  say("!taskrenew")
end)

onTextMessage(function(mode, text)
  if not taskOn then return end
  if not text:lower():find("progresso") then return end
  local current, total = text:match("(%d+)%s*/%s*(%d+)")
  if current and total then
    taskCurrent = tonumber(current)
    taskTotal = tonumber(total)
  end
end)

-- SKILLS
local spellOn = storage.MelhorOT_Save.skill or false -- Carrega do save

local spellMacro = macro(200,"Spells", function()
    if not spellOn then return end
    if not g_game.isAttacking() then return end
    if storage.Spell1 and storage.Spell1 ~= "" then say(storage.Spell1) end
    if storage.Spell2 and storage.Spell2 ~= "" then say(storage.Spell2) end
end)
addTextEdit("Spell1", storage.Spell1 or "Digite a magia 1", function(widget, text) storage.Spell1 = text end)
addTextEdit("Spell2", storage.Spell2 or "Digite a magia 2", function(widget, text) storage.Spell2 = text end)

-- BUFF
local buffOn = storage.MelhorOT_Save.buff or false -- Carrega do save

local buffMacro = macro(200, function()
    if not buffOn then return end
    if not storage.BuffSpell or storage.BuffSpell == "" then return end
    say(storage.BuffSpell)
end)
addTextEdit("Buff Spell", storage.BuffSpell or "Digite o buff", function(widget, text) storage.BuffSpell = text end)

-- =====================================================
-- RESTAURA ESTADO (ON/OFF) DO STORAGE
-- =====================================================
if storage.MelhorOT_Save.sell then sellMacro:setOn() else sellMacro:setOff() end
if storage.MelhorOT_Save.bank then bankMacro:setOn() else bankMacro:setOff() end
if storage.MelhorOT_Save.stamina then staminaMacro:setOn() else staminaMacro:setOff() end
if storage.MelhorOT_Save.bless then blessMacro:setOn() else blessMacro:setOff() end
if storage.MelhorOT_Save.task then taskMacro:setOn() else taskMacro:setOff() end
if storage.MelhorOT_Save.skill then spellMacro:setOn() else spellMacro:setOff() end
if storage.MelhorOT_Save.buff then buffMacro:setOn() else buffMacro:setOff() end

-- Restaura Cave e Target (Opcional: remove se preferir que o VBot gerencie)
if storage.MelhorOT_Save.cave then CaveBot.setOn() else CaveBot.setOff() end
if storage.MelhorOT_Save.target then TargetBot.setOn() else TargetBot.setOff() end


-- =====================================================
-- HUD PRINCIPAL
-- =====================================================
local mainHud = g_ui.createWidget("UIButton", rootWidget)
mainHud:setId("MelhorOT_Main")
mainHud:setPosition({x=BASE_X, y=BASE_Y})
mainHud:setSize({width=WIDTH, height=HEIGHT})
mainHud:setText("SYSTEM_MENU")
mainHud:setFont("terminus-14px-bold")
mainHud:setColor(COLOR_ON)
mainHud:setBackgroundColor(COLOR_BG)
mainHud:setBorderWidth(1)
mainHud:setBorderColor(COLOR_ON)
mainHud:setDraggable(true)

bringToFront(mainHud)

-- =====================================================
-- FUNÇÃO CRIAR HUD BOTÃO
-- =====================================================
local function createButton(id, label, iconId, index, onClick)
  local hud = g_ui.createWidget("UIButton", rootWidget)
  hud:setId(id)
  hud:setPosition({x=BASE_X, y=BASE_Y + (HEIGHT + GAP_Y) * index + 5}) -- +5 ajuste do titulo
  hud:setSize({width=WIDTH, height=HEIGHT})
  hud:setText(label)
  hud:setFont("terminus-10px") -- Fonte Console
  hud:setBackgroundColor(COLOR_BG)
  hud:setBorderWidth(1)
  hud:setBorderColor(COLOR_BORDER)
  hud:setVisible(false)
  
  -- Alinhamento à esquerda para parecer lista
  hud:setTextAlign(AlignLeft)
  hud:setTextOffset({x=25, y=0}) -- Espaço para o ícone
  
  -- Cria o ícone pequeno
  local icon = g_ui.createWidget("UIItem", hud)
  icon:setItemId(iconId)
  icon:setSize({width=16, height=16})
  icon:setPosition({x=4, y=1}) -- Canto esquerdo
  icon:setVirtual(true)
  
  hud.onClick = onClick
  return hud
end

-- =====================================================
-- CRIA BOTÕES (IDs SUGERIDOS PARA ÍCONES)
-- =====================================================
-- 3577 (Pick/Cave), 3271 (Sword/Target), 3031 (Gold/Sell), 3035 (Plat/Bank)
-- 6558 (Stamina), 3004 (Ring/Bless), 1949 (Scroll/Task)
-- 3056 (Buff), 3060 (Wand/Skill), 11677 (Boots/Fly)

local caveHud = createButton("MelhorOT_CaveBot", "CaveBot", 31946, 1, function()
  if CaveBot.isOn() then CaveBot.setOff() else CaveBot.setOn() end
  storage.MelhorOT_Save.cave = CaveBot.isOn()
end)

local targetHud = createButton("MelhorOT_Target", "Target", 6068, 2, function()
  if TargetBot.isOn() then TargetBot.setOff() else TargetBot.setOn() end
  storage.MelhorOT_Save.target = TargetBot.isOn()
end)

local sellHud = createButton("MelhorOT_Sell", "Auto Sell", 54995, 3, function()
  if sellMacro:isOn() then sellMacro:setOff() else sellMacro:setOn() end
  storage.MelhorOT_Save.sell = sellMacro:isOn()
end)

local bankHud = createButton("MelhorOT_Bank", "Auto Bank", 54991, 4, function()
  if bankMacro:isOn() then bankMacro:setOff() else bankMacro:setOn() end
  storage.MelhorOT_Save.bank = bankMacro:isOn()
end)

local staminaHud = createButton("MelhorOT_Stamina", "Stamina", 36725, 5, function()
  if staminaMacro:isOn() then staminaMacro:setOff() else staminaMacro:setOn() end
  storage.MelhorOT_Save.stamina = staminaMacro:isOn()
end)

local blessHud = createButton("MelhorOT_Bless", "Auto Bless", 54531, 6, function()
  if blessMacro:isOn() then
    blessEnabled = false
    blessMacro:setOff()
  else
    blessEnabled = true
    blessMacro:setOn()
    executeAutoBless()
  end
  storage.MelhorOT_Save.bless = blessMacro:isOn()
end)

local taskHud = createButton("MelhorOT_Task", "Task", 27874, 7, function()
  taskOn = not taskOn
  taskMacro:setOn(taskOn)
  storage.MelhorOT_Save.task = taskOn
end)

local buffsHud = createButton("MelhorOT_BuffsExtra", "Buffs Extra", 25748, 8, function()
  say("!buffsextra")
end)

local cooldownHud = createButton("MelhorOT_Cooldown", "Cooldown", 2660, 9, function()
  say("!cooldown")
end)

local flyHud = createButton("MelhorOT_Fly", "Fly", 5891, 10, function()
  say("!fly")
end)

local skillHud = createButton("MelhorOT_Skill", "Spells", 14769, 11, function()
  spellOn = not spellOn
  spellMacro:setOn(spellOn)
  storage.MelhorOT_Save.skill = spellOn

end)

local buffHudSpell = createButton("MelhorOT_Buff", "Buff Spell", 23518, 12, function()
  buffOn = not buffOn
  buffMacro:setOn(buffOn)
  storage.MelhorOT_Save.buff = buffOn
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
  
  -- Garante que o Storage esteja sempre atualizado (Segurança extra)
  storage.MelhorOT_Save.cave = CaveBot.isOn()
  storage.MelhorOT_Save.target = TargetBot.isOn()
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
-- SERVER SAVE HUD E OUTROS MACROS (MANTIDOS)
-- =========================
local HUD_X = 1325
local HUD_Y = 60
local UPDATE_INTERVAL = 1000 
local SAVE_INTERVAL_MIN = 15 
local nextSaveTimestamp = nil
local statusText = "Aguardando server..."

local function now() return os.time() end
local function secondsToClock(seconds)
  if seconds < 0 then seconds = 0 end
  local m = math.floor(seconds / 60)
  local s = seconds % 60
  return string.format("%02d:%02d", m, s)
end

onTextMessage(function(mode, text)
  if text:find("Server Save Anti%-RollBack em 60 segundos") then
    nextSaveTimestamp = now() + 60
    statusText = "Server Save em:"
  end
  if text:find("Server save completo") then
    nextSaveTimestamp = now() + (SAVE_INTERVAL_MIN * 60)
    statusText = "Next Server Save:"
  end
end)

local oldHud = rootWidget:recursiveGetChildById("ServerSaveHUD")
if oldHud then oldHud:destroy() end

local ssLabel = g_ui.createWidget("UILabel", rootWidget)
ssLabel:setId("ServerSaveHUD")
ssLabel:setPosition({ x = 480, y = 60 }) -- Ajuste a posição X/Y se quiser
ssLabel:setSize({ width = 150, height = 30 })
ssLabel:setText("Server Save: Wait")
ssLabel:setColor("#00FF00") -- Verde Hacker
ssLabel:setFont("terminus-10px")
ssLabel:setTextAlign(AlignRight) -- Alinhado a direita fica chique
ssLabel:setVisible(true)

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
  ssLabel:setText(statusText .. "\n" .. secondsToClock(remaining))
end)
ssTimerMacro.onChange = function(self, enabled) ssLabel:setVisible(enabled) end
ssTimerMacro:setOn()

-- TRAIN DUMMY
local RANGE = 5
if type(storage.trainDummy) ~= "table" then storage.trainDummy = {} end
UI.Label("Varinha de Treino")
local exerciseContainer = UI.Container(function(widget, items) storage.trainDummy.exercise = items end, false) 
exerciseContainer:setHeight(35)
exerciseContainer:setItems(storage.trainDummy.exercise or {})
UI.Separator()
UI.Label("Dummy (objeto)")
local dummyContainer = UI.Container(function(widget, items) storage.trainDummy.dummy = items end, false)
dummyContainer:setHeight(35)
dummyContainer:setItems(storage.trainDummy.dummy or {})
UI.Separator()

macro(10000, "Train Dummy", function()
  if not isInPz() then return end
  if not storage.trainDummy.exercise or not storage.trainDummy.exercise[1] or not storage.trainDummy.dummy or not storage.trainDummy.dummy[1] then return end
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

UI.Separator()

-- LISTA DE ITENS DE TRAP
local trapItems = {2981, 2982, 2983, 2984, 2985, 3503, 3504, 1738, 1739, 2314, 2743}

-- TABELA PARA CONTAR TENTATIVAS
local attemptCounter = {}
local lastClean = os.time()

macro(200, "Anti-Trap", function()
    local player = g_game.getLocalPlayer()
    if not player then return end
    
    local playerPos = player:getPosition()
    local dir = player:getDirection() -- 0=N, 1=E, 2=S, 3=W

    if os.time() - lastClean > 5 then
        attemptCounter = {}
        lastClean = os.time()
    end

    local backTiles = {}
    if dir == 0 then     -- Olhando Norte (Joga para Sul y+1)
        backTiles = {{x=playerPos.x-1, y=playerPos.y+1, z=playerPos.z}, {x=playerPos.x, y=playerPos.y+1, z=playerPos.z}, {x=playerPos.x+1, y=playerPos.y+1, z=playerPos.z}}
    elseif dir == 1 then -- Olhando Leste (Joga para Oeste x-1)
        backTiles = {{x=playerPos.x-1, y=playerPos.y-1, z=playerPos.z}, {x=playerPos.x-1, y=playerPos.y, z=playerPos.z}, {x=playerPos.x-1, y=playerPos.y+1, z=playerPos.z}}
    elseif dir == 2 then -- Olhando Sul (Joga para Norte y-1)
        backTiles = {{x=playerPos.x-1, y=playerPos.y-1, z=playerPos.z}, {x=playerPos.x, y=playerPos.y-1, z=playerPos.z}, {x=playerPos.x+1, y=playerPos.y-1, z=playerPos.z}}
    elseif dir == 3 then -- Olhando Oeste (Joga para Leste x+1)
        backTiles = {{x=playerPos.x+1, y=playerPos.y-1, z=playerPos.z}, {x=playerPos.x+1, y=playerPos.y, z=playerPos.z}, {x=playerPos.x+1, y=playerPos.y+1, z=playerPos.z}}
    end

    for x = -1, 1 do
        for y = -1, 1 do
            -- Pula o próprio pé (x=0, y=0)
            if x ~= 0 or y ~= 0 then
                local tilePos = {x = playerPos.x + x, y = playerPos.y + y, z = playerPos.z}
                local tile = g_map.getTile(tilePos)
                
                if tile then
                    local items = tile:getItems()
                    if items then
                        for _, item in ipairs(items) do
                            -- Se achar item da lista
                            if table.find(trapItems, item:getId()) then
                                
                                -- Cria chave única para o piso
                                local posKey = tilePos.x .. "," .. tilePos.y
                                local attempts = attemptCounter[posKey] or 0

                                if attempts < 3 then
                                    local randomBack = backTiles[math.random(1, #backTiles)]
                                    g_game.move(item, randomBack, item:getCount())
                                    
                                    attemptCounter[posKey] = attempts + 1
                                    return -- Sai para processar
                                else
                                    g_game.move(item, {x=65535, y=3, z=0}, item:getCount())
                                    return
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

UI.Separator()

-- CONFIGURAÇÕES
local wallId = 2129         -- ID da Magic Wall da magia
local scanRadius = 6        -- Raio para detectar a parede
local ignoreList = {"NomeAmigo1", "NomeAmigo2", "HolynhoNv3"} -- Nomes para NÃO atacar

macro(200, "Auto Attack on Trap", function()
    local player = g_game.getLocalPlayer()
    if not player then return end
    
    local pos = player:getPosition()
    local isTrapped = false


    for x = -scanRadius, scanRadius do
        for y = -scanRadius, scanRadius do
            local tile = g_map.getTile({x = pos.x + x, y = pos.y + y, z = pos.z})
            
            if tile then
                local items = tile:getItems()
                if items then
                    for _, item in ipairs(items) do
                        if item:getId() == wallId then
                            isTrapped = true
                            break
                        end
                    end
                end
            end
            
            if isTrapped then break end
        end
        if isTrapped then break end
    end

    if not isTrapped then return end

    local spectators = g_map.getSpectators(pos, false)
    local targetCreature = nil
    local closestDist = 999

    for _, creature in ipairs(spectators) do
        if creature:isPlayer() and creature ~= player then
            local name = creature:getName()
            
            -- Verifica se NÃO está na lista de amigos
            local isFriend = false
            for _, friendName in ipairs(ignoreList) do
                if name == friendName then
                    isFriend = true
                    break
                end
            end

            if not isFriend then
                local cPos = creature:getPosition()
                local dist = math.max(math.abs(pos.x - cPos.x), math.abs(pos.y - cPos.y))
                
                if dist < closestDist then
                    closestDist = dist
                    targetCreature = creature
                end
            end
        end
    end

    if targetCreature then
        if g_game.getAttackingCreature() ~= targetCreature then
            g_game.attack(targetCreature)
        end
    end
end)