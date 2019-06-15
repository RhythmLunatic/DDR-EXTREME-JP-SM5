local pn, controller = ...;
local tabCount = 4
local paneState = 0;

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
			SCREENMAN:GetTopScreen():GetChild("BonusFrameP1"):visible(paneState == 0);
			for i = 1,5 do
				SCREENMAN:GetTopScreen():GetChild("BarPossible"..i.."P1"):visible(paneState == 0);
				SCREENMAN:GetTopScreen():GetChild("BarActual"..i.."P1"):visible(paneState == 0);
			end;
			
			self:GetChild("QRCodePane"):visible(paneState==1);
		end;
	end;
	
	Def.ActorFrame{
		Name="MaxComboPane";
		Def.RollingNumbers{
			Font="ScreenEvaluation Combo",
			InitCommand=cmd(x,SCREEN_CENTER_X-249;y,SCREEN_CENTER_Y+104;diffuse,color("#FFFF00");playcommand,"Set";);
			OnCommand=cmd(draworder,90;zoom,1.3;horizalign,left;diffusealpha,0;sleep,0.266;linear,0.416;diffusealpha,1);
			OffCommand=cmd(sleep,0.066;sleep,0.333;linear,0.416;diffusealpha,0);
			SetCommand=function(self)
				self:Load("RollingNumbersMaxCombo")
				if GAMESTATE:GetSmallestNumStagesLeftForAnyHumanPlayer() <= 1 then
					self:targetnumber(STATSMAN:GetFinalEvalStageStats():GetPlayerStageStats(PLAYER_1):MaxCombo());
				else
					self:targetnumber(STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1):MaxCombo());
				end;
			end;
		};
		LoadActor(THEME:GetPathG("","ScreenEvaluation ComboLabel"))..{
			OnCommand=cmd(x,SCREEN_CENTER_X-276;y,SCREEN_CENTER_Y+104;draworder,90;diffusealpha,0;sleep,0.266;linear,0.416;diffusealpha,1);
			OffCommand=cmd(sleep,0.066;sleep,0.333;linear,0.416;diffusealpha,0);
		};
	};
	Def.ActorFrame{
		Name="QRCodePane";
		InitCommand=cmd(visible,false);
		--Do not attempt to modify the positioning here because it doesn't work
		LoadActor("qrcode",pn);
	};
};
return t;
