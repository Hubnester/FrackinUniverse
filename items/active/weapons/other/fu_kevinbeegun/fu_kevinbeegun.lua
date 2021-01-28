require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/effectUtil.lua"

function init()
	self.fireOffset = config.getParameter("fireOffset")
	updateAim()

	self.level = config.getParameter("level", 1)
	self.abilityData = config.getParameter("primaryAbility")
	storage.fireTimer = self.abilityData.fireTime

	activeItem.setCursor("/cursors/reticle0.cursor")

	setToolTipValues(self.abilityData)
end

function setToolTipValues(ability)
	local projectileCount=1

	activeItem.setInstanceValue("tooltipFields", {
		damagePerShotLabel = damagePerShot(ability,1),
		speedLabel = 1 / ability.fireTime,
		energyPerShotLabel = ability.energyUsage
	})
end

function update(dt, fireMode, shiftHeld)
	updateAim()
	storage.fireTimer = math.max(storage.fireTimer - dt, 0)

	if fireMode == "none" or not fireMode then return end

	if storage.fireTimer <= 0 and not world.pointTileCollision(firePosition()) and status.overConsumeResource("energy", self.abilityData.energyUsage) then
		storage.fireTimer = self.abilityData.fireTime
		world.spawnMonster("futinybee", firePosition(), {level = self.level, aggressive = true, dropPools = {default = "empty"}, damageTeamType = "enemy", damageTeam = 88})
		animator.burstParticleEmitter("fireParticles")
		animator.playSound("fire")
	end
end

function updateAim()
	self.aimAngle, self.aimDirection = activeItem.aimAngleAndDirection(self.fireOffset[2], activeItem.ownerAimPosition())
	activeItem.setArmAngle(self.aimAngle)
	activeItem.setFacingDirection(self.aimDirection)
end

function firePosition()
	return vec2.add(mcontroller.position(), activeItem.handPosition(self.fireOffset))
end

function aimVector(ability)
	local aimVector = vec2.rotate({1, 0}, self.aimAngle + sb.nrand(ability.inaccuracy or 0, 0))
	aimVector[1] = aimVector[1] * self.aimDirection

	return aimVector
end

function damagePerShot(ability, projectileCount)
	return ability.baseDps
	* ability.fireTime
	* (self.baseDamageMultiplier or 1.0)
	* config.getParameter("damageLevelMultiplier", root.evalFunction("weaponDamageLevelMultiplier", self.level))
	/ projectileCount
end

function uninit()
	
end