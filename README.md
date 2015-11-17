# Star Wars: The Old Republic
# "Restraining Bolt"

# IMPORTANT

While this mod makes every attempt not to screw things up, it is provided
without any warranty. No technical support is provided.

If it does screw up, please use the 'repair' option in the game's launcher
and try to use the force to choke me.  


# About the Mod

This mod will modify the game files so that the ship companion droids
(specifically C2N2 and 2VR8) will no longer use audio messages. 

Their text will continue to appear in the game chat window (if enabled).


You will need to reapply this patch if the audio files are updated after
a game update.

The mod will create backups of the original files.

This is a command line program,
as such to run it you'll need to open a command prompt.

A quick way on Windows to do this is to hold the Windows key and press R,
in the "Run" box type "cmd" and press enter.


Alternately, you can create two shortcuts to the executable.

One should be labeled "Patch".
The second should be labeled "Restore" and give the "-restore" argument.

Unfortunately you won't be able to see any messages the program displays.


If you wish to use the shortcut method, I would recommend doing the initial
run in a command window to see if there are any issues.

This software is written in Strawberry Perl and compiled with PAR::Packer.
The source is included.


# LICENSE

This software is freeware, if you make money on it - I'll be very sad and 
will try to force choke you to death.


# Commands

swtor_restrainingbolt -restore			Restore from Backup Folder
swtor_restrainingbolt -version			Show Version Number and Exit
swtor_restrainingbolt -help			Show Command List and Exit
swtor_restrainingbolt -debug			Show Debug Messages
swtor_restrainingbolt -data folder		Specify Data Folder
swtor_restrainingbolt -backup folder		Specify Backup Folder
swtor_restrainingbolt -game folder		Specify SWTOR Folder


# Usage Notes

The tool will try to locate your Star Wars: The Old Republic installation,
it does this by reading the registry.

If this fails, for whatever reason,
you can use the -game option to specify the folder.

	e.g.	
		swtor_restrainingbolt -game "D:\My Games\SWTOR"



# Backups

By default, the tool will backup assets in a folder called "SWTOR_MOD\Backup"
in the system's "TEMP" folder (whatever is defined in the "TEMP" environment
variable).

If it's not defined or accessible, it will use the current folder instead.

You can override this by using the option -backup.
	e.g.
		swtor_restrainingbolt -backup "D:\Temp" 

A backup folder will still be created, D:\Temp\SWTOR_MOD\Backup in this case.


# Data Storage

By default, the tool will store some data in a folder called "SWTOR_MOD" in
the current user's APPDATA folder under "Local". 

(The specifics are listed below under "Data File Format".)

If it's not defined or accessible, it will use the current folder instead.

You can override this by using the option -data
	e.g.
		swtor_restrainingbolt -data "D:\Temp" 

A SWTOR_MOD folder will still be created, D:\Temp\SWTOR_MOD in this case.


# Multple Switches

You can use multiple switches at the same time,
for example:

-data "D:\My Data" -game "C:\Games\SWTOR" -backup "E:\Backup"


# How It Works

The asset files are actually archives containing many small sound files.

The tool simply takes two of the asset files ("swtor_en-us_cnv_comp_chars_rep_1"
and "swtor_en-us_cnv_comp_chars_imp_1") and replaces the internal filenames 
where the ship droid names appear with XXXX.

When the game tries to play one of those sound files, it can't find it so instead
of hearing C2N2 drone on, you instead hear blissful silence instead!


example:

	cnv_location_companion_characters_multi_republic_c2n2_c2n2_98_m.wem

becomes

	cnv_location_companion_characters_multi_republic_XXXX_XXXX_98_m.wem


It gets the asset version information from the assets_swtor_main_version.txt
file in the game's "Assets" folder.


# Data File Format

Value|Comment
-----|-------
PROGRAM NAME|Not used right now
PROGRAM VERSION|Not used right now
DATA FILE|Literally "DATA FILE"
Game Installation Folder|Not used right now
Assets Patch Version|Game Asset Patch Level
Assets Data Version|Game Asset Data Level
Checksum of the Republic Asset File|MD5 Hash
Checksum of the Imperial Asset File|MD5 Hash
Patch Applied Flag|0 = No, 1 = Yes





