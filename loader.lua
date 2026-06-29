local function getGlobal(path)
	local value = getfenv(0)

	while value ~= nil and path ~= "" do
		local name, nextValue = string.match(path, "^([^.]+)%.?(.*)$")
		value = value[name]
		path = nextValue
	end

	return value
end

function hasFunctions(...)
    local funcs = {...}
    local missing = {}

    for _, f in ipairs(funcs) do
        local found = false
        
        for _, a in ipairs(f) do
            if type(a) == "string" and getGlobal(a) then
                found = true
                break
            end
        end

        if not found then
            table.insert(missing, f[1] or "unknown_function")
        end
    end

    return missing
end

function passedCheck()
    local missing = hasFunctions(
        {"queueonteleport", "queue_on_teleport"}, 
        {"getconnections"}, 
        {"request", "http_request", (http and "http.request")}, 
        {"fireproximityprompt"}, 
        {"isfile"},
        {"writefile"},
        {"readfile"},
        {"firesignal"}
    )

    return missing, #missing == 0 and true or false
end

repeat
    task.wait()
until game:IsLoaded()

local places = {
    [129279692364812] = {
        s = "https://raw.githubusercontent.com/shxmrocks/nullscape/refs/heads/main/scripts/lobby.lua"
    },
    [100588763114828] = {
        s = "https://raw.githubusercontent.com/shxmrocks/nullscape/refs/heads/main/scripts/game.lua"
    }
}

local valid = places[game.PlaceId]

if not valid then
    return game:GetService("Players").LocalPlayer:Kick("join nullscpae")
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/shxmrocks/Obsidian/main/Library.lua"))()
local info = loadstring(game:HttpGet("https://raw.githubusercontent.com/shxmrocks/nullscape/refs/heads/main/status.lua"))()

local Loading = Library:CreateLoading({
    Title = "nullscape sample",
    Icon = 94613692767003,
    TotalSteps = 4
})

Loading:SetMessage("Initializing...")
Loading:SetDescription("Waiting for game to load...")
-- how does nulslcpae check for laoded
task.wait(1)

Loading:SetCurrentStep(1)
Loading:SetDescription("Checking requirements...")
local missing, reqMet = passedCheck()
task.wait(2)
if not reqMet then
	Loading:ShowErrorPage(true)
	Loading:SetErrorMessage("Missing function(s): " .. table.concat(missing, ", "))
	Loading:SetErrorButtons({
		Close = {
			Title = "Close",
			Variant = "Destructive",
			Callback = function()
				Loading:Destroy()
			end
		}
	})

    return
end

Loading:SetCurrentStep(2)
Loading:SetDescription("Loading script...")
local loaded = loadstring(game:HttpGet(valid.s))
if not loaded then
    Loading:ShowErrorPage(true)
	Loading:SetErrorMessage("Failed to load script")
	Loading:SetErrorButtons({
		Close = {
			Title = "Close",
			Variant = "Destructive",
			Callback = function()
				Loading:Destroy()
			end
		}
	})

    return
end
task.wait(2)

Loading:SetCurrentStep(3)
Loading:SetDescription("Ready to start!")
Loading:ShowSidebarPage(true)

Loading.Sidebar:AddLabel("Status: " .. (info.status and "[🟢]" or "[🔴]"))
Loading.Sidebar:AddLabel("Version: " .. info.version)

Loading.Sidebar:AddButton("Load", function() 
    Loading:ShowSidebarPage(false)
    Loading:SetCurrentStep(4) 
    task.wait(1)

    if info.status then
        loaded()
    else
        Loading:ShowErrorPage(true)
        Loading:SetErrorMessage("Script is currently down")
        Loading:SetErrorButtons({
            Close = {
                Title = "Close",
                Variant = "Destructive",
                Callback = function()
                    Loading:Destroy()
                end
            }
        })

        return
    end 
end)
