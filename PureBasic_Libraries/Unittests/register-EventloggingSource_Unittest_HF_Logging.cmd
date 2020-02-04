@echo off
set EVENTSOURCE=Unittest_HF_Logging
if %EVENTSOURCE%.==. (
    echo Please set the variable EVENTSOURCE in this script to the Eventsource you use in
    echo your programm.
    pause
) else (
    echo Register eventsoure: %EVENTSOURCE%
    echo Run the script once as administrator to register the eventsource
    pause
    eventcreate.exe /t INFORMATION /id 1 /l Application /so %EVENTSOURCE% /d "Registered eventsource"
    pause
)
