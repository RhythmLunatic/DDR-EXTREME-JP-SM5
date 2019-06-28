local t = LoadFallbackB();

t[#t+1] = StandardDecorationFromFileOptional("StyleIcon","StyleIcon");
t[#t+1] = StandardDecorationFromFile("StageDisplay","StageDisplay");

--Panes.
for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
	--Positioning is done inside the panes.lua...
	t[#t+1] = LoadActor("panes",pn, pn);
	local negativeOffset = (pn == PLAYER_1 and -1 or 1);
	t[#t+1] = Def.ActorFrame{
	  	OnCommand=cmd(addy,100;sleep,0.749;accelerate,.25;addy,-100);
	  	OffCommand=cmd(accelerate,.25;addy,100);
	  	LoadFont("_20px fonts")..{
	  		Name="StatsText";
			Text="MORE STATS";
			InitCommand=cmd(xy,SCREEN_CENTER_X+170*negativeOffset,SCREEN_BOTTOM-75;zoom,.8);
			
			--InitCommamd=cmd(x,SCREEN_CENTER_X-276;y,SCREEN_CENTER_Y+104;diffuse,Color("White");draworder,100;visible,true;zoom,5);
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

-- difficulty display
if ShowStandardDecoration("DifficultyIcon") then
	if GAMESTATE:GetPlayMode() == 'PlayMode_Rave' then
		-- in rave mode, we always have two players.
	else
		-- otherwise, we only want the human players
		for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
			local diffIcon = LoadActor(THEME:GetPathG(Var "LoadingScreen", "DifficultyIcon"), pn)
			t[#t+1] = StandardDecorationFromTable("DifficultyIcon" .. ToEnumShortString(pn), diffIcon);
		end
	end
end

for pn in ivalues(PlayerNumber) do
	local MetricsName = "MachineRecord" .. PlayerNumberToString(pn);
	t[#t+1] = LoadActor( THEME:GetPathG(Var "LoadingScreen", "MachineRecord"), pn ) .. {
		InitCommand=function(self)
			self:player(pn);
			self:name(MetricsName);
			ActorUtil.LoadAllCommandsAndSetXY(self,Var "LoadingScreen");
		end;
	};
end

for pn in ivalues(PlayerNumber) do
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
	Condition=GAMESTATE:HasEarnedExtraStage() and GAMESTATE:IsExtraStage() and not GAMESTATE:IsExtraStage2();
	InitCommand=cmd(draworder,105);
	LoadActor( THEME:GetPathS("ScreenEvaluation","try Extra1" ) ) .. {
		Condition=THEME:GetMetric( Var "LoadingScreen","Summary" ) == false;
		OnCommand=cmd(play);
	};
};


return t;
