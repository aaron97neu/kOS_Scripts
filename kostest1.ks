clearscreen.

set sasmode to "STABILITYASSIST".
lock steering to up.
lock throttle to 1.0.
local count to 0.

print "counting down:".
from {local countdown is 3.} until countdown = 0 step {set countdown to countdown -1.} do {
	print "..." + countdown.
	wait 1.
}

when maxthrust = 0 then {
	if(count<2){
		print "Staging".
		stage.
		preserve.
		set count to count + 1.
	}
}

until ship:apoapsis > 70000 {
	

}
when (ship:altitude < 10000) then{
	stage.
	print "parachute deployed".
}
