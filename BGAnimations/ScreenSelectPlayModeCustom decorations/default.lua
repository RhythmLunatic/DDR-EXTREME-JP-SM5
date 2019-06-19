local function split( delimiter, text )
	local list = {}
	local pos = 1
	while 1 do
		local first,last = string.find( text, delimiter, pos )
		if first then
			table.insert( list, string.sub(text, pos, first-1) )
			pos = last+1
		else
			table.insert( list, string.sub(text, pos) )
			break
		end
	end
	return list
end

local function getOppositePlayer(pn)
	return (pn == "PlayerNumber_P1") and "PlayerNumber_P2" or "PlayerNumber_P1"
end;

--I hate metrics why am I even doing this
local ChoiceNames = split(",",THEME:GetMetric("ScreenSelectPlayModeCustom","ChoiceNames"));
local numChoices = #ChoiceNames;

local selection = 1;
local selectedHazard = false
--Sorry about the mess
chr = Def.ActorFrame{
	CodeMessageCommand=function(self, param)
		if param.Name == "Left" and selection > 1 then
			SOUND:PlayOnce(THEME:GetPathS("ScreenSelectDifficulty","change"),true);
			if selectedHazard then
				self:GetChild("Hazard"):playcommand("Hide");
				self:GetChild(ChoiceNames[selection]):playcommand("Show")
				selectedHazard = false
			end;
			self:GetChild(ChoiceNames[selection]):playcommand("LoseFocus")
			selection = selection - 1;
			self:GetChild(ChoiceNames[selection]):playcommand("GainFocus")
		elseif param.Name == "Right" and selection < numChoices then
			SOUND:PlayOnce(THEME:GetPathS("ScreenSelectDifficulty","change"),true);
			if selectedHazard then
				self:GetChild("Hazard"):playcommand("Hide");
				self:GetChild(ChoiceNames[selection]):playcommand("Show")
				selectedHazard = false;
			end;
			self:GetChild(ChoiceNames[selection]):playcommand("LoseFocus")
			selection = selection + 1;
			self:GetChild(ChoiceNames[selection]):playcommand("GainFocus")
		elseif param.Name == "Up" and ChoiceNames[selection] == "Normal" then
			if selectedHazard then
				selectedHazard = false
				self:GetChild(ChoiceNames[selection]):queuecommand("Show");
				self:GetChild("Hazard"):queuecommand("Hide")
			else
				selectedHazard = true;
				self:GetChild(ChoiceNames[selection]):queuecommand("Hide");
				self:GetChild("Hazard"):queuecommand("Show")
				--SOUND:PlayOnce(THEME:GetPathS("","Hazard"),true);
			end;
		elseif param.Name == "Start" then
			--Surely there's a better way to do this?
			if selectedHazard then
				GAMESTATE:SetCurrentPlayMode("PlayMode_Regular");
				--sMode seems to be a relic of the 3.9 days, since everything works fine
				--even if it's not set. In this case, using it to determine Hazard mode
				--probably shouldn't cause issues.
				setenv("sMode","Hazard");
				SCREENMAN:GetTopScreen():SetNextScreenName("ScreenSelectMusic");
			elseif ChoiceNames[selection] == "Casual" then
				
				GAMESTATE:SetCurrentPlayMode("PlayMode_Regular");
				SCREENMAN:GetTopScreen():SetNextScreenName(Branch.InstructionsNormal());
			
			elseif ChoiceNames[selection] == "Competitive" then
				SOUND:PlayAnnouncer("select difficulty comment medium");
				GAMESTATE:SetCurrentPlayMode("PlayMode_Regular");
				SCREENMAN:GetTopScreen():SetNextScreenName(Branch.InstructionsNormal());
			elseif ChoiceNames[selection] == "ECFA" then
				SOUND:PlayAnnouncer("select difficulty comment hard");
				setenv("sMode","ECFA");
				SCREENMAN:GetTopScreen():SetNextScreenName(Branch.InstructionsNormal());
			else
				--GAMESTATE:ApplyGameCommand(THEME:GetMetric("ScreenSelectPlayModeCustom","Choice"..ChoiceNames[selection]));
				lua.ReportScriptError("No parameters have been set for the screen "..ChoiceNames[selection]..", so I've returned you to the main menu to prevent crashing.","LUA_ERROR");
				SCREENMAN:GetTopScreen():SetNextScreenName("ScreenTitleMenu");
			end;
			SL.Global.GameMode = ChoiceNames[selection]
			SetGameModePreferences()
			--I don't know why we reload metrics here but I'm guessing it caches function results
			THEME:ReloadMetrics()
			SOUND:PlayOnce(THEME:GetPathS("Common","start"),true);
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen");
		elseif param.Name == "Back" then
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToPrevScreen");
		end;
		
		self:GetChild("Cursor"):x(SCREEN_CENTER_X-612/2+153.5*(selection-1));
		--[[if selectedHazard then
			self:GetChild("Title"):settext("Hazard"):diffusebottomedge(Color("Red"));
			self:GetChild("Description"):settext(THEME:GetString("ScreenSelectPlayMode","Hazard"));
		else
			self:GetChild("Description"):settext(THEME:GetString("ScreenSelectPlayMode",ChoiceNames[selection]));
			self:GetChild("Title"):settext(ChoiceNames[selection]):diffusebottomedge(Color("Blue"));
		end;]]
		--SCREENMAN:SystemMessage(selection.." "..param.Name);
	end;
	
	OnCommand=function(self)
		SOUND:PlayAnnouncer("select difficulty intro");
	end;
	
	LoadActor("bar")..{
		InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_BOTTOM-85);
		OnCommand=cmd(cropleft,.5;cropright,.5;linear,1;cropleft,0;cropright,0);
		OffCommand=cmd(sleep,1;linear,1;cropleft,.5;cropright,.5;);
		--OffCommand=cmd(cropbottom,0;cropleft,0;cropright,0;sleep,0.726;linear,0.726;cropleft,0.493;cropright,0.493;linear,0.264;cropbottom,1);

	};
	--bottom is 1224 pixels / 2 -> 612
	--612/4 = 153
	Def.ActorFrame{
		Name="Cursor";
		InitCommand=cmd(xy,SCREEN_CENTER_X-612/2,SCREEN_BOTTOM-85);
		
		Def.Sprite{
			Texture=THEME:GetPathG("_difficulty","cursor/_cursor "..pname(GAMESTATE:GetMasterPlayerNumber()));
			InitCommand=cmd(horizalign,left;);
			OnCommand=function(self)
				(cmd(cropleft,1;sleep,.5))(self);
				if GAMESTATE:GetNumSidesJoined() > 1 then
					self:sleep(.25):linear(.25):cropleft(.5);
				else
					self:linear(.5):cropleft(0);
				end;
			end;
			
			OffCommand=function(self)
				--Simple and annoying to manage code is still good code because you can understand it
				--SCREENMAN:SystemMessage(selection);
				self:sleep(1);
				if selection == 1 then
					self:linear(.5):cropleft(1);
				elseif selection == 2 then
					self:sleep(.5):linear(.5):cropleft(1);
				elseif selection == 3 then
					self:linear(.5):cropright(1);
				elseif selection == 4 then
					self:sleep(.5):linear(.5):cropright(1);
				end;
			end;
			--[[CodeMessageCommand=function(self)
				
			end;]]
		};
		--You're probably wondering why on earth there is two, this gets loaded if there are two players present
		Def.Sprite{
			Condition=GAMESTATE:GetNumSidesJoined() > 1;
			Texture=THEME:GetPathG("_difficulty","cursor/_cursor "..pname(getOppositePlayer(GAMESTATE:GetMasterPlayerNumber())));
			InitCommand=cmd(horizalign,left;);
			OnCommand=function(self)
				if GAMESTATE:GetNumSidesJoined() > 1 then
					self:cropright(1):sleep(.75):linear(.25):cropright(.5);
				else
					self:cropleft(1):sleep(.5):linear(.5):cropleft(0);
				end;
			end;
		};
	};
	
	LoadActor(THEME:GetPathG("_difficulty","cursor/_OK P1"))..{
		InitCommand=cmd(player,PLAYER_1;draworder,99;x,SCREEN_CENTER_X-226;y,SCREEN_CENTER_Y+84;diffusealpha,0);
		OnCommand=cmd();
		OffCommand=cmd(addy,68;diffusealpha,1;cropbottom,1;linear,0.083;addy,-68;cropbottom,0;decelerate,0.083;addy,-20;accelerate,0.083;addy,20;sleep,1;linear,0.1;cropright,1);
	};
	LoadActor(THEME:GetPathG("_difficulty","cursor/_OK P2"))..{
		InitCommand=cmd(player,PLAYER_2;draworder,99;x,152;x,SCREEN_CENTER_X-76;y,SCREEN_CENTER_Y+84;diffusealpha,0);
		OnCommand=cmd();
		OffCommand=cmd(addy,68;diffusealpha,1;cropbottom,1;linear,0.083;addy,-68;cropbottom,0;decelerate,0.083;addy,-20;accelerate,0.083;addy,20;sleep,1;linear,0.1;cropright,1);
	};
	
	LoadActor("bottom")..{
		InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_BOTTOM-85);
		OnCommand=cmd(cropleft,.5;cropright,.5;linear,1;cropleft,0;cropright,0);
		OffCommand=cmd(sleep,1;linear,1;cropleft,.5;cropright,.5;);
	};
	
	Def.ActorFrame {
		InitCommand=function(self)
			self:x(SCREEN_CENTER_X+156):y(SCREEN_CENTER_Y-14)
		end;
		LoadActor( "null" )..{
			OnCommand=cmd(zoomx,-1;cropright,1;sleep,0.264;sleep,0.132;cropright,0.936;cropbottom,1;linear,0.264;cropbottom,0;cropright,0.936;linear,0.396;cropright,0);
			OffCommand=cmd(sleep,1;sleep,0.233;linear,0.333;cropright,0.936;sleep,0.016;linear,0.267;cropbottom,1);
		};
		LoadActor( "innull" )..{
			OnCommand=cmd(x,119;y,19;horizalign,right;addx,240;cropright,1;sleep,0.264;sleep,0.132;sleep,0.264;linear,0.396;addx,-240;cropright,0);
			OffCommand=cmd(horizalign,right;sleep,1;sleep,0.236;linear,0.341;cropright,1;addx,240);
		};
	};
	
	LoadActor("../help")..{
		InitCommand=cmd(x,SCREEN_CENTER_X-165;y,SCREEN_BOTTOM-33.5;);
		OnCommand=cmd(draworder,199;shadowlength,0;diffuseblink;linear,0.5);
	};
	
	LoadActor(THEME:GetPathG("ScreenWithMenuElements","header"));
	--LoadFallbackB()

}
for i = 1,numChoices do
	chr[#chr+1] = Def.ActorFrame{
		Name=ChoiceNames[i];
		InitCommand=cmd(xy,SCREEN_CENTER_X-155--[[SCREEN_WIDTH/numChoices*i-SCREEN_WIDTH/numChoices/2]],SCREEN_CENTER_Y-15;);
		OnCommand=function(self)
			if i == selection then
				self:playcommand("GainFocus");
			else
				self:playcommand("LoseFocus")
			end;
		end;
		GainFocusCommand=cmd(visible,true);
		LoseFocusCommand=cmd(visible,false);
		HideCommand=cmd(stoptweening;decelerate,.3;rotationy,90);
		ShowCommand=cmd(stoptweening;rotationy,90;sleep,.3;decelerate,.3;rotationy,0);

		LoadActor(ChoiceNames[i])..{
			--InitCommand=cmd(addx,50);
			OnCommand=cmd(cropright,1;sleep,0.264;sleep,0.132;cropright,0.936;cropbottom,1;linear,0.264;cropbottom,0;cropright,0.936;linear,0.396;cropright,0);
			OffCommand=cmd(sleep,1;sleep,0.233;linear,0.333;cropright,0.936;sleep,0.016;linear,0.267;cropbottom,1);
		};
		--Title
		Def.BitmapText{
			Font="_arial black 28px";
			Text=string.upper(ChoiceNames[i]);
			InitCommand=cmd(maxwidth,180;horizalign,left;xy,-38,-109;diffuse,color("#41402FFF");zoom,.75;cropright,1);
			OnCommand=cmd(sleep,.75;linear,.25;cropright,0);
			OffCommand=cmd(sleep,1.25;linear,.25;cropright,1);
		};
		--Description, yes I know it's dumb
		Def.BitmapText{
			Font="ScreenSelectPlayMode";
			Text=THEME:GetString("ScreenSelectPlayMode",ChoiceNames[i]);
			InitCommand=cmd(xy,155+155,40;wrapwidthpixels,220);
			OnCommand=cmd(diffusealpha,0;sleep,1;linear,.25;diffusealpha,1);
			OffCommand=cmd(sleep,1;linear,.25;diffusealpha,0);
		};
		--[[LoadFont("_arial black 28px")..{
			Text="STANDARD";
		};]]
		--[[Def.Quad{
			InitCommand=cmd(setsize,50,SCREEN_HEIGHT);
		};]]
	};
