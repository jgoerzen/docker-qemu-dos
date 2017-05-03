@ECHO OFF
rem ----------------------------------------------------------------------------
rem Basic Settings
rem ----------------------------------------------------------------------------

SET DOSDIR=C:\FDOS
SET LANG=EN
SET TZ=UTC
SET PATH=%dosdir%\BIN

SET PATH=%PATH%;C:\NETWORK\MTCP;C:\SSH2DOS;C:\NETWORK\APPS;
SET PATH=%PATH%;C:\UTIL\PKZIP;C:\UTIL\CSDPMI7B\BIN;C:\UTIL\PEDIT;C:\UTIL\VC;

if exist %dosdir%\LINKS\NUL SET PATH=%path%;%dosdir%\LINKS
SET NLSPATH=%dosdir%\NLS
SET HELPPATH=%dosdir%\HELP
SET TEMP=%dosdir%\TEMP
SET TMP=%TEMP%
SET BLASTER=A220 I5 D1 H5 P330
SET DIRCMD=/P /OGN /Y
SET COPYCMD=/-Y

set WATTCP.CFG=%dosdir%
set MTCPCFG=%dosdir%\MTCP.CFG

rem ---------------------------------------------------
rem That's all we need to run FreeDOS without drivers.
IF "%config%"=="2" GOTO END
rem ---------------------------------------------------

rem ---------------------------------------------------
rem Additional settings for all other options:
rem ---------------------------------------------------

rem Advanced Power Management in VirtualBox is recommended.
LH FDAPM APMDOS

rem IF EXIST %DOSDIR%\BIN\DOSLFN.COM LH DOSLFN
rem NLSFUNC %dosdir%\BIN\COUNTRY.SYS
rem DISPLAY CON=(EGA),858,2)
rem MODE CON CP PREP=((858) %dosdir%\CPI\EGA.CPX)
rem KEYB US,858,%dosdir%\bin\keyboard.sys
rem CHCP 858
rem MKEYB UK

rem MOUSE
rem CTMOUSE

REM If you chose DR-DOS EMM386 in FDCONFIG.SYS, add
rem C:\UTIL\DRDOS\DREMM386.EXE PIC=ON

IF "%config%"=="1" GOTO FREEDOS

LH SHARE

IF "%config%"=="3" GOTO TCPIP
IF "%config%"=="4" GOTO NETBEUI
IF "%config%"=="5" GOTO IPX
IF "%config%"=="6" GOTO NWCLIENT


REM ----------------------------------------------------------------------------
:FREEDOS
REM ----------------------------------------------------------------------------

rem Load the CD-ROM/DVD driver
rem DEVLOAD /H /Q %dosdir%\BIN\UDVD2.SYS /D:FDCD0001
rem SHSUCDX /QQ /D3
rem LH SHSUCDHD /QQ /F:FDBOOTCD.ISO
rem DEVLOAD /H /Q %dosdir%\BIN\UIDE.SYS /H /D:FDCD0001 /S5
rem SHSUCDX /QQ /~ /D:?SHSU-CDR,D /D:?SHSU-CDH,D /D:?FDCD0001,D /D:?FDCD0002,D /D:?FDCD0003,D
rem SHSUCDX /D

rem Load a packet driver
LH C:\FDOS\NETWORK\PCNTPK INT=0x60
GOTO END

rem -------------------------------------------
:TCPIP
rem -------------------------------------------

SET PATH=%PATH%;C:\NET

rem Change PROTOCOL.INI:
C:\UTIL\INIFILE\INIFILE.COM C:\NET\PROTOCOL.INI [network.setup] transport=tcpip,TCPIP
C:\UTIL\INIFILE\INIFILE.COM C:\NET\PROTOCOL.INI [network.setup] lana0=PC_CARD,1,tcpip
rem Change SYSTEM.INI:
C:\UTIL\INIFILE\INIFILE.COM C:\NET\SYSTEM.INI [network drivers] transport=tcpdrv.dos,nemm.dos,dis_pkt9.dos

