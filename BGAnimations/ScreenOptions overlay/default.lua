return Def.ActorFrame{
  --[[Def.Quad{
    InitCommand=cmd(CenterX;y,SCREEN_CENTER_Y-20;setsize,640,300;diffuse,Color("Black"));
    OnCommand=cmd(linear,0.3;cropleft,1);
    OffCommand=cmd(linear,0.3;cropleft,0);
  };]]
  --[[Def.Quad{
	InitCommand=cmd(setsize,SCREEN_WIDTH/2,438;horizalign,right;x,SCREEN_CENTER_X-640/2;diffuse,color("#E0961E"));
  };]]
  LoadActor("overlay")..{
    InitCommand=cmd(CenterX;y,SCREEN_BOTTOM;valign,1;setsize,640,438);
  };
};
