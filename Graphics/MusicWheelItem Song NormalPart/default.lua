function clearLamp(self, param, player)
    local song = self.ParamSong;
    local steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
    if song then
        if steps then
            if PROFILEMAN:GetProfile(PLAYER_1):GetHighScoreListIfExists(song,steps) then
                local pgrade = PROFILEMAN:GetProfile(PLAYER_1):GetHighScoreList(song,steps):GetHighScores()[1]
                if pgrade then
                    --SCREENMAN:SystemMessage("Has grade");
                    --self:Load(THEME:GetPathG("MusicWheelItem Song", "NormalPart/clearlump_"..clearlamps[steps:GetDifficulty()]));
                    self:visible(true)
                    if pgrade == 'Grade_Failed' then
						SCREENMAN:SystemMessage("Failed");
                        self:glowblink();
                        self:effectcolor1(color("#FF0000"))
                        self:effectcolor2(color("#000000"))
		                self:effectperiod(1)
                    end;
                else
                    self:visible(false)
                end;
            else
                self:visible(false);
            end;
        end;
    end;
end;

function ChangeGrade(self,param)
	local steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
	if self.ParamSong and steps and PROFILEMAN:GetProfile(PLAYER_1):GetHighScoreListIfExists(self.ParamSong,steps) then
		local pgrade = PROFILEMAN:GetProfile(PLAYER_1):GetHighScoreList(self.ParamSong,steps):GetHighScores()[1]
		if pgrade then
			self:visible(true):settext(getGradeLetter(Grade:Reverse()[pgrade:GetGrade()]));
		else
			self:visible(false)
		end;
	else
		self:visible(false);
	end;
end;

return Def.ActorFrame{
	LoadActor("back")..{
	};
	Def.Sprite{
		Texture=THEME:GetPathG("MusicWheelItem Song","NormalPart/clearlamp");
        InitCommand=cmd(x,-696/4;horizalign,left;faderight,1;--[[diffuse,Color("HoloBlue")]]);
		CurrentStepsP1ChangedMessageCommand=function(self) clearLamp(self) end;
		CurrentSongChangedMessageCommand=function(self) clearLamp(self) end;
		SetCommand=function(self,param)
			self.ParamSong = param.Song
			clearLamp(self)
		end;
    };
	
	Def.BitmapText{
        Font="_shared1";
        Name = "Difficulty_Beginner";
		--Text="AAA";
        InitCommand=cmd(diffuse,Color("HoloBlue");horizalign,1;uppercase,true;x,110;maxwidth,40);
		CurrentStepsP1ChangedMessageCommand=function(self) ChangeGrade(self) end;
		CurrentSongChangedMessageCommand=function(self) ChangeGrade(self) end;
		SetCommand=function(self,param)
			self.ParamSong = param.Song
			ChangeGrade(self)
		end;
	};

};