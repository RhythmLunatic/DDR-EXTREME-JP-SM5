function TextBannerAfterSet(self,param)
	local Title=self:GetChild("Title")
	local Subtitle=self:GetChild("Subtitle")
	local Artist=self:GetChild("Artist")

	if Subtitle:GetText() == "" then
		Title:maxwidth(192)
		Title:y(-8)
		Title:zoom(1.2)
		Title:zoomx(1.4)

		Subtitle:visible(false)

		Artist:maxwidth(349)
		Artist:y(10)
		Artist:zoom(0.75)
	else
		Title:maxwidth(274)
		Title:zoom(1)
		Title:y(-10)

		-- subtitle below title
		Subtitle:visible(true)
		Subtitle:zoom(0.55)
		Subtitle:maxwidth(274)

		Artist:maxwidth(349)
		Artist:y(9)
		Artist:zoom(0.7)
	end

end

local difficultyToIconIndex = {
	Difficulty_Beginner		= 0,
	Difficulty_Easy			= 1,
	Difficulty_Medium		= 2,
	Difficulty_Hard			= 3,
	Difficulty_Challenge 	= 4,
	Difficulty_Edit			= 5
}
function GetDifficultyIconFrame(diff) return difficultyToIconIndex[diff] or difficultyToIconIndex['Difficulty_Edit'] end

function LoadStepsDisplayGameplayFrame(self,player)
	local difficultyStates = {
		Difficulty_Beginner	 = 0,
		Difficulty_Easy		 = 2,
		Difficulty_Medium	 = 4,
		Difficulty_Hard		 = 6,
		Difficulty_Challenge = 8,
		Difficulty_Edit		 = 10,
	};
	local selection;
	if GAMESTATE:IsCourseMode() then
		-- get steps of current course entry
		selection = GAMESTATE:GetCurrentTrail(player);
		local entry = selection:GetTrailEntry(GAMESTATE:GetLoadingCourseSongIndex()+1)
		selection = entry:GetSteps()
	else
		selection = GAMESTATE:GetCurrentSteps(player);
	end;
	local diff = selection:GetDifficulty()
	local state = difficultyStates[diff] or 10;
	if player == PLAYER_2 then state = state + 1; end;
	return state;
end;

function Actor:scale_or_crop_background()
	if PREFSMAN:GetPreference("StretchBackgrounds") then
		self:cropto(SCREEN_WIDTH, SCREEN_HEIGHT)
	else
		local graphicAspect = self:GetWidth()/self:GetHeight()
		self:zoomto(SCREEN_HEIGHT*graphicAspect,SCREEN_HEIGHT)
	end
end

function Actor:Cover()
	self:scaletocover(0,0,SCREEN_RIGHT,SCREEN_BOTTOM);
end;

--Kyz scale_to_fit
function Actor:scaletofit2(width,height)
	local xscale= width / self:GetWidth()
	local yscale= height / self:GetHeight()
	self:zoom(math.min(xscale, yscale))
end;

-- summary evaluation banner handling (for 1-5 stages)
-- ganked from my ddr 5th mix port
local summaryBannerX = {
	MaxStages1 = { SCREEN_CENTER_X },
	MaxStages2 = {
		SCREEN_CENTER_X+45,
		SCREEN_CENTER_X-45
	},
	MaxStages3 = {
		SCREEN_CENTER_X+60,
		SCREEN_CENTER_X,
		SCREEN_CENTER_X-60
	},
	MaxStages4 = {
		SCREEN_CENTER_X+45,
		SCREEN_CENTER_X+15,
		SCREEN_CENTER_X-15,
		SCREEN_CENTER_X-45
	},
	MaxStages5 = {
		SCREEN_CENTER_X+60,
		SCREEN_CENTER_X+30,
		SCREEN_CENTER_X,
		SCREEN_CENTER_X-30,
		SCREEN_CENTER_X-60
	}
}

local summaryBannerY = {
	MaxStages1 = { SCREEN_CENTER_Y-140 },
	MaxStages2 = {
		SCREEN_CENTER_Y-130,
		SCREEN_CENTER_Y-150
	},
	MaxStages3 = {
		SCREEN_CENTER_Y-120,
		SCREEN_CENTER_Y-140,
		SCREEN_CENTER_Y-160
	},
	MaxStages4 = {
		SCREEN_CENTER_Y-125,
		SCREEN_CENTER_Y-135,
		SCREEN_CENTER_Y-145,
		SCREEN_CENTER_Y-155
	},
	MaxStages5 = {
		SCREEN_CENTER_Y-120,
		SCREEN_CENTER_Y-130,
		SCREEN_CENTER_Y-140,
		SCREEN_CENTER_Y-150,
		SCREEN_CENTER_Y-160
	}
}

function GetSummaryBannerX(num)
	local maxStages = PREFSMAN:GetPreference('SongsPerPlay')

	-- check how many stages were played...
	local playedStages = STATSMAN:GetStagesPlayed()
	if playedStages < maxStages then
		-- long versions and/or marathons were involved.
		if playedStages == 1 then return summaryBannerX.MaxStages1[1]
		elseif playedStages == 2 then return summaryBannerX.MaxStages2[num]
		elseif playedStages == 3 then return summaryBannerX.MaxStages3[num]
		elseif playedStages == 4 then return summaryBannerX.MaxStages4[num]
		end
	elseif playedStages > maxStages then
		-- extra stages
		if playedStages == 1 then return summaryBannerX.MaxStages1[1]
		elseif playedStages == 2 then return summaryBannerX.MaxStages2[num]
		elseif playedStages == 3 then return summaryBannerX.MaxStages3[num]
		elseif playedStages == 4 then return summaryBannerX.MaxStages4[num]
		elseif playedStages == 5 then return summaryBannerX.MaxStages5[num]
		end
	else
		-- normal behavior
		if maxStages == 1 then return summaryBannerX.MaxStages1[1]
		elseif maxStages == 2 then return summaryBannerX.MaxStages2[num]
		elseif maxStages == 3 then return summaryBannerX.MaxStages3[num]
		elseif maxStages == 4 then return summaryBannerX.MaxStages4[num]
		elseif maxStages == 5 then return summaryBannerX.MaxStages5[num]
		end
	end
