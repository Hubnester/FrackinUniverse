require "/scripts/util.lua"

function init()
	storage.matMod = storage.matMod or config.getParameter("matMod")
	storage.fuel = storage.fuel or config.getParameter("fuel")
	storage.fuelValue = storage.fuelValue or config.getParameter("fuelValue")
	storage.remove = false
	self.cooldownTime = config.getParameter("cooldownTime", .1)
end

function activate(fireMode, shiftHeld)
	if shiftHeld then
		if fireMode == "primary" then
			activeItem.interact("ScriptPane", "/interface/scripted/fu_matmodplacer/fu_matmodplacer.config", player.id())
			animator.playSound("selectMod")
		elseif fireMode == "alt" then
			if storage.remove then
				activeItem.setInstanceValue("matMod", storage.matMod)
				activeItem.setInstanceValue("fuel", storage.fuel)
				activeItem.setInstanceValue("fuelValue", storage.fuelValue)
				storage.remove = false
				animator.playSound("paintMode")
				
			else
				activeItem.setInstanceValue("matMod", nil)
				activeItem.setInstanceValue("fuel", nil)
				activeItem.setInstanceValue("fuelValue", nil)
				storage.remove = true
				animator.playSound("eraseMode")
			end
		end
	end
end

function update(dt, fireMode, shiftHeld)
	self.aimAngle, self.aimDirection = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
    activeItem.setArmAngle(self.aimAngle)
    activeItem.setFacingDirection(self.aimDirection)
	if self.cooldown and self.cooldown > 0 then
		self.cooldown = self.cooldown - dt
	end
	if not shiftHeld then
		if fireMode == "primary" then
			placeMod("foreground")
		elseif fireMode == "alt" then
			placeMod("background")
		end
	end
end

function placeMod(layer)
	matMod = config.getParameter("matMod")
	fuel = config.getParameter("fuel")
	fuelValue = config.getParameter("fuelValue")
	position = activeItem.ownerAimPosition()
	if matMod then
		if fuel then
			if not storage.fuelAmount or storage.fuelAmount <= 0 then
				if player.consumeItem(fuel) then
					storage.fuelAmount = fuelValue
				end
			elseif storage.fuelAmount > 0 then
				if world.placeMod(position, layer, matMod) then
					storage.fuelAmount = storage.fuelAmount - 1
				end
			end
		else
			world.placeMod(position, layer, matMod)
			if not self.cooldown or self.cooldown <= 0 then
				animator.playSound("fire")
				self.cooldown = self.cooldownTime
			end
		end
	else
		if world.mod(position, layer) then
			world.damageTiles({position}, layer, mcontroller.position(), "tilling", 0.001, 0)
			if not self.cooldown or self.cooldown <= 0 then
				animator.playSound("fire")
				self.cooldown = self.cooldownTime
			end
		end
	end
end
