--[[
------ WARNING ------
This script was made for a minecraft mod "CC: Tweaked"!
Don't run this script in outside of CC: Tweaked, or won't work!
]]

local versionOfCommand = "0.0.1"
local productionTypeId = 0

local prodp = {
    [0] = {"Snapshot", 0},
    [1] = {"Alpha",    0},
    [2] = {"Beta",     0},
    [3] = {"Release",  1}
}

local function prod()
    return prodp[productionTypeId][1]
end

local function prok()
    return (prodp[productionTypeId][2] == 1 and true or false)
end

-- copy from https://gist.github.com/mmurdoch/3806239

local ENCODABET = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
	'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
	'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd',
	'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
	'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
	'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', '+', '/'
}

local DECODABET = {}
for i, v in ipairs(ENCODABET) do
	DECODABET[v] = i - 1
end

local PAD = "="

local function toChar (octet)
	return ENCODABET[octet + 1]
end

local function toOctet (char)
	return DECODABET[char]
end

local function decode(input)
    local length = #input
    if PAD then
        length = input:find(PAD, 1, true) or (length + 1)
        length = length - 1
    end
    assert(length > 0, "Invalid input: "..tostring(input))
    
    local out = {}
    
    local i = 1
	while i <= length - 3 do
		local buffer = 0
		local b = toOctet(input:sub(i, i))
		b = bit.blshift(b, 18)
		buffer = bit.bor(buffer, b)
		i = i + 1
		b = toOctet(input:sub(i, i))
		b = bit.blshift(b, 12)
		buffer = bit.bor(buffer, b)
		i = i + 1
		b = toOctet(input:sub(i, i))
		b = bit.blshift(b, 6)
		buffer = bit.bor(buffer, b)
		i = i + 1
		b = toOctet(input:sub(i, i))
		buffer = bit.bor(buffer, b)
		i = i + 1
		b = bit.blogic_rshift(buffer, 16)
		b = bit.band(b, 0xff)
		out[#out + 1] = b
		b = bit.blogic_rshift(buffer, 8)
		b = bit.band(b, 0xff)
		out[#out + 1] = b
		b = bit.band(buffer, 0xff)
		out[#out + 1] = b
	end
	if length % 4 == 2 then
		local buffer = 0

		local b = toOctet(input:sub(i, i))
		b = bit.blshift(b, 18)
		buffer = bit.bor(buffer, b)
		i = i + 1
		
		b = toOctet(input:sub(i, i))
		b = bit.blshift(b, 12)
		buffer = bit.bor(buffer, b)
		i = i + 1
		
		b = bit.blogic_rshift(buffer, 16)
		b = bit.band(b, 0xff)
		out[#out + 1] = b
	elseif length % 4 == 3 then
		local buffer = 0
		
		local b = toOctet(input:sub(i, i))
		b = bit.blshift(b, 18)
		buffer = bit.bor(buffer, b)
		i = i + 1
		
		b = toOctet(input:sub(i, i))
		b = bit.blshift(b, 12)
		buffer = bit.bor(buffer, b)
		i = i + 1
		
		b = toOctet(input:sub(i, i))
		b = bit.blshift(b, 6)
		buffer = bit.bor(buffer, b)
		i = i + 1

		b = bit.blogic_rshift(buffer, 16)
		b = bit.band(b, 0xff)
		out[#out + 1] = b
		b = bit.blogic_rshift(buffer, 8)
		b = bit.band(b, 0xff)
		out[#out + 1] = b
	elseif length % 4 == 1 then
		error("Invalid length input string, extra character: "..tostring(input:sub(i, i)))
	end
	return string.char(unpack(out))
end

-- end copy of https://gist.github.com/mmurdoch/3806239

local charLimit = 16384

local environments = {
    {"charLimit", 16384}
}

local pgn = arg[0] or fs.getName(shell.getRunningProgram())

local usageList = {
    {"-uuid","<username>",          0,0,"Get Player UUID from Username"},
    {"--getUuidByName","<username>",0,1,"Get Player UUID from Username"},
    {"-profile","<uuid>",           1,0,"Get Profile, Skin and cape data from Player UUID"},
    {"--getProfileByUuid","<uuid>", 1,1,"Get Profile, Skin and cape data from Player UUID"},
    {"-blockedsvrs",nil,            2,0,"Shows the server Blocked in minecraft"},
    {"-u",nil,                      3,0,"Shows the usage (this)"},
    {"--usage",nil,                 3,1,"Shows the usage (this)"},
    {"-env",nil,                    4,0,"Shows Environment variables for this command"}
}

local function writeByUsageId(id,type)
    if id == nil then printError("ID has not inputed;") return end
    return ((type == 0 or type == nil) and usageList[id][1] or type == 1 and usageList[id][2] or type == 2 and usageList[id][5]) or nil
end

local function cmdPrint(type)
    if type == "usage" then
        local programName = arg[0] or fs.getName(shell.getRunningProgram())
        print(pgn.." v" .. versionOfCommand .. " - " .. prod())
        if not prok() then
            print("This version is in-development;\nPlease improve the experience of the project at:\nGitHub, NoteSwiper/cctweaked-thing/discussions!")
        end
        for i = 1, #usageList do
            term.setTextColour(colours.green)
            write("\t " .. writeByUsageId(i))
            term.setTextColour(colours.yellow)
            if (writeByUsageId(i,1) ~= nil) then
                write(" " .. writeByUsageId(i,1) .. "\n")
            else
                write("\n")
            end
            term.setTextColour(colours.white)
            write("\t\t Short Description: " .. writeByUsageId(i,2) or "No short description in this command")
            write("\n\n")
        end
    elseif type == "name" then
        local programName = arg[0] or fs.getName(shell.getRunningProgram())
        print(pgn.." v" .. versionOfCommand .. " - " .. prod())
        if not prok() then
            print("This version is in-development;\nPlease improve the experience of the project at:\nGitHub, NoteSwiper/cctweaked-thing/discussions!")
        end
    elseif type == "env" then
        local programName = arg[0] or fs.getName(shell.getRunningProgram())
        print(pgn.." v" .. versionOfCommand .. " - " .. prod())
        if not prok() then
            print("This version is in-development;\nPlease improve the experience of the project at:\nGitHub, NoteSwiper/cctweaked-thing/discussions!")
        end
        write("\nEnvironment Variables: \n")
        for i = 1, #environments do
            term.setTextColour(colours.lightBlue)
            write("\t"..environments[i][1]..": ")
            term.setTextColour(colours.cyan)
            write(environments[i][2].."\n")
        end
    else
        print("Error while executing: cmdPrint parameter \"type\" got nil;")
        return
    end
end

local tArgs = { ... }

local subType = tArgs[1]

if #tArgs < 1 or subType == "--usage" or subType == "-u" then
    cmdPrint("usage")
    return
end

local apiUrls = {
    ["UsernameToUUID"] = "https://api.mojang.com/users/profiles/minecraft/",
    ["UUIDToProfiles"] = "https://sessionserver.mojang.com/session/minecraft/profile/",
    ["BlockedServers"] = "https://sessionserver.mojang.com/blockedservers"
}

local apiEndpoints = {
    ["UsernameToUUID"] = "Mojang General API; /users/profiles/minecraft/",
    ["UUIDToProfiles"] = "Mojang Session API; /session/minecraft/profile/",
    ["BlockedServers"] = "Mojang Session API; /blockedservers"
}

if not http then
    local programName = arg[0] or fs.getName(shell.getRunningProgram())
    printError(programName .. " requires the http API, but it is not enabled!")
    printError("Set http.enabled to true in CC: Tweaked's server config!")
    return
end

local function get(typeofAPI,value)
    if typeofAPI ~= "BlockedServers" and not value then
        printError("value cannot be null!")
        return
    end
    local ok, err = http.checkURL(apiUrls[typeofAPI] .. (value and value or ""))
    if not ok then
        printError(err or "The API Endpoint has invalid, contact to developper.")
        return
    end
    
    write("Connecting to API Endpoint: \n\t")
    term.setTextColour(colours.yellow)
    write((apiEndpoints[typeofAPI] or "Unexcepted variable value"))
    term.setTextColour(colours.white)
    write("\n\nWith the value: ")
    term.setTextColour(colours.yellow)
    write("\"@"..(value and value or "").."\"")
    term.setTextColour(colours.white)
    
    local response = http.get(apiUrls[typeofAPI] .. (value and value or ""))
    if not response then
        term.setTextColour(colours.red)
        print("\n\nFailed to connect!\nIt seems the API Endpoint has currently down!")
        term.setTextColour(colours.white)
        return nil
    end
    
    term.setTextColour(colours.green)
    print("\n\nGetting data from API has completed!\n")
    term.setTextColour(colours.white)
    
    local sResponse = response.readAll()
    local count = #sResponse
    response.close()
    if count > charLimit then
        sResponse = "The response has reached the limit \""..charLimit.."\"!"
    end
    return "Characters: " .. count .. "\n" .. sResponse or "Response got nil"
end

if subType == "--getUuidByName" or subType == "-uuid" then
    print(cmdPrint("name"))
    write("\n")
    if tArgs[2] == nil then
        printError("<username> cannot be null!")
        return nil
    end
    local response = get("UsernameToUUID",tArgs[2])
    if response ~= nil then
        term.setTextColour(colours.yellow)
        print(response)
        term.setTextColour(colours.white)
        return response
    else
        printError("Response got nil")
        return nil
    end
elseif subType == "-profile" or subType == "--getProfileByUuid" then
    print(cmdPrint("name"))
    write("\n")
    if tArgs[2] == nil then
        printError("<uuid cannot be null!")
        return nil
    end
    local response = get("UUIDToProfiles",tArgs[2])
    if response ~= nil then
        term.setTextColour(colours.yellow)
        local cpp = 0
        print(response)
        term.setTextColour(colours.white)
        print("The auto-decoding has not implemented.\nthere is Decoder for base64 in code, but I don't know how to extract JSON key...\nGet to discussion @ GitHub:\nNoteSwiper/cctweaked-thing/discussions")
        return response
    else
        printError("Response got nil")
        return nil
    end
elseif subType == "-blockedsvrs" then
    print(cmdPrint("name"))
    write("\n")
    local response = get("BlockedServers")
    if response ~= nil then
        term.setTextColour(colours.yellow)
        print(response)
        term.setTextColour(colours.white)
        return response
    else
        printError("Response got nil")
        return nil
    end
elseif subType == "-env" then
    print(cmdPrint("env"))
    return
else
end