end

function GetSummaryBannerY(num)
	local maxStages = PREFSMAN:GetPreference('SongsPerPlay')

	-- check how many stages were played...
	local playedStages = STATSMAN:GetStagesPlayed()
	if playedStages < maxStages then
		-- long versions and/or marathons were involved.
		if playedStages == 1 then return summaryBannerY.MaxStages1[1]
		elseif playedStages == 2 then return summaryBannerY.MaxStages2[num]
		elseif playedStages == 3 then return summaryBannerY.MaxStages3[num]
		elseif playedStages == 4 then return summaryBannerY.MaxStages4[num]
		end
	elseif playedStages > maxStages then
		-- extra stages
		if playedStages == 1 then return summaryBannerY.MaxStages1[1]
		elseif playedStages == 2 then return summaryBannerY.MaxStages2[num]
		elseif playedStages == 3 then return summaryBannerY.MaxStages3[num]
		elseif playedStages == 4 then return summaryBannerY.MaxStages4[num]
		elseif playedStages == 5 then return summaryBannerY.MaxStages5[num]
		end
	else
		-- normal behavior
		if maxStages == 1 then return summaryBannerY.MaxStages1[1]
		elseif maxStages == 2 then return summaryBannerY.MaxStages2[num]
		elseif maxStages == 3 then return summaryBannerY.MaxStages3[num]
		elseif maxStages == 4 then return summaryBannerY.MaxStages4[num]
		elseif maxStages == 5 then return summaryBannerY.MaxStages5[num]
		end
	end
end

-- GetCharAnimPath(sPath)
-- Easier access to Characters folder (taken from ScreenHowToPlay.cpp)
function GetCharAnimPath(sPath) return "/Characters/"..sPath end



local gradeNames = {
    "••••", --The font mapped the chraracter incorrectly, these show up as stars
    "•••",
    "••",
    "•",
    "S+",
    "S",
    "S-",
	"A+",
	"A",
	"A-",
	"B+",
	"B",
	"B-",
	"C+",
	"C",
	"C-",
	"D",
    "INVALID!"
};

function getGradeLetter(grade)
  --[[if type(grade) ~= "number" then
	SCREENMAN:SystemMessage("Error: getGradeLetter is for NUMBERS, you idiot. You gave: "..grade);
	return "AAA";
  end;]]
	assert(grade, "Grade was nil!");
	if grade < #gradeNames then
		--Because lua arrays start at 1...
		--You can't preform arithmatic on an enum for some odd reason, so it has to be turned into a number.
		--grade = grade + 1;
		local gradeLetter = gradeNames[Grade:Reverse()[grade+1]];
		--[[if grade == nil then
			SCREENMAN:SystemMessage("Grade was nil!!");
			return "F";
		end;]]
		return gradeLetter;
	else
		return "F";
	end;
end;

function gradeToNumber(grade)
	return Grade:Reverse()[grade]
end;

function IsW1AllowedHere()
	if PREFSMAN:GetPreference("AllowW1") == "AllowW1_Everywhere" then
		return true;
	elseif PREFSMAN:GetPreference("AllowW1") == "AllowW1_CoursesOnly" then
		return (GAMESTATE:GetCurrentPlayMode() == 'PlayMode_Nonstop' or GAMESTATE:GetCurrentPlayMode() == "PlayMode_Oni" or GAMESTATE:GetCurrentPlayMode() == "PlayMode_Endless")
	end;
	return false;
end;

function EvalW1Offset()
	return IsW1AllowedHere() and 25 or 0
end;


local gsCodes = {
	-- steps
	GroupSelect1 = {
		default = "Up",
		--dance = "Up",
		pump = "UpLeft",
	},
	GroupSelect2 = {
		default = "Down",
		--dance = "Down",
		pump = "UpRight",
	},
	GroupSelect3 = {
		default = "MenuUp"
	},
	GroupSelect4 = {
		default= "MenuDown"
	},
	OptionList = {
		default = "Left,Right,Left,Right",
		pump = "DownLeft,DownRight,DownLeft,DownRight,DownLeft,DownRight"
	},
	--Alternative for menu buttons instead of pads
	OptionList2 = {
		default = "MenuLeft,MenuRight,MenuLeft,MenuRight,MenuLeft,MenuRight"
	},
	Left = {
		default = "Left",
		pump = "DownLeft"
	},
	Right = {
		default = "Right",
		pump = "DownRight"
	},
	Start = {
		default = "Start",
		pump = "Center"
	}
};

local function CurGameName()
	return GAMESTATE:GetCurrentGame():GetName()
end

function MusicSelectMappings(codeName)
	local gameName = string.lower(CurGameName())
	local inputCode = gsCodes[codeName]
	return inputCode[gameName] or inputCode["default"]
end
