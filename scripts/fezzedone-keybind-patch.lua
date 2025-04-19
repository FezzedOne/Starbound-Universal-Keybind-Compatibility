local potentialOldKeybindScripts = assets.scan("keybinds.lua")
local keybindHeaderPattern = "%-%-%[%[[%s\n]*Keybinds Library"
for _, scriptPath in ipairs(potentialOldKeybindScripts) do
    sb.logInfo("Potential keybind scripts: %s", sb.printJson(potentialOldKeybindScripts))
    local scriptFile = assets.bytes(scriptPath)
    if scriptFile:find(keybindHeaderPattern, nil, false) then
        sb.logInfo("Found Silverfeelin keybind header at '%s'.", scriptPath)
        -- This is a Silverfeelin keybind script. Replace any `if input then` check.
        local replacedOld = false
        scriptFile = scriptFile:gsub("(if input then)", function(s)
            replacedOld = true
            return [=[if type(input) == "function" then]=]
        end)
        if replacedOld then
            assets.erase(scriptPath)
            assets.add(scriptPath, scriptFile)
            if assets.origin and assets.sourceMetadata then -- Hopefully oSB gets a metadata callback soon.
                local originPath = assets.origin(scriptPath)
                local sourceMetadata = assets.sourceMetadata(originPath)
                local sourceName = sourceMetadata.friendlyName or sourceMetadata.name or originPath
                sourceName = type(sourceName) == "string" and sourceName or sb.printJson(sourceName)
                sb.logInfo(
                    "[Keybind Patch] Patched old Silverfeelin keybind script at '%s', owned by '%s'",
                    scriptPath,
                    sourceName
                )
            elseif assets.origin then
                local originPath = assets.origin(scriptPath)
                sb.logInfo(
                    "[Keybind Patch] Patched old Silverfeelin keybind script at '%s', owned by asset source at '%s'",
                    scriptPath,
                    originPath
                )
            else
                sb.logInfo("[Keybind Patch] Patched old Silverfeelin keybind script at '%s'", scriptPath)
            end
        end
    end
end
