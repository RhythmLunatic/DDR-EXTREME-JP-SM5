local t = LoadFallbackB();

t[#t+1] = StandardDecorationFromFileOptional("StyleIcon","StyleIcon");
t[#t+1] = StandardDecorationFromFile("StageDisplay","StageDisplay");


--Panes.
for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
	--Positioning is done inside the panes.lua... (Argument 2 is which player controls the pane, since this was ported from my DDR2014 theme)
	t[#t+1] = LoadActor("panes",pn, pn);
	local negativeOffset = (pn == PLAYER_1 and -1 or 1);
	t[#t+1] = Def.ActorFrame{
	  	OnCommand=cmd(addy,100;sleep,0.749;accelerate,.25;addy,-100);
	  	OffCommand=cmd(accelerate,.25;addy,100);
	  	LoadFont("_20px fonts")..{
	  		Name="StatsText";
			Text="MORE STATS";
			InitCommand=cmd(xy,SCREEN_CENTER_X+170*negativeOffset,SCREEN_BOTTOM-75;zoom,.8);
			
			--InitCommand=cmd(x,SCREEN_CENTER_X-276;y,SCREEN_CENTER_Y+104;diffuse,Color("White");draworder,100;visible,true;zoom,5);
		};
		Def.Sprite{
			--Bet you didn't know I could do this
			Texture=THEME:GetPathF("_game chars","16px 4x1.png");
			InitCommand=cmd(zoom,.8;y,SCREEN_BOTTOM-69;animate,false;setstate,1;glowshift;effectcolor1,1,1,1,0.2;effectcolor2,0,0,0,0;effectperiod,0.198;);
			OnCommand=function(self)
				local st = self:GetParent():GetChild("StatsText")
				self:x(st:GetX() - st:GetWidth()/2);
				self:horizalign(left);
			end;
			
		};
		Def.Sprite{
			Texture=THEME:GetPathF("_game chars","16px 4x1.png");
			InitCommand=cmd(zoom,.8;y,SCREEN_BOTTOM-69;animate,false;setstate,2;glowshift;effectcolor1,1,1,1,0.2;effectcolor2,0,0,0,0;effectperiod,0.198;);
			OnCommand=function(self)
				local st = self:GetParent():GetChild("StatsText")
				self:x(st:GetX() + st:GetWidth()/2);
				self:horizalign(right);
			end;
			
		};
	};
end;

--Only load if one player is present. If there are two players then it will be loaded as a pane instead.
if GAMESTATE:GetNumSidesJoined() == 1 then
	local pn = GAMESTATE:GetMasterPlayerNumber()
	local negativeOffset = (pn == PLAYER_1 and -1 or 1);
	t[#t+1] = Def.ActorFrame{
		OnCommand=cmd(diffusealpha,0;sleep,0.266;linear,0.416;diffusealpha,1);
		OffCommand=cmd(sleep,0.066;sleep,0.333;linear,0.416;diffusealpha,0);
		LoadActor("Graphs",pn)..{
			--It's minus because for P1 we want it on the P2 side and for P2 we want it on the P1 side.
			--Meaning the side without anything currently using that space.
			InitCommand=cmd(x,SCREEN_CENTER_X-SCREEN_WIDTH*.25*negativeOffset);
		};
		LoadActor("Pane4",pn)..{
			--Why is the graph centered but this one isnt???????
			InitCommand=cmd(x,SCREEN_CENTER_X-SCREEN_WIDTH*.25*negativeOffset-300/2);
		};
	};
end;



-- Score display.

t[#t+1] = LoadActor(THEME:GetPathG("ScreenEvaluation","ScoreLabel"))..{
	InitCommand=cmd(xy,THEME:GetMetric("ScreenEvaluation","ScoreLabelX"),THEME:GetMetric("ScreenEvaluation","ScoreLabelY"));
	OnCommand=THEME:GetMetric("ScreenEvaluation","ScoreLabelOnCommand");
	OffCommand=THEME:GetMetric("ScreenEvaluation","ScoreLabelOffCommand");
};
for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
	--negativeOffset = (pn == PLAYER_1 ? -1 : 1)
	local negativeOffset = (pn == PLAYER_1 and -1 or 1);
	t[#t+1] = LoadFont("ScreenEvaluation ScoreNumber")..{
		Text=string.format("%.2f%%", STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetPercentDancePoints()*100.0);
		--This is more ternary, it means halign,pn == PLAYER_1 ? 1 : 0, aka halign,1 if pn == PLAYER_1 else halign,0
		InitCommand=cmd(xy,SCREEN_CENTER_X+60*negativeOffset,SCREEN_CENTER_Y+140;diffuse,PlayerColor(pn);halign,(pn == PLAYER_1 and 1 or 0));
		OnCommand=cmd(addx,365*negativeOffset;sleep,0.749;decelerate,0.25;addx,-365*negativeOffset);
		OffCommand=cmd(sleep,0.066;accelerate,0.25;addx,380*negativeOffset);
	};
end;

-- difficulty & mods display
if ShowStandardDecoration("DifficultyIcon") then
	if GAMESTATE:GetPlayMode() == 'PlayMode_Rave' then
		-- in rave mode, we always have two players.
	else
		-- otherwise, we only want the human players
		for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
			local diffIcon = LoadActor(THEME:GetPathG(Var "LoadingScreen", "DifficultyIcon"), pn)
			t[#t+1] = StandardDecorationFromTable("DifficultyIcon" .. ToEnumShortString(pn), diffIcon);

			t[#t+1] = LoadFont("ScreenGameplay player options")..{
				Text=GAMESTATE:GetPlayerState(pn):GetPlayerOptionsString("ModsLevel_Current");
				--Text="AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
				InitCommand=cmd(
					draworder,100;
					--Behold my legendary math skills
					x,THEME:GetMetric('ScreenEvaluation','LargeBannerX')+(THEME:GetMetric('ScreenEvaluation','BannerWidth')/2-5)*(pn == PLAYER_1 and -1 or 1);
					y,THEME:GetMetric('ScreenEvaluation','LargeBannerY')+10;
					horizalign,(pn == PLAYER_1 and left or right);
					diffuse,PlayerColor(pn);
					--I honestly have no idea how it's calculating the maxwidth here since zoom kind of messes it up. This value just happens to work.
					maxwidth,THEME:GetMetric('ScreenEvaluation','BannerWidth')*.7;
					zoom,.6;
				);
				OnCommand=THEME:GetMetric("ScreenEvaluation","LargeBannerFrameOnCommand");
				OffCommand=THEME:GetMetric("ScreenEvaluation","LargeBannerFrameOffCommand");
			};
		end
	end
end

-- Machine Record, personal record...
for pn in ivalues(PlayerNumber) do

	local MetricsName = "MachineRecord" .. PlayerNumberToString(pn);
	t[#t+1] = LoadActor( THEME:GetPathG(Var "LoadingScreen", "MachineRecord"), pn ) .. {
		InitCommand=function(self)
			self:player(pn);
			self:name(MetricsName);
			ActorUtil.LoadAllCommandsAndSetXY(self,Var "LoadingScreen");
		end;
	};
	local MetricsName = "PersonalRecord" .. PlayerNumberToString(pn);
	t[#t+1] = LoadActor( THEME:GetPathG(Var "LoadingScreen", "PersonalRecord"), pn ) .. {
		InitCommand=function(self)
			self:player(pn);
			self:name(MetricsName);
			ActorUtil.LoadAllCommandsAndSetXY(self,Var "LoadingScreen");
		end;
	};
end


t[#t+1] = Def.ActorFrame {
	Condition=GAMESTATE:HasEarnedExtraStage()--[[ and GAMESTATE:IsExtraStage() and not GAMESTATE:IsExtraStage2()]];
	InitCommand=cmd(draworder,105);
	LoadActor( THEME:GetPathS("ScreenEvaluation","try Extra1" ) ) .. {
		Condition=THEME:GetMetric( Var "LoadingScreen","Summary" ) == false;
		OnCommand=cmd(play);
	};
};


return t;
