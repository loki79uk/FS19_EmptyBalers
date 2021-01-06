-- ============================================================= --
-- EMPTY BALERS MOD
-- ============================================================= --
EmptyBalers = {};

--addModEventListener(EmptyBalers);

function EmptyBalers.prerequisitesPresent(specializations)
	return SpecializationUtil.hasSpecialization(Baler, specializations)
end

function EmptyBalers.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", EmptyBalers)
	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", EmptyBalers)
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", EmptyBalers)
end

function EmptyBalers.registerFunctions(vehicleType)
	SpecializationUtil.registerFunction(vehicleType, "emptyBaler", EmptyBalers["emptyBaler"])
end

function EmptyBalers:onLoad(savegame)
	local spec = self.spec_emptyBalers
	spec.actionEventId = nil
	spec.emptyingEnabled = false
end

function EmptyBalers:onRegisterActionEvents(isSelected, isOnActiveVehicle)
    local actionEventId
    if isOnActiveVehicle then
        _, actionEventId = InputBinding.registerActionEvent(g_inputBinding, 'EMPTY_BALER', self, EmptyBalers.actionEventEmptyBaler, false, true, false, true)
		g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_NORMAL)
		g_inputBinding:setActionEventTextVisibility(actionEventId, true)
		
		self.spec_emptyBalers.actionEventId = actionEventId
    end
end

function EmptyBalers:onUpdate(dt, isActiveForInput, isSelected)
	local spec = self.spec_emptyBalers
	local baler = self.spec_baler

	if spec.actionEventId ~= nil then
		local fillLevel = self:getFillUnitFillLevelPercentage(baler.fillUnitIndex)		
		local baleIsCotton = false
		if baler.dummyBale.currentBale ~= nil then
			if baler.dummyBale.currentBaleFillType == 11 then
				baleIsCotton = true
			end
		end
		if baleIsCotton==false and table.getn(baler.bales)==0 and fillLevel>0 and fillLevel<1 then
			g_inputBinding:setActionEventActive(spec.actionEventId, true)
			spec.emptyingEnabled = true
		else
			g_inputBinding:setActionEventActive(spec.actionEventId, false)
			spec.emptyingEnabled = false
		end
	end
end

function EmptyBalers:actionEventEmptyBaler(actionName, inputValue, callbackState, isAnalog)
	if self.spec_emptyBalers.emptyingEnabled then
		local vehicle = self.selectionObject.vehicle
		self:emptyBaler(vehicle, false)
	end
end

function EmptyBalers:emptyBaler(vehicle, noEventSend)
	local spec = self.spec_emptyBalers
	local baler = self.spec_baler
	local fillUnit = self.spec_fillUnit.fillUnits[baler.fillUnitIndex]
	fillUnit.fillLevel = 0
	fillUnit.fillType = FillType.UNKNOWN
	if baler.dummyBale.currentBale ~= nil then
		self:deleteDummyBale()
	end
	baler.dummyBale.currentBale = nil
	baler.lastBaleFillLevel = 0

	if noEventSend == nil or noEventSend == false then
		if g_server == nil then
			g_client:getServerConnection():sendEvent(EmptyBalerEvent:new(vehicle))
		end
	end
end

function EmptyBalers:loadMap(name)
	--print("Load: 'Empty Balers'")
	EmptyBalers.initialised	= false
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


EmptyBalerEvent = {}
EmptyBalerEvent_mt = Class(EmptyBalerEvent, Event)
InitEventClass(EmptyBalerEvent, "EmptyBalerEvent")

function EmptyBalerEvent:emptyNew()
	local self =  Event:new(EmptyBalerEvent_mt)
	return self
end

function EmptyBalerEvent:new(object)
	local self = EmptyBalerEvent:emptyNew()
	self.object = object
	return self
end

function EmptyBalerEvent:readStream(streamId, connection)
	self.object = NetworkUtil.readNodeObject(streamId)
	self:run(connection)
end

function EmptyBalerEvent:writeStream(streamId, connection)
	NetworkUtil.writeNodeObject(streamId, self.object)
end

function EmptyBalerEvent:run(connection)
	if not connection:getIsServer() then
		self.object:emptyBaler(self.object, true)
	end
end
