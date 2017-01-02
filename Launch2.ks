clearscreen.

set sasmode to "STABILITYASSIST".
print sasmode +" activated".
local cHeadComp to 90.
local cHeadPitch to 90.
lock steering to heading(cHeadcomp,cheadpitch).
lock throttle to 1.0.
local count to 0.
local pitchmax to 75.
local pitchmin to 65.
local currenttime to Time:SECONDS.
local previoustime to Time:SECONDS.

print "Counting Down:".
from {local countdown is 3.} until countdown = 0 step {set countdown to countdown -1.} do {
	print "..." + countdown.
	wait .5.
}

stage.

local pitchud to 33.
local timepos to 34.
when (true) then{
	print "Current heading: "+cheadcomp+","+cheadpitch at (0,30).
	print "Current Apoapsis is "+round(APOAPSIS) at (0,31).
	print "Time to apo: "+round(ETA:APOAPSIS,2) at (0,32).
	print "Max pitch: "+pitchmax+" Min pitch "+pitchmin at (0,35).
	preserve.
}
local twr to 0.
local end to false.
local thrott to 1.
lock throttle to thrott.
until ship:apoapsis >= 101000 {
	list engines in listengines.
	for eng in listengines{
		if(eng:flameout){
			//wait .5.
			stage.
			print "Staging".
			break.
		}
	}
	set twr to (availablethrust*thrott)/(mass*10).
	print "Mass: "+round(mass,2) at (0,28).
	print "available thrust: "+round(availablethrust) at (0,27).
	print "current thrust: "+round(availablethrust*thrott) at (0,26).
	print "TWR: "+round(twr,2) at (0,29).
	
	if(ship:altitude < 50000){
		if(twr > 1.8){
			set thrott to max(min((thrott - .01),1),0). 
		}else if(twr < 1.3){
			set thrott to max(min((thrott + .01),1),0).
		}
	}else{
		set thrott to 1.
	}


	if(SHIP:VELOCITY:SURFACE:MAG > 50 and SHIP:VELOCITY:SURFACE:MAG < 100){
		local cHeadComp to 90.
		local cHeadPitch to 80.
		LOCK STEERING TO HEADING(cHeadcomp,cheadpitch).
	}
	else if(SHIP:VELOCITY:SURFACE:MAG >100){
		if(SHIP:VELOCITY:SURFACE:MAG < 200){
			local cHeadComp to 90.
			set cHeadPitch to 75.
			lock steering to heading(cheadcomp,cheadpitch).
		}
		else{
		
			set currentTime to Time:seconds.
			print (currenttime-previoustime) at (0,timepos).
			if(abs(currentTime - previousTime)> 2.5 and pitchmin > 0){
				set pitchmax to pitchmax-1.
				set pitchmin to pitchmin-1.
				set previoustime to time:seconds.
				set currenttime to time:seconds.
				}	


			if((ETA:APOAPSIS < 55 and cHeadPitch <=pitchmax) or cheadpitch < pitchmin){
				local cHeadComp to 90.
				set cHeadPitch to cHeadpitch + 1.
				LOCK STEERING TO HEADING(cHeadcomp,cHeadpitch).
				print "Pitching up  " at (0,pitchud).
			}else if((ETA:APOAPSIS > 65 and cHeadpitch >=pitchmin) or cheadpitch > pitchmax){
				local cHeadComp to 90.
				set cHeadPitch to cHeadpitch - 1.
				LOCK STEERING TO HEADING(cHeadcomp,cHeadpitch).
				print "Pitching down" at (0,pitchud).
			}
			
		}
	}
	

}.
print "Orbital injection complete.".


lock throttle to 0.
lock steering to prograde.

set circnode to Node(time:seconds+eta:apoapsis,0,0,0).
add circnode.
until (circnode:orbit:periapsis > 99000){
	set circnode:prograde to circnode:prograde+1.
}
print "Adding curcularization manuver node.". 
print "Required deltaV: "+round(circnode:deltav:mag)+"m/s eta: "+round(circnode:eta)+"s".

set burntime to circnode:deltav:mag/(ship:maxthrust/ship:mass). //Should replace with tsiolkovsky's exquation eventually.
print "estimated burn time: "+round(burntime)+"s".

wait until ship:altitude >= 70000.

set nodedir to circnode:deltav.
lock steering to nodedir.

//wait until abs(np:pitch-facingpitch) < .15 and abs(np:yaw - facing:yaw) < .15. //not needed b/c starting burn befroe facing will make the ship point faster because of engine gimbal

until circnode:eta <= (burntime/2)+((burntime/2)*.1){
	print "Circulization burn starting in T-"+round(circnode:eta-(burntime/2)+((burntime/2)*.1),2) at (0,25).
}

set thrott to 0.
lock throttle to thrott.

set done to false.

set dv0 to circnode:deltav.

until done{
	list engines in listengines.
	for eng in listengines{
              if(eng:flameout){
                      stage.
                      print "Staging".
                      break.
              }
	}
	

	set maxaccel to max(ship:maxthrust,.001)/ship:mass.
	set thrott to min(circnode:deltav:mag/max(maxaccel,.001),1).
	print "current throttle: "+thrott at (0,24).
	if(vdot(dv0, circnode:deltav) < 0){
		print "Circulization complete. Remaining DeltaV: "+round(circnode:deltav:mag,1)+"m/s, vdot: "+round(vdot(dv0, circnode:deltav),1).
		lock throttle to 0.
		break.

	}
	if(circnode:deltav:mag < .1){
		print "Finalizing circulization. Remaining DeltaV: "+round(circnode:deltav:mag,1)+"m/s, vdot: "+round(vdot(dv0, circnode:deltav),1).
		wait until vdot(dv0, circnode:deltav) < .5.
		lock throttle to 0.
		print "Circulization complete. Remaining DeltaV: "+round(circnode:deltav:mag,1)+"m/s, vdot: "+round(vdot(dv0, circnode:deltav),1).
		set done to true.

	}

}
remove circnode.

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
