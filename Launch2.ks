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
	print "Current Apoapsis is "+APOAPSIS at (0,31).
	print "Time to apo: "+ETA:APOAPSIS at (0,32).
	print "Max pitch: "+pitchmax+" Min pitch "+pitchmin at (0,35).
	preserve.
}


until ship:apoapsis >= 101000 {
	list engines in listengines.
	for eng in listengines{
		if(eng:flameout){
			stage.
			print "Staging".
			break.
		}
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
when (ETA:APOAPSIS <= 10) then{
	lock throttle to 1.
	print "Circularizing".

}.

local end to false.

//when (ship:PERIAPSIS >= 95000 and ship:apoapsis >=100000) then{
when (abs(ship:PERIAPSIS - ship:apoapsis) <= 2000) then{
	lock throttle to 0.
	print "circularization complete".
	print "Currently in a stabe orbit of "+apoapsis+ " by "+periapsis.
	set end to true.
}

until (end){
}