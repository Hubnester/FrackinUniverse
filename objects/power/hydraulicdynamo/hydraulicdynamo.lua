require "/scripts/kheAA/transferUtil.lua"
require "/scripts/fupower.lua"
require "/scripts/effectUtil.lua"
function init()
    power.init()
	transferUtil.init()
	object.setInteractive(true)
	powerStates = {
		{amount = 20, state = 'fast'},
		{amount = 12, state = 'fast'},
		{amount = 4, state = 'fast'},
		{amount = 0, state = 'off'}
	}
    storage.fuels = config.getParameter("fuels")
	storage.active = true
	storage.active2 = (not object.isInputNodeConnected(0)) or object.getInputNodeLevel(0)
end

function onInputNodeChange(args)
	onNodeConnectionChange(args)
end

function onNodeConnectionChange(args)
	storage.active2 = (not object.isInputNodeConnected(0)) or object.getInputNodeLevel(0)
	power.onNodeConnectionChange(nil,0)
end

function update(dt)
	if not deltaTime or deltaTime > 1 then
		deltaTime=0
		transferUtil.loadSelfContainer()
	else
		deltaTime=deltaTime+dt
	end
	if (not storage.active) or (not storage.active2) then
		animator.setAnimationState("screen", "off")
		power.setPower(0)
		power.update(dt)
		return
	end
	if storage.active2 then
		for i=0,2 do
			if isn_slotDecayCheck(i) then isn_doSlotDecay(i) end
		end
			if isn_slotDecayCheckWater(3) then isn_doSlotDecay(3) end
	end
	local powerout = isn_getCurrentPowerOutput()
	power.setPower(powerout)
	for _,dink in pairs(powerStates) do
        if powerout >= dink.amount then
            animator.setAnimationState("screen", dink.state)
			animator.setAnimationRate(0.7 + 0.06*isn_getCurrentPowerOutput())
            break
        end
	end
	power.update(dt)
end

function isn_powerSlotCheck(slotnum)
    local item = world.containerItemAt(entity.id(), slotnum)
    if not item then return 0 end
	return storage.fuels[item.name] and storage.fuels[item.name].power or 0
end

function isn_slotDecayCheck(slot)
	local item = world.containerItemAt(entity.id(),slot)
	local myLocation = entity.position()
    if item and isn_slotDecayCheckWater(3) and storage.fuels[item.name] and math.random(1, storage.fuels[item.name].decayRate) == 1 then
        return true
    end
	return false
end

function isn_slotDecayCheckWater(slot)
	local item = world.containerItemAt(entity.id(),slot)
	local myLocation = entity.position()
    if item and item.name == "liquidwater" and math.random(1, 4) == 1 then
        return true
    end
	return false
end
function isn_doSlotDecay(slot)
	world.containerConsumeAt(entity.id(),slot,1) --consume resource
--	local waste = world.containerItemAt(entity.id(),3)
--	local wastestack
--
--	if waste then
--		-- sb.logInfo("Waste found in slot. Name is " .. waste.name)
--		if (waste.name == "deadgnomes") then
--		  -- sb.logInfo("increasing storage.radiation")
--		  wastestack = world.containerSwapItems(entity.id(),{name = "deadgnomes", count = 1, data={}},3)
--		else
--		  -- sb.logInfo("not dead gnomes, ejecting")
--		  local wastecount = waste.count -- variable to ensure no change of quantities in between calculations.
--		  world.containerConsumeAt(entity.id(),3,wastecount) --delete waste
--		  world.spawnItem(waste.name,entity.position(),wastecount) --drop it on the ground
--		end
--	else -- (waste == nil)
--		wastestack = world.containerSwapItems(entity.id(),{name = "deadgnomes", count = 1, data={}},3)
--	end
--
--	if wastestack  and (wastestack.count > 0) then
--		world.spawnItem(wastestack.name,entity.position(),wastestack.count) --drop it on the ground
--	end
end
function isn_getCurrentPowerOutput()
	local water = world.containerItemAt(entity.id(),3)
	if storage.active and water and water.name == "liquidwater" then
		local powercount = 0
		for i=0,2 do
			powercount = powercount + isn_powerSlotCheck(i)
		end
		--object.say(powercount)
		return powercount
	else
		return 0
	end
end