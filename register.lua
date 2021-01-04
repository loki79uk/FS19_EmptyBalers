-- ============================================================= --
-- EMPTY BALERS MOD
-- ============================================================= --
EmptyBalersREGISTER = {};

g_specializationManager:addSpecialization('emptyBalers', 'EmptyBalers', Utils.getFilename('EmptyBalers.lua', g_currentModDirectory), true);

for name, data in pairs( g_vehicleTypeManager:getVehicleTypes() ) do
	local vehicleType = g_vehicleTypeManager:getVehicleTypeByName(tostring(name));
	if SpecializationUtil.hasSpecialization(Baler, data.specializations) then
			g_vehicleTypeManager:addSpecialization(name, 'emptyBalers')
	end
end
