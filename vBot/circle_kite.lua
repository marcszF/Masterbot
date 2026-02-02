-- =========================================================
-- Circle Kite (OTC BOT SCRIPT) - padrão SIO do seu pack
-- UI: 1 botão por linha (Switch / Center / Config)
-- Config expandível: Walk(ms) + Radius (sem MainWindow)
-- Objetivo: rodar em círculo pra não fechar box e manter mobs atrás
-- =========================================================

local panelName = "circleKite"

local ui = setupUI([[
Panel
  id: root
  height: 46

  Panel
    id: line1
    height: 22
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right

    BotSwitch
      id: title
      anchors.left: parent.left
      anchors.right: parent.right
      height: 18
      text-align: center
      !text: tr('Circle Kite')

  Panel
    id: actions
    height: 22
    anchors.top: line1.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 2

    Button
      id: setCenter
      anchors.left: parent.left
      height: 18
      text: Center

    Button
      id: config
      anchors.left: setCenter.right
      height: 18
      text: Config

  Panel
    id: options
    height: 42
    anchors.top: actions.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    margin-top: 2
    visible: false

    Panel
      id: walkRow
      height: 20
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right

      Label
        id: walkLabel
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        margin-left: 6
        text: Walk

      Label
        id: walkValue
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        margin-right: 6
        text: 180

      HorizontalScrollBar
        id: walkScroll
        anchors.left: walkLabel.right
        anchors.right: walkValue.left
        anchors.verticalCenter: parent.verticalCenter
        margin-left: 6
        margin-right: 6
        height: 14
        minimum: 60
        maximum: 800
        value: 180

    Panel
      id: radiusRow
      height: 20
      anchors.top: walkRow.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      margin-top: 2

      Label
        id: radiusLabel
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        margin-left: 6
        text: Rad

      Label
        id: radiusValue
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        margin-right: 6
        text: 2

      HorizontalScrollBar
        id: radiusScroll
        anchors.left: radiusLabel.right
        anchors.right: radiusValue.left
        anchors.verticalCenter: parent.verticalCenter
        margin-left: 6
        margin-right: 6
        height: 14
        minimum: 1
        maximum: 6
        value: 2
]])
ui:setId(panelName)

-- pega widgets (ids estão aninhados)
local title        = ui:recursiveGetChildById("title")
local actions      = ui:recursiveGetChildById("actions")
local setCenter    = ui:recursiveGetChildById("setCenter")
local configBtn    = ui:recursiveGetChildById("config")

local options      = ui:recursiveGetChildById("options")
local walkScroll   = ui:recursiveGetChildById("walkScroll")
local walkValue    = ui:recursiveGetChildById("walkValue")
local radiusScroll = ui:recursiveGetChildById("radiusScroll")
local radiusValue  = ui:recursiveGetChildById("radiusValue")

storage[panelName] = storage[panelName] or {
  enabled = false,
  walkMs = 180,
  radius = 2,
  center = nil,
  idx = 1,
  _nextStep = 0,
  showOptions = false
}
local cfg = storage[panelName]

local function applyLayout()
  -- fechado: line1(22) + gap(2) + actions(22) = 46
  -- aberto: + gap(2) + options(42) = 90
  ui:setHeight(cfg.showOptions and 90 or 46)

  -- Center/Config 50/50
  local w = actions:getWidth()
  if w and w > 20 then
    local gap = 4
    local half = math.floor((w - gap) / 2)
    setCenter:setWidth(half)
    configBtn:setMarginLeft(gap)
    configBtn:setWidth(half)
  end
end

-- estado inicial
title:setOn(cfg.enabled)
options:setVisible(cfg.showOptions)
walkScroll:setValue(cfg.walkMs);  walkValue:setText(tostring(cfg.walkMs))
radiusScroll:setValue(cfg.radius); radiusValue:setText(tostring(cfg.radius))
applyLayout()

-- binds
title.onClick = function(widget)
  cfg.enabled = not cfg.enabled
  widget:setOn(cfg.enabled)
end

setCenter.onClick = function()
  local p = pos()
  if not p then return end
  cfg.center = {x=p.x, y=p.y, z=p.z}
  cfg.idx = 1
end

configBtn.onClick = function()
  cfg.showOptions = not cfg.showOptions
  options:setVisible(cfg.showOptions)
  applyLayout()
end

walkScroll.onValueChange = function(_, value)
  cfg.walkMs = value
  walkValue:setText(tostring(value))
end

radiusScroll.onValueChange = function(_, value)
  cfg.radius = value
  radiusValue:setText(tostring(value))
  cfg.idx = 1
end


-- =========================================================
-- LÓGICA DO CÍRCULO (ANTI-BOX)
-- =========================================================

local ring = {
  {x= 1,y= 0}, {x= 1,y= 1}, {x= 0,y= 1}, {x=-1,y= 1},
  {x=-1,y= 0}, {x=-1,y=-1},{x= 0,y=-1},{x= 1,y=-1}
}

local function nowMs()
  if now then return now end
  if g_clock and g_clock.millis then return g_clock.millis() end
  return os.time() * 1000
end

local function chebDist(a, b)
  return math.max(math.abs(a.x-b.x), math.abs(a.y-b.y))
end

local function buildTargets(center, radius)
  local t = {}
  for i=1,#ring do
    t[#t+1] = {x = center.x + ring[i].x * radius, y = center.y + ring[i].y * radius, z = center.z}
  end
  return t
end

local function tileWalkable(p)
  local tile = g_map.getTile(p)
  if not tile then return false end
  if tile.isWalkable and not tile:isWalkable() then return false end
  return true
end

-- evita pisar em tile ocupado por OUTRA criatura (não conta você)
local function tileHasOtherCreature(p)
  local tile = g_map.getTile(p)
  if not tile then return true end

  local things = tile:getThings()
  if not things then return false end

  local me = g_game.getLocalPlayer()
  for _, thing in ipairs(things) do
    if thing and thing.isCreature and thing:isCreature() then
      if not me or thing ~= me then
        return true
      end
    end
  end
  return false
end

local function isGoodStep(p)
  if not tileWalkable(p) then return false end
  if tileHasOtherCreature(p) then return false end
  return true
end

-- Macro principal
macro(20, function()
  if not cfg.enabled then return end
  if not g_game.isOnline() then return end

  local p = pos()
  if not p then return end

  -- timing real (walkMs)
  local t = nowMs()
  if t < (cfg._nextStep or 0) then return end
  cfg._nextStep = t + (cfg.walkMs or 180)

  -- centro automático se não setou
  if not cfg.center then
    cfg.center = {x=p.x, y=p.y, z=p.z}
    cfg.idx = 1
  end

  local targets = buildTargets(cfg.center, cfg.radius)

  -- tenta 8 pontos do círculo; se bloqueou, pula pro próximo
  for _=1,8 do
    local target = targets[cfg.idx]
    if target and isGoodStep(target) then
      autoWalk(target, 20, {ignoreNonPathable=true, precision=1})
      cfg.idx = (cfg.idx % #targets) + 1
      return
    end
    cfg.idx = (cfg.idx % #targets) + 1
  end

  -- fallback: dá 1 passo adjacente seguro pra não parar e fechar box
  for i=1,#ring do
    local np = {x=p.x + ring[i].x, y=p.y + ring[i].y, z=p.z}
    if isGoodStep(np) then
      autoWalk(np, 5, {ignoreNonPathable=true, precision=1})
      return
    end
  end
end)

UI.Separator()
