function clearLamp(self)
    local song = self.ParamSong;
    local steps = GAMESTATE:GetCurrentSteps(self.Player)
    if song then
        if steps then
            if PROFILEMAN:GetProfile(self.Player):GetHighScoreListIfExists(song,steps) then
                local pgrade = PROFILEMAN:GetProfile(self.Player):GetHighScoreList(song,steps):GetHighScores()[1]
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

function ChangeGrade(self,player)
	--assert(player,"supply a player, idiot");
	local steps = GAMESTATE:GetCurrentSteps(player)
	if self.ParamSong and steps and PROFILEMAN:GetProfile(player):GetHighScoreListIfExists(self.ParamSong,steps) then
		local pgrade = PROFILEMAN:GetProfile(player):GetHighScoreList(self.ParamSong,steps):GetHighScores()[1]
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
		Condition=GAMESTATE:IsSideJoined(PLAYER_1);
		Texture=THEME:GetPathG("MusicWheelItem Song","NormalPart/clearlamp");
        InitCommand=cmd(x,-696/4;horizalign,left;faderight,1;--[[diffuse,Color("HoloBlue")]]);
        OnCommand=function(self)
        	if GAMESTATE:IsSideJoined(PLAYER_2) then
        		self:cropbottom(.5);
        	end;
        end;
		CurrentStepsP1ChangedMessageCommand=function(self) clearLamp(self) end;
		CurrentSongChangedMessageCommand=function(self) clearLamp(self) end;
		SetCommand=function(self,param)
			self.ParamSong = param.Song
			self.Player = PLAYER_1
			clearLamp(self)
		end;
    };
	Def.Sprite{
		Condition=GAMESTATE:IsSideJoined(PLAYER_2);
		Texture=THEME:GetPathG("MusicWheelItem Song","NormalPart/clearlamp");
        InitCommand=cmd(x,-696/4;horizalign,left;faderight,1;--[[diffuse,Color("HoloBlue")]]);
        OnCommand=function(self)
        	if GAMESTATE:IsSideJoined(PLAYER_1) then
        		self:croptop(.5);
        	end;
        end;
		CurrentStepsP1ChangedMessageCommand=function(self) clearLamp(self) end;
		CurrentSongChangedMessageCommand=function(self) clearLamp(self) end;
		SetCommand=function(self,param)
			self.ParamSong = param.Song
			self.Player = PLAYER_2
			clearLamp(self)
		end;
    };
	
	Def.BitmapText{
		Condition=GAMESTATE:IsSideJoined(PLAYER_1);
        Font="_shared1";
        Name = "Difficulty_Beginner";
		--Text="AAA";
        InitCommand=cmd(diffuse,PlayerColor(PLAYER_1);horizalign,1;uppercase,true;x,97;maxwidth,30);
		CurrentStepsP1ChangedMessageCommand=function(self) ChangeGrade(self,PLAYER_1) end;
		CurrentSongChangedMessageCommand=function(self) ChangeGrade(self,PLAYER_1) end;
		SetCommand=function(self,param)
			self.ParamSong = param.Song
			ChangeGrade(self,PLAYER_1)
		end;
	};
	Def.BitmapText{
		Condition=GAMESTATE:IsSideJoined(PLAYER_2);
        Font="_shared1";
        Name = "Difficulty_Beginner";
		--Text="AAA";
        InitCommand=cmd(diffuse,PlayerColor(PLAYER_2);horizalign,1;uppercase,true;x,130;maxwidth,30);
		CurrentStepsP1ChangedMessageCommand=function(self) ChangeGrade(self,PLAYER_2) end;
		CurrentSongChangedMessageCommand=function(self) ChangeGrade(self,PLAYER_2) end;
		SetCommand=function(self,param)
			self.ParamSong = param.Song
			ChangeGrade(self,PLAYER_2)
		end;
	};

};
