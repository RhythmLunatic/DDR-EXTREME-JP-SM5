return Def.ActorFrame{
	Def.Sprite{
		Texture=THEME:GetPathB("ScreenLogo","background/bg.png");
		InitCommand=cmd(Center);
	};
	--[[LoadActor("a")..{
		InitCommand=cmd(Center);
	};]]
	LoadActor("start")..{
		InitCommand=cmd(xy,SCREEN_CENTER_X,SCREEN_BOTTOM-70;diffuseblink;linear,0.5;effectcolor1,color(".5,.5,.5,1"));
	};
}