# OBS JW Meeting Timer

This is a Lua script for OBS Studio that sets a text source as a timer for the JW meeting.  

**Configuration**  
The first thing is to create the text sources for the script:
- one for the countdown 
- one for the delay time

I have created a default scene used by me in the file  TimerScene.json that can be easily imported on OBS.
Or you can create your own text sources with your preferred style.

Configure it on the script using the Timer source and Delay Source input.

I suggest to put a background. In my TimerScene file i have used the color of Zoom interface as background.

**Use**

Click on one of the button to start the timer with the prefixed and mostly used minutes during the meeting.

If you prefer a custom time use the slider and the set button.

Play/Pause button can be used for play or pause the timer

The Stop button is useful to reset the timer to 00:00.