end;
chr[#chr+1] = LoadActor("Challenge")..{
	Name="Hazard";
	InitCommand=cmd(y,SCREEN_CENTER_Y;rotationy,90);
	OnCommand=function(self)
		self:x(self:GetParent():GetChild("Competitive"):GetX());
	end;
	GainFocusCommand=cmd(diffuse,Color("White"));
	LoseFocusCommand=cmd(diffuse,color("#888888"));
	HideCommand=cmd(stoptweening;decelerate,.3;rotationy,90);
	ShowCommand=cmd(stoptweening;rotationy,90;sleep,.3;decelerate,.3;rotationy,0)
};

chr[#chr+1] = Def.ActorFrame{
	InitCommand=cmd(y,SCREEN_TOP+58;draworder,100);
	LoadActor("explanation")..{
		InitCommand=cmd(x,SCREEN_LEFT+136);
		OnCommand=cmd(draworder,99;diffusealpha,0;sleep,0.264;diffusealpha,1);
	};
	Def.Quad{
		InitCommand=cmd(x,SCREEN_LEFT+339;setsize,230,24;diffuse,color("#8cbd00"));
		OnCommand=cmd(addx,-204;sleep,0.264;sleep,0.198;linear,0.198;addx,204);
		OffCommand=cmd(sleep,0.66;linear,0.198;addx,-204);
	};
	LoadActor("arrow")..{
		InitCommand=cmd(x,SCREEN_LEFT+238);
		OnCommand=cmd(addx,-204;diffusealpha,0;sleep,0.264;diffusealpha,1;sleep,0.198;linear,0.198;addx,204);
		OffCommand=cmd(sleep,0.66;linear,0.198;addx,-204;sleep,0.198;diffusealpha,0);
	};
};
--[[chr[#chr+1] = Def.Quad{
		InitCommand=cmd(setsize,SCREEN_WIDTH/4,35;xy,SCREEN_CENTER_X,SCREEN_HEIGHT*.75;diffuse,color("0,0,0,.8");fadeleft,.5;faderight,.5);
	};
	
chr[#chr+1] = Def.Quad{
		InitCommand=cmd(setsize,SCREEN_WIDTH,35;xy,SCREEN_CENTER_X,SCREEN_HEIGHT*.80;diffuse,color("0,0,0,.8"));
	};

chr[#chr+1] = LoadFont("Common Label")..{
	Name="Title";
	Text=ChoiceNames[1];
	InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_HEIGHT*.75;diffusebottomedge,Color("Blue"));
};
chr[#chr+1] = LoadFont("Common Normal")..{
		Name="Description";
		Text=THEME:GetString("ScreenSelectPlayMode",ChoiceNames[1]);
		InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_HEIGHT*.80;);
	};]]

--It's returning an ActorFrame with the 'chr' ActorFrame inside it
--chr itself cannot be returned because inputs will stop working so just live with it
return Def.ActorFrame{
	--LoadActor("back")..{ InitCommand=cmd(FullScreen); };

	--Load the chr frame here
	chr
};