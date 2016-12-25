clearscreen.
lock throttle to 0.
lock steering to retrograde.
print "Pointing to retrograde".
wait 5.
lock throttle to 1.
print "Buring retrograde".
local currenttime to Time:seconds.
local previoustime to Time:seconds.
local powerland to false.

when (ship:periapsis < -60000) then{
	lock throttle to 0.
	print "On inpact tragetory with sphere of influence".
}



when (ship:altitude < 1500 and ship:verticalspeed <-10) then{
	set chutes to true.
	print "parachute deployed".
}.
if(powerland){
	local sp to SHIP:VELOCITY:SURFACE:MAG.
	if(sp > 250){
		lock throttle to throttle +.25.
		set brakes to true.
	}
	if(sp < 200){
		lock throttle to throttle -.1.
	}
	if(chutes=false){
		//preserve.
	}
}

until(chutes){
	if(powerland=false or true){
		if(ship:altitude < 5000 and SHIP:VELOCITY:SURFACE:MAG > 250){
			set powerland to true.
		}	
	}

	if(ship:maxthrust = 0 and ship:liquidfuel > 0){
		stage.
	}	
}
set legs to true.
until (ship:altitude < 500 and ship:verticalspeed < -5){
}