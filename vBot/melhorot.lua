setDefaultTab("Main")

local DUMMY_IDS = {54005}
local EXERCISE_ID = 55634
local RANGE = 8 -- distância máxima (1 = colado)

local treino = macro(4000, "Train Dummy Auto", function()
  if not player then return end
  if player:isWalking() then return end
  if g_game.isAttacking() then return end

  local exercise = findItem(EXERCISE_ID)
  if not exercise then return end

  local myPos = pos()

  for _, tile in pairs(g_map.getTiles(posz())) do
    local p = tile:getPosition()
    if getDistanceBetween(myPos, p) <= RANGE then
      for _, thing in pairs(tile:getThings()) do
        local id = thing:getId()
        for _, dummyId in ipairs(DUMMY_IDS) do
          if id == dummyId then
            useWith(exercise, thing)
            return
          end
        end
      end
    end
  end
end)
addIcon("Treino", {
  item = 54005,
  text = "Treino",
}, treino)
UI.Separator()

local DEPOSIT_BANK_ID = 54991
local depositIcon = macro(46000, "Deposit Bank", function()
  use(DEPOSIT_BANK_ID)
end)
addIcon("DepositIcon", {
  item = DEPOSIT_BANK_ID,
  text = "DEPOSIT",
}, depositIcon)

UI.Separator()

local SELL_ITEM_ID = 54995
local sellIcon = macro(45500, "Sell Itens", function()
  use(SELL_ITEM_ID)
end)
addIcon("SellIcon", {
  item = SELL_ITEM_ID,
  text = "SELL",
}, sellIcon)

UI.Separator()

local STAMINA_ITEM_ID = 36725
local staminaMacro = macro(200, "Stamina", function()
  if player:getStamina() < 2401 then
    use(STAMINA_ITEM_ID)
  end
end)
addIcon("StaminaIcon", {item = STAMINA_ITEM_ID, text = "Stamina"}, staminaMacro)

UI.Separator()

buffz = macro(1000, "USAR BUFF", function()
if not hasPartyBuff() then
local buff = storage.buff
  say(buff)
 end
end)
addTextEdit(" BUFF", storage.buff or "Digite o buff", function(widget, text)
    storage.buff = text
end)
addIcon("buffz", {
  item = 55228,
  text = "BUFF",
}, buffz)

UI.Separator()

local renew = macro(45500, "Renewtask", function()
say("!taskrenew")
end)

UI.Separator()

local spellMacro = macro(200, "USAR MAGIAS", function()
    if not g_game.isAttacking() then return end

    if storage.Spell1 and storage.Spell1 ~= "" then
        say(storage.Spell1)
    end

    if storage.Spell2 and storage.Spell2 ~= "" then
        say(storage.Spell2)
    end
    
    if storage.Spell3 and storage.Spell3 ~= "" then
        say(storage.Spell3)
    end
end)
addTextEdit("Spell1", storage.Spell1 or "Digite a magia 1", function(widget, text)
    storage.Spell1 = text
end)

addTextEdit("Spell2", storage.Spell2 or "Digite a magia 2", function(widget, text)
    storage.Spell2 = text
end)

addTextEdit("Spell3", storage.Spell3 or "Digite a magia 3", function(widget, text)
    storage.Spell3 = text
end)
addIcon("SpellIcon", {item = 51459, text = "Magia"}, spellMacro)

UI.Separator()

addIcon("CaveTarget", {
  item = 55229, 
  text = "Cave\nTarget",
  switchable = true,
  moveable = true
}, function(icon, isOn)
  if isOn then
    CaveBot.setOn()
    TargetBot.setOn()
  else
    CaveBot.setOff()
    TargetBot.setOff()
  end
end)