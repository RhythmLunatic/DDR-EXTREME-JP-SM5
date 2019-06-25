return Def.ActorFrame{
	InitCommand=function(self)
		InitializeSimplyLove();
	end;
	LoadActor("warning")..{
		InitCommand=cmd(Center);
	};
}