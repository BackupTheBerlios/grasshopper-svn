#!/bin/sh

#
# This CGI-Skript will read and set the LEDs on a icnova base.
# To be used via an HTML-Browser
#
# (C) 2008 by Benjamin Tietz <benjamin.tietz@in-circuit.de>
# licensed under the terms of the GPL
#

cat <<"HEAD"
Content-Type: text/html

<html>
<head>
<title> LEDs on ICnova Base </title>
</head>
<body>
<h2> These are the LEDs on your ICnova Base </h2>
<p> You can set the leds, by checking their corresponding checkbox and click
submit. </p>
<p> Each LED with a checked checkbox is enabled on your board. LED1 is used
by the kernel as heartbeat and flashing autonomous, so it isn't displayed here.
</p>
<form>
<table>
	<tr><th> LED nr </th><th>On</th></tr>
HEAD

for i in 2 3 4 5 6 7 8; do
	if (echo $QUERY_STRING | grep "led$i" >> /dev/null ); then
		echo 255 >> /sys/class/leds/led$i:green/brightness
	else
		echo 0 >> /sys/class/leds/led$i:green/brightness
	fi
	echo -n "<tr><td> $i, green </td> <td><input type=\"checkbox\" name=\"led\" value=\"led$i\""
	if ! ( cat /sys/class/leds/led$i:green/brightness | grep 0 ); then
		echo -n " checked"
	fi
	echo " /></td></tr>"
done

cat <<"FOOTER"
</table>
<input type="submit">
</form>
</body>
</html>
FOOTER

