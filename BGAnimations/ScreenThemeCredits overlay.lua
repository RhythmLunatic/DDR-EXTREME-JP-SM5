local function getWavyText(s,x,y)
	local letters = Def.ActorFrame{}
	local spacing = 15
	for i = 1, #s do
		local c = s:sub(i,i)
		--local c = "a"
		letters[i] = LoadFont("_soms2")..{
			Text=c;
			InitCommand=cmd(x,x-(#s)*spacing/2+i*15;y,y;effectoffset,i*.1;bob;Stroke,Color("Black"));
			--OnCommand=cmd(sleep,i*.1-.1;decelerate,.2;zoom,1);
		};
	end;
	return letters;
end;

local xVelocity = 0
local t = Def.ActorFrame{
	Def.Quad{
		InitCommand=cmd(setsize,SCREEN_WIDTH,SCREEN_HEIGHT;diffuse,Color("Black");Center);
	};
	Def.ActorFrame{
		FOV=50;
		Def.Sprite{
			Texture=THEME:GetPathB("ScreenCredits","overlay/extreme_special_ending.avi");
			InitCommand=cmd(customtexturerect,0,0,3,3;setsize,750,750;Center;texcoordvelocity,0,1.5;rotationx,-90/4*3.5;fadetop,1);
			CodeMessageCommand=function(self, params)
				if params.Name == "Start" or params.Name == "Center" then
					SCREENMAN:GetTopScreen():StartTransitioningScreen("SM_GoToPrevScreen");
				elseif params.Name == "Left" then
					xVelocity=xVelocity+.5;
				elseif params.Name == "Right" then
					xVelocity=xVelocity-.5;
				else
					SCREENMAN:SystemMessage("Unknown button: "..params.Name);
				end;
				self:texcoordvelocity(xVelocity,1.5);
			end;
		};
	}
};
t[#t+1] = getWavyText("Simply EXTREME",SCREEN_CENTER_X,SCREEN_CENTER_Y-100);
t[#t+1] = getWavyText("Coded by Rhythm Lunatic",SCREEN_CENTER_X,SCREEN_CENTER_Y);
t[#t+1] = getWavyText("Extreme theme by Beware, ported to SM5 by Inori. Simply Love by dguzek",SCREEN_RIGHT,SCREEN_CENTER_Y+100)..{
	OnCommand=cmd(x,1000;linear,10;x,-1500;queuecommand,"On");
};

return t;
