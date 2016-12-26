clearscreen.

lock throttle to 1.0.
lock steering to up

print "counting down:"
from{local countdown is 10.} until countdown = 0 step {set countdown to countdown -1.} do{
	print "..." + countdown.
	wait 1.
}

when ship:maxthrust = 0{
	print "Staging".
	stage.
	preserve
}.

wait until ship:altitude > 70000.