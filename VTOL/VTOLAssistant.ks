clearscreen.

/////////////////SETUP////////////////////
local targetAlt to 700.
local tstatus to 36.
print "VTOL Assistant" at (0,tstatus).
SAS on.
set sasmode to "STABILITYASSIST".
brakes on.
set throttle to 0.
copy lib_navball from 0.
run lib_navball.


list engines in listengines.
for eng in listengines{
	set eng:thrustlimit to 0.
}

local basictl to 50.
lock throttle to 1.
for eng in listengines{
	set eng:thrustlimit to 10.
}

lock lpitch to pitch_for(ship).
lock lyaw to compass_for(ship).
lock lroll to roll_for(ship).
/////////////////////////////////////////////



////////////  PITCH SETUP   ////////////////
local pitch_setpoint to 0.
lock p to pitch_setpoint-lpitch.

local p_kp to .04.
local p_ki to .015.
local p_kd to .035.
local p_I to 0.
local p_D to 0.
local p_p0 to P.
local p_deadzone to .1.

lock dpitch to p_kp*P+p_ki*p_I+p_kd*p_d.

set p_t0 to time:seconds.
////////////////////////////////////////////




////////////  Roll SETUP   ////////////////
local Roll_setpoint to 0.
lock r to roll_setpoint-lroll.

local r_kp to .04.
local r_ki to .01.
local r_kd to .02.
local r_I to 0.
local r_D to 0.
local r_p0 to P.
local r_deadzone to .5.

lock droll to r_kp*r+r_ki*r_I+r_kd*r_d.

set r_t0 to time:seconds.
////////////////////////////////////////////





///////  Forward Speed Setup   ////////////
local fwspeed_setpoint to 0.
lock f to fwspeed_setpoint-ship:groundspeed.

local f_kp to .12.
local f_ki to .02.
local f_kd to .05.
local f_I to 0.
local f_D to 0.
local f_p0 to P.

lock dfwspeed to f_kp*f+p_ki*f_I+f_kd*f_d.

set f_t0 to time:seconds.
///////////////////////////////////////////




until(false){
	

	////////  PITCH CONTROL   /////////	

	set p_dt to Time:seconds-p_t0.

	print ship:partstagged("fr")[0]:thrustlimit at (32, 16).
	print ship:partstagged("fl")[0]:thrustlimit at (26, 16).
	print ship:partstagged("br")[0]:thrustlimit at (32, 24).
	print ship:partstagged("bl")[0]:thrustlimit at (26, 24).

	print "Pitch "+lpitch at (0,tstatus-4).
	print "Yaw " + lyaw at (0, tstatus -3).
	print "Roll "+lroll at (0, tstatus -2).
	print "Change in pitch: "+dpitch at (0, tstatus - 5).
	if(p_dt>0 and abs(lpitch)>p_deadzone){ 
		set p_I to p_I+P *p_dt.
		set p_D to (P-p_P0) / p_dt.
		set ship:partstagged("fr")[0]:thrustlimit to ship:partstagged("fr")[0]:thrustlimit+dpitch.
		set ship:partstagged("fl")[0]:thrustlimit to ship:partstagged("fl")[0]:thrustlimit+dpitch.
		set ship:partstagged("br")[0]:thrustlimit to ship:partstagged("br")[0]:thrustlimit-dpitch.
		set ship:partstagged("bl")[0]:thrustlimit to ship:partstagged("bl")[0]:thrustlimit-dpitch.
		set p_p0 to P.
		set p_t0 to Time:seconds.
	}
	////////////////////////////////////
	


	////////  FW Speed CONTROL   /////////	

	set f_dt to Time:seconds-f_t0.

	if(f_dt>0 and ship:altitude>100){
		set f_I to f_I+P *f_dt.
		set f_D to (f-f_P0) / f_dt.
		set pitch_setpoint to max(min(30, pitch_Setpoint+dfwspeed),-30)*-1.
		set f_p0 to P.
 		set f_t0 to Time:seconds.
	}

	print "Target pitch: "+pitch_setpoint at (0, tstatus-6).
	////////////////////////////////////


	
	////////  Roll CONTROL   /////////	

	set r_dt to Time:seconds-r_t0.


	print "Change in Roll: "+droll at (0, tstatus - 7).
	if(r_dt>0 and abs(lroll)>r_deadzone){ 
		set r_I to r_I+r *r_dt.
		set r_D to (r-r_P0) / r_dt.
		set ship:partstagged("fr")[0]:thrustlimit to ship:partstagged("fr")[0]:thrustlimit-dpitch.
		set ship:partstagged("fl")[0]:thrustlimit to ship:partstagged("fl")[0]:thrustlimit+dpitch.
		set ship:partstagged("br")[0]:thrustlimit to ship:partstagged("br")[0]:thrustlimit-dpitch.
		set ship:partstagged("bl")[0]:thrustlimit to ship:partstagged("bl")[0]:thrustlimit+dpitch.
		set r_p0 to r.
		set r_t0 to Time:seconds.
	}
	////////////////////////////////////


	/////// ALTITUDE CONTROL  ///////
	local alt to ship:altitude.
	local vspeed to ship:verticalspeed.
	if((vspeed < 2) and (targetalt > alt)){
		for eng in listengines{
			set eng:thrustlimit to eng:thrustlimit+.5.
		}
	} else if((vspeed > 10 and targetalt > alt) or (vspeed > 2 and targetalt < alt)){
		for eng in listengines{
			set eng:thrustlimit to eng:thrustlimit-.5.
		}
	}
	//////////////////////////////////


	//if(ship:oxidizer<.2){
	//	break.
	//}
	
	wait .001.
}



//Set all engines to 100% before exiting
for eng in listengines{
	set eng:thrustlimit to 100.
}