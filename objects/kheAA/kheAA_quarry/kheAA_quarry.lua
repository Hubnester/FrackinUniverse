require "/scripts/kheAA/excavatorCommon.lua"

function init()
	kheAA_quarryWide = config.getParameter("kheAA_quarryWide")
	drillReset(true)
	excavatorCommon.init()
end

function anims()
	animHorizontal({storage.width,1})
	if storage.drillPos==nil then
		drillReset()
	end
	renderDrill(storage.drillPos)
end

function renderDrill(pos)
	local pos1 = pos[1]*object.direction()	-- Since the transformation group stuff takes direction into account, need to remove the direction from the position
	if object.direction() == -1 then
		pos1 = pos1 + ((kheAA_quarryWide and 2) or 1) - 0.5	-- Make it render everything in the right place (since the stuff for rendering assumes it starts 1 or 2 blocks away from the objects position)
	end
	animator.resetTransformationGroup("vertical")
	animator.scaleTransformationGroup("vertical", {1,math.min(0,pos[2] + 2)})
	animator.translateTransformationGroup("vertical", {pos1,1}); 
	animator.resetTransformationGroup("drill")
	animator.translateTransformationGroup("drill", {pos1 - 0.5, pos[2] + 1}); 
	animator.resetTransformationGroup("connector")
	animator.translateTransformationGroup("connector", {pos1, 1}); 
end

function animHorizontal()
	animator.resetTransformationGroup("horizontal")
	animator.scaleTransformationGroup("horizontal", {storage.width + step,1})
	animator.setAnimationState("horizontalState", "on")
	animator.resetTransformationGroup("horizontal")
	animator.scaleTransformationGroup("horizontal", {storage.width,1})
	animator.translateTransformationGroup("horizontal", {2,1})
end

function drillReset(soft)
	local pos1 = (kheAA_quarryWide and 2) or 1
	if object.direction() == -1 then
		pos1 = 0
	end
	if soft then
		storage.drillPos = storage.drillPos or {pos1,-1}
		storage.drillTarget = storage.drillPos or {0,0}
		storage.drillDir = storage.drillPos or {0,0}
	else
		storage.drillPos = {pos1,-1}
		storage.drillTarget = {0,0}
		storage.drillDir = {0,0}
	end
end

function setRunning(running)
	if running then
		storage.running = true
		animator.setAnimationState("quarryState", "on")
		animator.setAnimationState("drillState", "on")
	else
		storage.running = false
		animator.setAnimationState("drillState", "idle")
		animator.setAnimationState("quarryState", "off")
	end
end

function update(dt)
	excavatorCommon.cycle(dt)
end