LH C:\NET\net initialize
C:\NET\netbind.com
rem LH C:\NET\umb.com
C:\NET\tcptsr.exe
C:\NET\tinyrfc.exe
rem LH C:\NET\nmtsr.exe
rem C:\NET\emsbfr.exe
rem C:\NET\DNR.EXE
LH C:\NET\net start
GOTO END


rem -------------------------------------------
:NETBEUI
rem -------------------------------------------

SET PATH=%PATH%;C:\NET

rem Change PROTOCOL.INI:
C:\UTIL\INIFILE\INIFILE.COM C:\NET\PROTOCOL.INI [network.setup] transport=ms$netbeui,MS$NETBEUI
C:\UTIL\INIFILE\INIFILE.COM C:\NET\PROTOCOL.INI [network.setup] lana0=PC_CARD,1,ms$netbeui
rem Change SYSTEM.INI:
C:\UTIL\INIFILE\INIFILE.COM C:\NET\SYSTEM.INI [network drivers] transport=ndishlp.sys,*netbeui,dis_pkt9.dos

LH C:\NET\net start
GOTO END


rem -------------------------------------------
:IPX
rem -------------------------------------------

SET PATH=%PATH%;C:\NET

rem Change PROTOCOL.INI:
C:\UTIL\INIFILE\INIFILE.COM C:\NET\PROTOCOL.INI [network.setup] transport=ms$nwlink,MS$NWLINK
C:\UTIL\INIFILE\INIFILE.COM C:\NET\PROTOCOL.INI [network.setup] lana0=PC_CARD,1,ms$nwlink
rem Change SYSTEM.INI:
C:\UTIL\INIFILE\INIFILE.COM C:\NET\SYSTEM.INI [network drivers] transport=ndishlp.sys

LH C:\NET\net initialize
C:\NET\nwlink
rem Load a packet driver additionally
LH C:\FDOS\NETWORK\PCNTPK INT=0x60
GOTO END


rem -------------------------------------------
:NWCLIENT
rem -------------------------------------------

SET PATH=%PATH%;C:\NETWORK\NWCLIENT
LH C:\NETWORK\NWCLIENT\LSL.COM
LH C:\NETWORK\NWCLIENT\PCNTNW.COM
LH C:\NETWORK\NWCLIENT\ODIPKT.COM 0 96
GOTO END


rem -------------------------------------------
:END
rem -------------------------------------------

SET AUTOFILE=%0
SET CFGFILE=C:\FDCONFIG.SYS
alias reboot=fdapm warmboot
alias reset=fdisk /reboot
alias halt=fdapm poweroff
alias shutdown=fdapm poweroff
alias cfg=pedit %cfgfile%
alias auto=pedit %0
alias mc=vc
alias ls=dir

set OS_NAME=FreeDOS
set OS_VERSION=1.2

rem Start DHCP client and show IPs:
echo.
IF NOT "%config%"=="2" IF NOT "%config%"=="3" C:\UTIL\DDHCP\DDHCP /W /M
IF "%config%"=="3" C:\UTIL\DDHCP\DDHCP.COM /W /M >NUL 
IF "%config%"=="3" C:\NET\IPCONFIG C:\NET

rem IF "%config%"=="3" type C:\NETWORK\MSC-TCP.TXT
IF "%config%"=="4" type C:\NETWORK\MSC-BEUI.TXT
IF "%config%"=="5" type C:\NETWORK\MSC-IPX.TXT
IF "%config%"=="6" type C:\NETWORK\NWCLIENT.HLP

rem Not loading fdnet.bat because not all configurations 
rem need a packet driver and we use DDHCP.COM, not DHCP.EXE.
rem if exist %dosdir%\bin\fdnet.bat call %dosdir%\bin\fdnet.bat start

if exist %dosdir%\bin\welcome.bat call %dosdir%\bin\welcome.bat
D:\BOOTUP
