local x = Def.ActorFrame{
	LoadActor("_moveon")..{ InitCommand=cmd(CenterX;y,SCREEN_CENTER_Y-10); };
};

x[#x+1] = Def.Actor {
	BeginCommand=function(self)
		if SCREENMAN:GetTopScreen():HaveProfileToSave() then self:sleep(0.01); end;
		self:queuecommand("Load");
	end;
	LoadCommand=function()
		--Workaround for SaveProfileCustom not being called by SM
		for player in ivalues(GAMESTATE:GetHumanPlayers()) do
			local profileDir = PROFILEMAN:GetProfileDir(ProfileSlot[PlayerNumber:Reverse()[player]+1]);
			SaveProfileCustom(PROFILEMAN:GetProfile(player),profileDir);
		end;
	
		SCREENMAN:GetTopScreen():Continue(); 
	end;
};

return x;