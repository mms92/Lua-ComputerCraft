local expect = require "cc.expect"
local expect, field, range = expect.expect, expect.field, expect.range

local reactor = false
local fuelTank = false
local battery = false
local coolantTank = false
local reactor_type = false

-- function bind
-- bind a reactor to the library ( try to find it if no name given)
-- name : the name of the peripheral to connect (optional)

local function bind( name )
	expect(1, name, "string", "nil")
	if not name then
		reactor = peripheral.find("BiggerReactors_Reactor")
		if not reactor then return false, "no reactor found" end
	else
		if not peripheral.isPresent(name) then return false, ("no such peripheral, '%s'"):format(name) end
		if not peripheral.hasType(name, "BiggerReactors_Reactor") then return false, ("'%s' is not a reactor'"):format(name) end
		reactor = peripheral.wrap(name)
	end
	fuelTank = reactor.fuelTank()
	battery = reactor.battery()
	coolantTank = reactor.coolantTank()
	reactorType = battery and 1 or 2

	return true
end



local function fuelInfo()
	if fuelTank then
		t = {
			["temp"] = reactor.fuelTemperature(),
			["reactivity"] = fuelTank.fuelReactivity(),
			["capacity"] = fuelTank.capacity(),
			["stored"] = fuelTank.totalReactant(),
			["fuel"] = fuelTank.fuel(),
			["waste"] = fuelTank.waste(),
			["burned"] = fuelTank.burnedLastTick()
		}
		t.level = {
			["total"] = t.stored / t.capacity * 100,
			["fuel"] = t.fuel / t.capacity * 100,
			["waste"] = t.waste / t.capacity * 100
		}
		return t
	else
		return nil
	end
end

local function controlRodInfo()
	if reactor then
		local t = {}
		for i=1, reactor.controlRodCount() do
			local controlRod = reactor.getControlRod(i-1)
			t[i] = {
				controlrod.name(),
				controlRod.level()
			}
		end
	end
end

local function batteryInfo()
	if battery then
		t = {
			["capacity"] = battery.capacity(),
			["stored"] = battery.stored(),
			["generated"] = battery.generatedLastTick()
		}
		t["level"] = t.stored / t.capacity * 100
	else
		return nil
	end
end

local function coolantInfo()
	if coolantTank then
		return {
			["error"] = "not implemented"
		}
	else
		return nil
	end
end

local function getInfo()
	local t
	if reactor then
		return {
			["active"] = reactor.active(),
			["ambientTemp"] = reactor.ambientTemperature(),
			["caseTemp"] = reactor.casingTemperature(),
			["type"] = reactorType,
			["fuel"] = fuelInfo(),
			["controlRod"] = controlRodInfo(),
			["battery"] = batteryInfo(),
			["coolant"] = coolantInfo()
		}
	else
		return {
			["error"] = "no reactor binded"
		}
	end
end

local function setAllRodsLevels(value)
	expect(1, value, "number")
	value = math.max(math.min(value,100),0)
	if reactor then
		reactor.setAllControlRodLevels(value)
		return true
	else
		return false, "no reactor binded"
	end
end

local function setRodLevel(id, value)
	expect(1, id, "number")
	expect(2, value, "number")
	value = math.max(math.min(value,100),0)
	if reactor then
		range(id, 1, reactor.controlRodCount())
		reactor.getControlRod(id-1).setLevel(value)
		return true
	else
		return false, "no reactor binded"
	end
end

local function setActive(value)
	expect(1, value, "boolean")
	if reactor then
		reactor.setActive(value)
		return true
	else
		return false, "no reactor binded"
	end
end

local function ejectWaste()
	if reactor then
		reactor.ejectWaste()
		return true
	else
		return false, "no reactor binded"
	end
end
return {
	["description"] = {
		["bind( ?name ) : boolean, nil/string"] = [[usage : bind the target reactor to the library
if name is not given, the function will search for peripheral with the type 'BiggerReactors_Reactor' and bind to the first found
name : (optional) name of the peripheral to bind
returns : true if successfuly binded, false and an error message otherwise
]],
		["getInfo() : table"] = [[usage : return all informations of the reactor
returns : a table wich format is described bellow
{
	active : boolean : is the reactor active/running ?
	ambientTemp : number : the ambient temperature of the reactor
	caseTemp : number : the temperature of the exterior wall of the reactor
	type : number : the type number of the reactor, 1 = passive cooling / direct generator, 2 = active cooling / turbine generator
	fuel : table : a table with all fuel informations
	controlRod : table : a table with all controls rods informations
	battery : table/nil : if type = 1, a table with all battery informations
	coolant : table/nil : if type = 2, a table with all coolant informations
}]]
		["setAllRodsLevels( value ) : boolean, nil/string"] = [[usage : set the level of every rods
value : the target insertion level, between 0 and 100]]
		["setRodLevel( id, value ) : boolean, nil/string"] = [[
usage : set the level of the specified rod
id : the id of the rod between 1 and reactor rod count
value : the target insertion level, between 0 and 100
]]
	},
	["bind"] = bind,
	["getInfo"] = getInfo,
	["setAllRodsLevels"] = setAllRodsLevels,
	["setRodLevel"] = setRodLevel,
	["setActive"] = setActive,
	["ejectWaste"] = ejectWaste
}