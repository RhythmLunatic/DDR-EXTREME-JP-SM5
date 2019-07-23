-- gameplay score frame
local scoreFrame = "normal"

-- todo: show oni on life meter battery as well
if GAMESTATE:GetPlayMode() == 'PlayMode_Oni' then
	scoreFrame = "oni"
end

if GAMESTATE:IsExtraStage() or GAMESTATE:IsExtraStage2() then scoreFrame = "extra" end

return Def.ActorFrame{
	LoadActor(scoreFrame);
	--[[Def.Quad{
		InitCommand=cmd(setsize,SCREEN_WIDTH,10;horizalign,left;xy,-SCREEN_CENTER_X,58;zoomx,0;diffuse,color(".5,.5,.5,1"));
		OnCommand=cmd(linear,10;zoomx,1);
	}]]
		Def.SongMeterDisplay{
			StreamWidth=_screen.w,
			Stream=Def.Quad{ 
				InitCommand=cmd(zoomy,10; diffuse,color(".5,.5,.5,1");y,58)
			}
		},
};