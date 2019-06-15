local outColor = color("#00326B")

return Def.ActorFrame{
	InitCommand=function(self)
		Setup();
	end;
	LoadActor("bg")..{ 
		InitCommand=cmd(Center;);
	};
}
