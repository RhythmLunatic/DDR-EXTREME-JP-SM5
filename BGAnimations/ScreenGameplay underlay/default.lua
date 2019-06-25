local t = Def.ActorFrame{};

t[#t+1] = Def.ActorFrame{
	Def.ActorFrame{
		Name="DangerP1";
		Def.ActorFrame{
			Name="Single";
			BeginCommand=function(self)
			local style = GAMESTATE:GetCurrentStyle()
			local styleType = style:GetStyleType()
			local bDoubles = (styleType == 'StyleType_OnePlayerTwoSides' or styleType == 'StyleType_TwoPlayersSharedSides')
				self:visible(not bDoubles)
			end;
		HealthStateChangedMessageCommand=function(self, param)
			if param.PlayerNumber == PLAYER_1 then
				if param.HealthState == "HealthState_Danger" then
					self:RunCommandsOnChildren(cmd(playcommand,"Show"))
				else
					self:RunCommandsOnChildren(cmd(playcommand,"Hide"))
				end
			end
		end;
			Def.Quad{
				InitCommand=cmd(visible,false;FullScreen;diffuse,color("0,0,0,1"));
				ShowCommand=cmd(visible,true;diffuseblink;effectperiod,1);
				HideCommand=cmd(visible,false);
			};
			LoadActor("_danger")..{
				InitCommand=cmd(visible,false;Center;zoomto,640,480);
				ShowCommand=cmd(visible,true;diffuseshift;effectcolor1,color("1,1,1,1");effectcolor2,color("0,0,0,0");effectperiod,0;effectclock,"music";);
				HideCommand=cmd(visible,false);
			};
		};
	};
	Def.ActorFrame{
		Name="DangerP2";
		Def.ActorFrame{
			Name="Single";
			BeginCommand=function(self)
			local style = GAMESTATE:GetCurrentStyle()
			local styleType = style:GetStyleType()
			local bDoubles = (styleType == 'StyleType_OnePlayerTwoSides' or styleType == 'StyleType_TwoPlayersSharedSides')
				self:visible(not bDoubles)
			end;
		HealthStateChangedMessageCommand=function(self, param)
			if param.PlayerNumber == PLAYER_2 then
				if param.HealthState == "HealthState_Danger" then
					self:RunCommandsOnChildren(cmd(playcommand,"Show"))
				else
					self:RunCommandsOnChildren(cmd(playcommand,"Hide"))
				end
			end
		end;
			Def.Quad{
				InitCommand=cmd(visible,false;FullScreen;diffuse,color("0,0,0,1"));
				ShowCommand=cmd(visible,true;diffuseblink;effectperiod,1);
				HideCommand=cmd(visible,false);
			};
			LoadActor("_danger")..{
				InitCommand=cmd(visible,false;Center;zoomto,640,480);
				ShowCommand=cmd(visible,true;diffuseshift;effectcolor1,color("0,0,0,1");effectcolor2,color("0,0,0,0")effectclock,"music";);
				HideCommand=cmd(visible,false);
			};
		};
	};
};

--It's either CS or AC that displays bars on the side of the bg videos. I have to check. -Inori
--WE ARE NOT DOING THIS -ARC
--[[t[#t+1] = LoadActor("frame")..{
	InitCommand=cmd(Center);
};]]

t[#t+1] = Def.Quad{
-- Extra lifemeter under, shit breaks because lol reverse.
	InitCommand=cmd(CenterX;diffuse,color("0,0,0,1"));
	OnCommand=function(self)
		if GAMESTATE:IsAnExtraStage() == true then
			self:setsize(SCREEN_WIDTH,70)
			:y(SCREEN_BOTTOM-78):
			addy(78):linear(0.6):addy(-78);
		else
			self:setsize(SCREEN_WIDTH,58)
			:y(SCREEN_TOP+20):
			addy(-50):linear(0.6):addy(50);
		end
	end;
	OffCommand=function(self)
		if GAMESTATE:IsAnExtraStage() == true then
			self:linear(0.8);addy(78);
		else
			self:linear(0.8):addy(-58);
		end;
	end;
};

-- if the MenuTimer is enabled, we should reset SSM's MenuTimer now that we've reached Gameplay
if PREFSMAN:GetPreference("MenuTimer") then
	SL.Global.MenuTimer.ScreenSelectMusic = ThemePrefs.Get("ScreenSelectMusicMenuTimer")
end

local Players = GAMESTATE:GetHumanPlayers()
local t = Def.ActorFrame{ Name="GameplayUnderlay" }


for player in ivalues(Players) do
	-- StepStatistics takes up the full screenwidth and thus needs to draw under everything else
	t[#t+1] = LoadActor("./PerPlayer/StepStatistics/default.lua", player)
	-- actual underlays
	--t[#t+1] = LoadActor("./PerPlayer/Danger.lua", player)
	--t[#t+1] = LoadActor("./PerPlayer/ScreenFilter.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/nice.lua", player)
end

-- shared UI elements for both players
--t[#t+1] = LoadActor("./Shared/Header.lua")
--t[#t+1] = LoadActor("./Shared/SongInfoBar.lua") -- title and progress bar

-- per-player UI elements
for player in ivalues(Players) do
	t[#t+1] = LoadActor("./PerPlayer/UpperNPSGraph.lua", player)
	--t[#t+1] = LoadActor("./PerPlayer/Score.lua", player)
	--t[#t+1] = LoadActor("./PerPlayer/DifficultyMeter.lua", player)

	--t[#t+1] = LoadActor("./PerPlayer/LifeMeter/default.lua", player)

	t[#t+1] = LoadActor("./PerPlayer/ColumnFlashOnMiss.lua", player)
	--t[#t+1] = LoadActor("./PerPlayer/MeasureCounter.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/TargetScore/default.lua", player)
	t[#t+1] = LoadActor("./PerPlayer/SubtractiveScoring.lua", player)
end

-- gets overlapped by StepStatistics otherwise...?
--t[#t+1] = LoadActor("./Shared/BPMDisplay.lua")

if GAMESTATE:IsPlayerEnabled(PLAYER_1) and GAMESTATE:IsPlayerEnabled(PLAYER_2) then
	t[#t+1] = LoadActor("./Shared/WhoIsCurrentlyWinning.lua")
end

return t;
