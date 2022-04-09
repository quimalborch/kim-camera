--I've pulled this from the ESX locales

Locales = {}

function _(str, ...)    -- luacheck: no unused

	if Locales[Config['locale']] ~= nil then

		if Locales[Config['locale']][str] ~= nil then
			return string.format(Locales[Config['locale']][str], ...)
		else
			return 'Translation [' .. Config['locale'] .. '][' .. str .. '] does not exist'
		end

	else
		return 'Locale [' .. Config['locale'] .. '] does not exist'
	end

end

function Locale(str, ...)   -- luacheck: no unused
	return tostring(_(str, ...):gsub("^%l", string.upper))
end