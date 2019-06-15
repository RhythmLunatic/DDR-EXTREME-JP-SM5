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
			else
				--GAMESTATE:ApplyGameCommand(THEME:GetMetric("ScreenSelectPlayModeCustom","Choice"..ChoiceNames[selection]));
				lua.ReportScriptError("No parameters have been set for the screen "..ChoiceNames[selection]..", so I've returned you to the main menu to prevent crashing.","LUA_ERROR");
				SCREENMAN:GetTopScreen():SetNextScreenName("ScreenTitleMenu");
			end;
			SOUND:PlayOnce(THEME:GetPathS("Common","start"),true);
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToNextScreen");
		elseif param.Name == "Back" then
			SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToPrevScreen");
		end;
		
		self:GetChild("Cursor"):x(SCREEN_CENTER_X-612/2+153*(selection-1));
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
	};
	--bottom is 1224 pixels / 2 -> 612
	--612/4 = 153
	LoadActor(THEME:GetPathG("_difficulty","cursor/_cursor "..pname(GAMESTATE:GetMasterPlayerNumber())))..{
		Name="Cursor";
		InitCommand=cmd(horizalign,left;xy,SCREEN_CENTER_X-612/2,SCREEN_BOTTOM-85);
		--[[CodeMessageCommand=function(self)
			
		end;]]
	};
	
	LoadActor("bottom")..{
		InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_BOTTOM-85);
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
		};
		--Title
		Def.BitmapText{
			Font="_arial black 28px";
			Text=string.upper(ChoiceNames[i]);
			InitCommand=cmd(maxwidth,180;horizalign,left;xy,-38,-109;diffuse,color("#41402FFF");zoom,.75);
		};
		--Description, yes I know it's dumb
		Def.BitmapText{
			Font="ScreenSelectPlayMode";
			Text=THEME:GetString("ScreenSelectPlayMode",ChoiceNames[i]);
			InitCommand=cmd(xy,155+155,40;wrapwidthpixels,220);
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
	LoadActor("back")..{ InitCommand=cmd(FullScreen); };

	--Load the chr frame here
	chr
};