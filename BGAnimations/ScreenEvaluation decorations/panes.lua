local pn, controller = ...;
local tabCount = 4
local paneState = 0;

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
local PercentDP = stats:GetPercentDancePoints()
local percent = FormatPercentScore(PercentDP)

local game = GAMESTATE:GetCurrentGame():GetName()

--Here we go again.
local negativeOffset = (pn == PLAYER_1 and -1 or 1);
local t = Def.ActorFrame{

	--Input handler
	CodeMessageCommand=function(self,params)
		if params.PlayerNumber==controller then
			if params.Name=="Left" then
				if paneState > 0 then
					--soundeffect:play();
					SOUND:PlayOnce(THEME:GetPathS("ScreenOptions","change" ));
					paneState = paneState - 1;
				end;
			elseif params.Name=="Right" then
				if paneState < (tabCount-1) then
					--soundeffect:play();
					SOUND:PlayOnce(THEME:GetPathS("ScreenOptions","change" ));
					paneState = paneState + 1;
				end;
			else
				SCREENMAN:SystemMessage("Unknown button: "..params.Name);
			end;
			
			self:GetChild("MaxComboPane"):visible(paneState==0);
			SCREENMAN:GetTopScreen():GetChild("BonusFrame"..pname(pn)):visible(paneState == 0);
			for i = 1,5 do
				SCREENMAN:GetTopScreen():GetChild("BarPossible"..i..pname(pn)):visible(paneState == 0);
				SCREENMAN:GetTopScreen():GetChild("BarActual"..i..pname(pn)):visible(paneState == 0);
			end;
			
			self:GetChild("QRCodePane"):visible(paneState==1);
			self:GetChild("PercentPane"):visible(paneState==2);
			self:GetChild("ArrowPane"):visible(paneState==3);
		end;
	end;
	
	Def.ActorFrame{
		Name="MaxComboPane";
		Def.RollingNumbers{
			Font="ScreenEvaluation Combo",
			InitCommand=cmd(x,SCREEN_CENTER_X+249*negativeOffset;y,SCREEN_CENTER_Y+104;diffuse,color("#FFFF00");playcommand,"Set";);
			OnCommand=cmd(draworder,90;zoom,1.3;horizalign,(pn == PLAYER_1 and left or right);diffusealpha,0;sleep,0.266;linear,0.416;diffusealpha,1);
			OffCommand=cmd(sleep,0.066;sleep,0.333;linear,0.416;diffusealpha,0);
			SetCommand=function(self)
				self:Load("RollingNumbersMaxCombo")
				if GAMESTATE:GetSmallestNumStagesLeftForAnyHumanPlayer() <= 1 then
					self:targetnumber(STATSMAN:GetFinalEvalStageStats():GetPlayerStageStats(pn):MaxCombo());
				else
					self:targetnumber(stats:MaxCombo());
				end;
			end;
		};
		LoadActor(THEME:GetPathG("","ScreenEvaluation ComboLabel"))..{
			OnCommand=cmd(x,SCREEN_CENTER_X+276*negativeOffset;y,SCREEN_CENTER_Y+104;draworder,90;diffusealpha,0;sleep,0.266;linear,0.416;diffusealpha,1);
			OffCommand=cmd(sleep,0.066;sleep,0.333;linear,0.416;diffusealpha,0);
		};
	};
	Def.ActorFrame{
		Name="QRCodePane";
		InitCommand=cmd(visible,false);
		--Do not attempt to modify the positioning here because it doesn't work
		LoadActor("qrcode",pn);
	};
	
	Def.ActorFrame{
		Name="PercentPane";
		InitCommand=cmd(visible,false;x,SCREEN_CENTER_X+249*negativeOffset;y,SCREEN_CENTER_Y;);
		LoadFont("Common Normal")..{
			Text="Your score: "..percent
		};
		LoadFont("Common Normal")..{
			InitCommand=cmd(y,20);
			Text="Tier "..stats:GetGrade();
		};
	};
	
	Def.ActorFrame{
		Name="ArrowPane",
		InitCommand=function(self)
			--[[local style = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())
			if style == "OnePlayerTwoSides" then
				--self:x(SCREEN_CENTER_X*negativeOffset);
			else]]
			self:x(SCREEN_CENTER_X+373*negativeOffset);

			self:visible(false)
		end,

		--LoadActor("Pane2/Percentage.lua", pn),
		--LoadActor("Pane2/JudgmentLabels.lua", pn),
		LoadActor("Pane2/Arrows.lua", pn)
	}
};
return t;
