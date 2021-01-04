-- ============================================================= --
-- EMPTY BALERS MOD
-- ============================================================= --
EmptyBalers = {};

addModEventListener(EmptyBalers);

function EmptyBalers.prerequisitesPresent(specializations)
	return SpecializationUtil.hasSpecialization(Baler, specializations)
end

function EmptyBalers.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onUpdateTick", EmptyBalers)
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", EmptyBalers)
end

function EmptyBalers:onRegisterActionEvents(isSelected, isOnActiveVehicle)
    local actionEventId
    if isOnActiveVehicle then
        _, actionEventId = InputBinding.registerActionEvent(g_inputBinding, 'EMPTY_BALER', self, EmptyBalers.emptyBaler, false, true, false, true)
		g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_NORMAL)
		g_inputBinding:setActionEventTextVisibility(actionEventId, true)
		EmptyBalers.actionEventId = actionEventId
    end
end

function EmptyBalers:onUpdateTick(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
	local spec = self.spec_baler
	
	local baleIsCotton = false
	if spec.dummyBale.currentBale ~= nil then
		if spec.dummyBale.currentBaleFillType == 11 then
			baleIsCotton = true
		end
	end
	
	if EmptyBalers.actionEventId ~= nil then
		local fillLevel = self:getFillUnitFillLevelPercentage(spec.fillUnitIndex)
		if baleIsCotton==false and table.getn(spec.bales)==0 and fillLevel>0 and fillLevel<1 then
			g_inputBinding:setActionEventActive(EmptyBalers.actionEventId, true)
			EmptyBalers.emptyingEnabled = true
		else
			g_inputBinding:setActionEventActive(EmptyBalers.actionEventId, false)
			EmptyBalers.emptyingEnabled = false
		end
	end
end

function EmptyBalers:emptyBaler(actionName, inputValue)
	if EmptyBalers.emptyingEnabled then
		local spec = self.spec_baler
		local fillUnit = self.spec_fillUnit.fillUnits[spec.fillUnitIndex]
		fillUnit.fillLevel = 0
		fillUnit.fillType = FillType.UNKNOWN
		if spec.dummyBale.currentBale ~= nil then
			self:deleteDummyBale()
		end
		spec.dummyBale.currentBale = nil
		spec.lastBaleFillLevel = 0
	end
end

function EmptyBalers:loadMap(name)
	--print("Load: 'Empty Balers'")
	EmptyBalers.emptyingEnabled 	= false		-- cleaning enabled/disabled
	EmptyBalers.actionEventId		= nil		-- handle for the action event
	EmptyBalers.initialised			= false		-- inisitalised flag
end

function EmptyBalers:deleteMap()
end

function EmptyBalers:mouseEvent(posX, posY, isDown, isUp, button)
end

function EmptyBalers:keyEvent(unicode, sym, modifier, isDown)
end

function EmptyBalers:draw()
end

function EmptyBalers:update(dt)
	if not EmptyBalers.initialised then
		EmptyBalers.initialised = true
	end
end