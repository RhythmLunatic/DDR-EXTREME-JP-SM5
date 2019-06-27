local t = Def.ActorFrame{
  LoadActor("hl")..{
    OnCommand=cmd(cropbottom,0.1;diffuseshift;blend,Blend.Add;;effectcolor1,0.2,0.33,0,1;effectcolor2,0.2,0.33,0,0;effectperiod,1.085);
  };
};

local function GetScorePercent(profile,player)
	local song = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
	local steps = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	local score = ""

	if profile and song and steps then
		local scorelist = profile:GetHighScoreList(song,steps)
		local scores = scorelist:GetHighScores()
		local topscore = scores[1]

		if topscore then
			score = string.format("%.2f%%", topscore:GetPercentDP()*100.0)
		else
			score = "00.00%";--string.format("%.2f%%", 0)
		end
	end

	return score
end

local GetNameAndScore = function(profile)
	local song = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse()) or GAMESTATE:GetCurrentSong()
	local steps = (GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player)) or GAMESTATE:GetCurrentSteps(player)
	local score = ""
	local name = ""

	if profile and song and steps then
		local scorelist = profile:GetHighScoreList(song,steps)
		local scores = scorelist:GetHighScores()
		local topscore = scores[1]

		if topscore then
			score = string.format("%.2f%%", topscore:GetPercentDP()*100.0)
			name = topscore:GetName()
		else
			score = "00.00%"; --string.format("%.2f%%", 0)
			name = "????"
		end
	end

	return score, name
end

t[#t+1] = Def.ActorFrame{

  OnCommand=cmd(addx,350;sleep,0.9;decelerate,0.2;addx,-350);
  LoadActor("frame")..{
    InitCommand=function(self)
      if GAMESTATE:IsPlayerEnabled(PLAYER_1) ~= true then
        self:croptop(0.27)
      end;
      if GAMESTATE:IsPlayerEnabled(PLAYER_2) ~= true then
        self:cropbottom(0.27)
      end;
    end;
  };
  LoadFont("_numbers6")..{
  	--Text="57.30%";
	Condition=GAMESTATE:IsSideJoined(PLAYER_1);
	InitCommand=cmd(xy,140,-32;halign,1;zoom,.6;diffuse,PlayerColor(PLAYER_1););
  	--OnCommand=cmd(addx,380;sleep,0.366;sleep,0.6;decelerate,0.2;addx,-380;queuecommand,"Set");
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set"),
	CurrentCourseChangedMessageCommand=cmd(queuecommand,"Set"),
	CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set"),
	SetCommand=function(self)
		--Why is it checking persistent?
		if PROFILEMAN:IsPersistentProfile(PLAYER_1) then
			local player_score = GetScorePercent( PROFILEMAN:GetProfile(PLAYER_1),PLAYER_1 )
			self:settext(player_score)
		end
	end
  };
  
  LoadFont("_numbers6")..{
  	--Text="57.30%";
	Condition=GAMESTATE:IsSideJoined(PLAYER_2);
	InitCommand=cmd(xy,140,32;halign,1;zoom,.6;diffuse,PlayerColor(PLAYER_2););
  	--OnCommand=cmd(addx,380;sleep,0.366;sleep,0.6;decelerate,0.2;addx,-380;queuecommand,"Set");
	CurrentSongChangedMessageCommand=cmd(queuecommand,"Set"),
	CurrentCourseChangedMessageCommand=cmd(queuecommand,"Set"),
	CurrentStepsP1ChangedMessageCommand=cmd(queuecommand,"Set"),
	SetCommand=function(self)
		--Why is it checking persistent?
		if PROFILEMAN:IsPersistentProfile(PLAYER_2) then
			local player_score = GetScorePercent( PROFILEMAN:GetProfile(PLAYER_2),PLAYER_2 )
			self:settext(player_score)
		end
	end
  };
  
};

return t;
