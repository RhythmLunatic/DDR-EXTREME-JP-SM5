local c;
local pt; --proTiming display handle
local player = Var "Player";

local JudgeCmds = {
	TapNoteScore_W1 = THEME:GetMetric( "Judgment", "JudgmentW1Command" );
	TapNoteScore_W2 = THEME:GetMetric( "Judgment", "JudgmentW2Command" );
	TapNoteScore_W3 = THEME:GetMetric( "Judgment", "JudgmentW3Command" );
	TapNoteScore_W4 = THEME:GetMetric( "Judgment", "JudgmentW4Command" );
	TapNoteScore_W5 = THEME:GetMetric( "Judgment", "JudgmentW5Command" );
	TapNoteScore_Miss = THEME:GetMetric( "Judgment", "JudgmentMissCommand" );
};

local ProtimingCmds = {
	TapNoteScore_W1 = THEME:GetMetric( "Protiming", "ProtimingW1Command" );
	TapNoteScore_W2 = THEME:GetMetric( "Protiming", "ProtimingW2Command" );
	TapNoteScore_W3 = THEME:GetMetric( "Protiming", "ProtimingW3Command" );
	TapNoteScore_W4 = THEME:GetMetric( "Protiming", "ProtimingW4Command" );
	TapNoteScore_W5 = THEME:GetMetric( "Protiming", "ProtimingW5Command" );
	TapNoteScore_Miss = THEME:GetMetric( "Protiming", "ProtimingMissCommand" );
};

local AverageCmds = {
	Pulse = THEME:GetMetric( "Protiming", "AveragePulseCommand" );
};
local TextCmds = {
	Pulse = THEME:GetMetric( "Protiming", "TextPulseCommand" );
};

local BiasCmd = THEME:GetMetric("Judgment", "JudgmentBiasCommand");

local TNSFrames = {
	TapNoteScore_W1 = 0;
	TapNoteScore_W2 = 1;
	TapNoteScore_W3 = 2;
	TapNoteScore_W4 = 3;
	TapNoteScore_W5 = 4;
	TapNoteScore_Miss = 5;
};

local tTotalJudgments = {};

local function MakeAverage( t )
	local sum = 0;
	for i=1,#t do
		sum = sum + t[i];
	end
	return sum / #t
end

local ProtimingWidth = THEME:GetMetric("Protiming", "ProtimingWidth");
assert(ProtimingWidth,"oh no");
--No need, ActiveModifiers is empty if we're not playing.
--[[local function ShowProtiming()
	if stage == "ScreenGameplay stage Demo" then
		return false
	else
		return 
	end
end;]]
local bShowProtiming = (ActiveModifiers[pname(player)]["DetailedPrecision"] == "ProTiming");
--assert(bShowProtiming ~= nil, "What the fuck???")


local showBias = (ActiveModifiers[pname(player)]["DetailedPrecision"] == "EarlyLate");

