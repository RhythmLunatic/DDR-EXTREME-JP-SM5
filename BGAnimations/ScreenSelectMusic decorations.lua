local t = LoadFallbackB();

t[#t+1] = StandardDecorationFromFileOptional("StyleIcon","StyleIcon");
t[#t+1] = StandardDecorationFromFile("StageDisplay","StageDisplay")
t[#t+1] = StandardDecorationFromFile("BannerFrame","BannerFrame")
t[#t+1] = StandardDecorationFromFileOptional("BPMDisplay","BPMDisplay")
t[#t+1] = StandardDecorationFromFileOptional("SortDisplay","SortDisplay")

-- difficulty icons
if ShowStandardDecoration("DifficultyIcons") then
	for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
		local diffFrame = LoadActor(THEME:GetPathG(Var "LoadingScreen", "DifficultyFrame"), pn)
		t[#t+1] = StandardDecorationFromTable( "DifficultyFrame" .. ToEnumShortString(pn), diffFrame );

		local diffIcon = LoadActor(THEME:GetPathG(Var "LoadingScreen", "DifficultyIcon"), pn)
		t[#t+1] = StandardDecorationFromTable( "DifficultyIcon" .. ToEnumShortString(pn), diffIcon );
	end
end

t[#t+1] = StandardDecorationFromFileOptional("GrooveRadar","GrooveRadar")

-- StepsDisplay
local function StepsDisplay(pn)
	local function set(self, player)
		self:SetFromGameState(player);
	end

	local name = "StepsDisplaySelMusic";

	local sd = Def.StepsDisplay {
		InitCommand=cmd(Load,name..ToEnumShortString(pn),GAMESTATE:GetPlayerState(pn););
		CurrentSongChangedMessageCommand=function(self)
			local song = GAMESTATE:GetCurrentSong();
			if not song then
				-- hacky hack 1: set all feet to nothing!
				self:GetChild("Ticks"):settext("0000000000");
				-- hacky hack 2: diffuse to beginner
				self:GetChild("Ticks"):diffuse(CustomDifficultyToColor("Beginner"))
			end
		end;
	};

	if pn == PLAYER_1 then
		sd.CurrentStepsP1ChangedMessageCommand=function(self) set(self, pn); end;
		sd.CurrentTrailP1ChangedMessageCommand=function(self) set(self, pn); end;
	else
		sd.CurrentStepsP2ChangedMessageCommand=function(self) set(self, pn); end;
		sd.CurrentTrailP2ChangedMessageCommand=function(self) set(self, pn); end;
	end

	return sd;
end

-- song options text (e.g. 1.5xmusic)
t[#t+1] = StandardDecorationFromFileOptional("SongOptions","SongOptions")

-- other items (balloons, etc.)

t[#t+1] = StandardDecorationFromFile( "Balloon", "Balloon" );

t[#t+1] = LoadActor("GrooveRadar base")..{
	InitCommand=cmd(x,SCREEN_CENTER_X-168;y,SCREEN_CENTER_Y+90;);
	BeginCommand=cmd(playcommand,"CheckCourseMode");
	OnCommand=cmd(zoom,0;rotationz,-360;sleep,0.3;decelerate,0.4;rotationz,0;zoom,1);
	OffCommand=cmd(sleep,0.4;accelerate,0.383;zoom,0;rotationz,-360);
	CheckCourseModeCommand=function(self,param)
			if GAMESTATE:IsCourseMode() == true then
				self:visible(false)
			end
		end;
}

--Sprite Based CDTitle
t[#t+1] = Def.ActorFrame{
	OnCommand=function(s)
		s:fov(10):draworder(101)
		:spin():effectmagnitude(0,-180,0)
		:xy( SCREEN_CENTER_X-84, SCREEN_CENTER_Y-83 )
		:vanishpoint(SCREEN_CENTER_X-84, SCREEN_CENTER_Y-83)
		:addx(-280-100):sleep(0.450):linear(0.267):addx(274+100)
		:linear(0.05):addx(-6):decelerate(0.116):addx(12):decelerate(0.067)
		:addx(-4):decelerate(0.1):addx(4)
	end,
	OffCommand=function(s)
		s:accelerate(0.316):addx(-SCREEN_WIDTH/2.28)
	end,
	CurrentSongChangedMessageCommand=function(s)
		local c = {"BorderBack","Front","Back","BorderFront"}
		for v in ivalues(c) do
			s:GetChild(v):GetChild("Spr"):visible(false)
			if GAMESTATE:GetCurrentSong() then
				if GAMESTATE:GetCurrentSong():GetCDTitlePath() then
					s:GetChild(v):GetChild("Spr"):visible(true):Load( GAMESTATE:GetCurrentSong():GetCDTitlePath() )
				end
			end
		end
	end,

	Def.ActorFrame{
		Name="BorderBack",
		Def.Sprite{
			Name="Spr", OnCommand=function(s) s:z(-2):glowshift()
				:effectcolor1(color("1,1,1,1")):cullmode("CullMode_Back") end,
		},
	},
	Def.ActorFrame{
		Name="Back",
		Def.Sprite{
			Name="Spr", OnCommand=function(s) s:shadowlength(1):cullmode("CullMode_Back"):glowshift():effectcolor2(color("0,0,0,0.7")):effectcolor1(color("0,0,0,0")) end,
		},
	},
	Def.ActorFrame{
		Name="Front",
		Def.Sprite{ Name="Spr", OnCommand=function(s) s:shadowlength(1):glow(Color.White):diffuse(color("0,0,0,1")):cullmode("CullMode_Front") end }
	},
	Def.ActorFrame{
		Name="BorderFront",
		Def.Sprite{ Name="Spr", OnCommand=function(s) s:z(-2):glowshift():effectoffset(0.5):effectcolor2(color("0.9,0.9,0.9,1")):effectcolor1(Color.Black)
			:cullmode("CullMode_Front"):effecttiming( 0.5,0.1,0.4,0 ) end,
	},
	}
}

return t
