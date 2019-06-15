function Setup()
	--Reset PlayerOptions
	ActiveModifiers = {
		P1 = table.shallowcopy(PlayerDefaults),
		P2 = table.shallowcopy(PlayerDefaults),
		--MACHINE = table.shallowcopy(PlayerDefaults),
		--Save values here if editing profile
	}
	PerfectionistMode = {
		PlayerNumber_P1 = false,
		PlayerNumber_P2 = false
	};
end
