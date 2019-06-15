return Def.ActorFrame{
	InitCommand=function(self)
		Setup();
	end;
	LoadActor("warning")..{
		InitCommand=cmd(Center);
	};
}