local toLoad = (SL.Global.GameMode == "ECFA") and "ECFA" or "Judgment"
local t = Def.ActorFrame {
	LoadActor(toLoad) .. {
		Name="Judgment";
		InitCommand=cmd(pause;visible,false;);
		OnCommand=THEME:GetMetric("Judgment","JudgmentOnCommand");
		ResetCommand=cmd(stopeffect;finishtweening;y,0;visible,false);
	};
	--[[
	LoadFont("Common Normal") .. {
		Name="ProtimingDisplay";
		Text="";
		InitCommand=cmd(visible,false);
		OnCommand=THEME:GetMetric("Protiming","ProtimingOnCommand");
		ResetCommand=cmd(finishtweening;stopeffect;visible,false);
	};
	--]]
	LoadActor("Deviation 1x2") .. {
		Name="Bias";
		Condition=showBias;
		InitCommand=cmd(pause;visible,false;xy,35,25;zoom,.75);
		OnCommand=THEME:GetMetric("Judgment","JudgmentBiasOnCommand");
		ResetCommand=cmd(finishtweening;stopeffect;visible,false);
	};
	
	--ProTiming Information (Text and Numbers)
	LoadFont("Combo Numbers") .. {
		Name="ProtimingDisplay";
		Text="";
		InitCommand=cmd(visible,false);
		OnCommand=THEME:GetMetric("Protiming","ProtimingOnCommand");
		ResetCommand=cmd(finishtweening;stopeffect;visible,false);
	};
	LoadFont("Common Normal") .. {
		Name="ProtimingAverage";
		Text="";
		InitCommand=cmd(visible,false);
		OnCommand=THEME:GetMetric("Protiming","AverageOnCommand");
		ResetCommand=cmd(finishtweening;stopeffect;visible,false);
	};
	LoadFont("Common Normal") .. {
		Name="TextDisplay";
		Text=THEME:GetString("Protiming","MS");
		InitCommand=cmd(visible,false);
		OnCommand=THEME:GetMetric("Protiming","TextOnCommand");
		ResetCommand=cmd(finishtweening;stopeffect;visible,false);
	};
	Def.Quad {
		Name="ProtimingGraphBG";
		InitCommand=cmd(visible,false;y,32;zoomto,ProtimingWidth,16);
		ResetCommand=cmd(finishtweening;diffusealpha,0.8;visible,false);
		OnCommand=cmd(diffuse,Color("Black");diffusetopedge,color("0.1,0.1,0.1,1");diffusealpha,0.8;shadowlength,2;);
	};
	Def.Quad {
		Name="ProtimingGraphWindowW3";
		InitCommand=cmd(visible,false;y,32;zoomto,ProtimingWidth-4,16-4);
		ResetCommand=cmd(finishtweening;diffusealpha,1;visible,false);
		OnCommand=cmd(diffuse,GameColor.Judgment["JudgmentLine_W3"];);
	};
	Def.Quad {
		Name="ProtimingGraphWindowW2";
		InitCommand=cmd(visible,false;y,32;zoomto,scale(PREFSMAN:GetPreference("TimingWindowSecondsW2"),0,PREFSMAN:GetPreference("TimingWindowSecondsW3"),0,ProtimingWidth-4),16-4);
		ResetCommand=cmd(finishtweening;diffusealpha,1;visible,false);
		OnCommand=cmd(diffuse,GameColor.Judgment["JudgmentLine_W2"];);
	};
	Def.Quad {
		Name="ProtimingGraphWindowW1";
		InitCommand=cmd(visible,false;y,32;zoomto,scale(PREFSMAN:GetPreference("TimingWindowSecondsW1"),0,PREFSMAN:GetPreference("TimingWindowSecondsW3"),0,ProtimingWidth-4),16-4);
		ResetCommand=cmd(finishtweening;diffusealpha,1;visible,false);
		OnCommand=cmd(diffuse,GameColor.Judgment["JudgmentLine_W1"];);
	};
	Def.Quad {
		Name="ProtimingGraphUnderlay";
		InitCommand=cmd(visible,false;y,32;zoomto,ProtimingWidth-4,16-4);
		ResetCommand=cmd(finishtweening;diffusealpha,0.25;visible,false);
		OnCommand=cmd(diffuse,Color("Black");diffusealpha,0.25);
	};
	Def.Quad {
		Name="ProtimingGraphFill";
		InitCommand=cmd(visible,false;y,32;zoomto,0,16-4;horizalign,left;);
		ResetCommand=cmd(finishtweening;diffusealpha,1;visible,false);
		OnCommand=cmd(diffuse,Color("Red"););
	};
	Def.Quad {
		Name="ProtimingGraphAverage";
		InitCommand=cmd(visible,false;y,32;zoomto,2,7;);
		ResetCommand=cmd(finishtweening;diffusealpha,0.85;visible,false);
		OnCommand=cmd(diffuse,Color("Orange");diffusealpha,0.85);
	};
	Def.Quad {
		Name="ProtimingGraphCenter";
		InitCommand=cmd(visible,false;y,32;zoomto,2,16-4;);
		ResetCommand=cmd(finishtweening;diffusealpha,1;visible,false);
		OnCommand=cmd(diffuse,Color("White");diffusealpha,1);
	};
	
	--[[LoadFont("Common Normal")..{
		Text=string.format("W1 Window: %.3f",PREFSMAN:GetPreference("TimingWindowSecondsW1"));
		InitCommand=cmd(addy,100);
	};]]
	

	InitCommand = function(self)
		c = self:GetChildren();
	end;

	JudgmentMessageCommand=function(self, param)
		if param.Player ~= player then return end;
		if param.HoldNoteScore then return end;

		local iNumStates = c.Judgment:GetNumStates();
		local iFrame = TNSFrames[param.TapNoteScore];

		if not iFrame then return end
		if iNumStates == 12 then
			iFrame = iFrame * 2;
			if not param.Early then
				iFrame = iFrame + 1;
			end
		end
		
		local fTapNoteOffset = param.TapNoteOffset;
		if param.HoldNoteScore then
			fTapNoteOffset = 1;
		else
			fTapNoteOffset = param.TapNoteOffset; 
		end
		
		if param.TapNoteScore == 'TapNoteScore_Miss' then
			fTapNoteOffset = 1;
			bUseNegative = true;
		else
-- 			fTapNoteOffset = fTapNoteOffset;
			bUseNegative = false;
		end;
		
		if fTapNoteOffset ~= 1 then
			-- we're safe, you can push the values
			tTotalJudgments[#tTotalJudgments+1] = math.abs(fTapNoteOffset);
--~ 			tTotalJudgments[#tTotalJudgments+1] = bUseNegative and fTapNoteOffset or math.abs( fTapNoteOffset );
		end

		--c.Judgment:playcommand("Reset");
		self:playcommand("Reset");
		
		if showBias then
			---XXX: don't hardcode this
			if param.TapNoteScore ~= 'TapNoteScore_W1' and
				param.TapNoteScore ~= 'TapNoteScore_Miss' then
				local late = fTapNoteOffset and (fTapNoteOffset > 0);
				c.Bias:visible(true);
				c.Bias:setstate( late and 1 or 0 );
				BiasCmd(c.Bias);
			else
				c.Bias:visible(false);
			end
		end

		c.Judgment:visible( true );
		c.Judgment:setstate( iFrame );
		JudgeCmds[param.TapNoteScore](c.Judgment);

		if bShowProtiming then
			c.ProtimingDisplay:visible( bShowProtiming );
			c.ProtimingDisplay:settextf("%i",fTapNoteOffset * 1000);
			ProtimingCmds[param.TapNoteScore](c.ProtimingDisplay);
			
			c.ProtimingAverage:visible( bShowProtiming );
			c.ProtimingAverage:settextf("%.2f%%",clamp(100 - MakeAverage( tTotalJudgments ) * 1000 ,0,100));
			AverageCmds['Pulse'](c.ProtimingAverage);
			
			c.TextDisplay:visible( bShowProtiming );
			TextCmds['Pulse'](c.TextDisplay);
			
			c.ProtimingGraphBG:visible( bShowProtiming );
			c.ProtimingGraphUnderlay:visible( bShowProtiming );
			c.ProtimingGraphWindowW3:visible( bShowProtiming );
			c.ProtimingGraphWindowW2:visible( bShowProtiming );
			c.ProtimingGraphWindowW1:visible( bShowProtiming );
			c.ProtimingGraphFill:visible( bShowProtiming );
			c.ProtimingGraphFill:finishtweening();
			c.ProtimingGraphFill:decelerate(1/60);
			c.ProtimingGraphFill:zoomtowidth( clamp(
					scale(
					fTapNoteOffset,
					0,PREFSMAN:GetPreference("TimingWindowSecondsW3"),
					0,(ProtimingWidth-4)/2),
				-(ProtimingWidth-4)/2,(ProtimingWidth-4)/2)
			);
			c.ProtimingGraphAverage:visible( bShowProtiming );
			c.ProtimingGraphAverage:zoomtowidth( clamp(
					scale(
					MakeAverage( tTotalJudgments ),
					0,PREFSMAN:GetPreference("TimingWindowSecondsW3"),
					0,ProtimingWidth-4),
				0,ProtimingWidth-4)
			);
			c.ProtimingGraphCenter:visible( bShowProtiming );
			(cmd(sleep,2;linear,0.5;diffusealpha,0))(c.ProtimingGraphBG);
			(cmd(sleep,2;linear,0.5;diffusealpha,0))(c.ProtimingGraphUnderlay);
			(cmd(sleep,2;linear,0.5;diffusealpha,0))(c.ProtimingGraphWindowW3);
			(cmd(sleep,2;linear,0.5;diffusealpha,0))(c.ProtimingGraphWindowW2);
			(cmd(sleep,2;linear,0.5;diffusealpha,0))(c.ProtimingGraphWindowW1);
			(cmd(sleep,2;linear,0.5;diffusealpha,0))(c.ProtimingGraphFill);
			(cmd(sleep,2;linear,0.5;diffusealpha,0))(c.ProtimingGraphAverage);
			(cmd(sleep,2;linear,0.5;diffusealpha,0))(c.ProtimingGraphCenter);
		end;
				

	end;
};

return t;
