# Star Wars: The Old Republic
# "Restraining Bolt"

# IMPORTANT

While this mod makes every attempt not to screw things up, it is provided without any warranty. No technical support is provided.

If it does screw up, please use the 'repair' option in the game's launcher and try to use the force to choke me.  


# About the Mod

This mod will modify the game files so that the ship companion droids (specifically C2N2 and 2VR8) will no longer use audio messages. 

Their text will continue to appear in the game chat window (if enabled).


You will need to reapply this patch if the audio files are updated after a game update.

The software will create backups of the original files.  (Unless ```-nobackup`` is specified.)

This is a command line program, as such to run it you'll need to open a command prompt.

A quick way on Windows to do this is to hold the Windows key and press R, in the "Run" box type "cmd" and press enter.


Alternately, you can create two shortcuts to the executable.

One should be labeled "Patch".
The second should be labeled "Restore" and given the "-restore" argument.

Unfortunately you won't be able to see any messages the program displays, although you could add ``` > %homepath%\Documents\restraining_bolt.txt``` to the shortcut's path as a parameter.


If you wish to use the shortcut method, I would recommend doing the initial
run in a command window to see if there are any issues.

This software is written in Strawberry Perl and compiled with PAR::Packer.
The source is included.


# LICENSE

This software is freeware, if you make money on it - I'll be very sad and  will try to force choke you to death.


# Commands

Argument|Description
--------|-----------
-restore|Restore from Backup Folder
-nobackup|Don't Make Backup Copies (*)
-nodatafile|Don't Make/Update a Data File (*)
-version|Show Version Number and Exit
-help|Show Command List and Exit
-debug|Show Debug Messages
-trace|Show Debug Trace Messages (implies -debug)
-data folder|Specify Data Folder
-backup folder|Specify Backup Folder
-game folder|Specify SWTOR Folder
-debug_nopatch|Don't actually update the asset file (**)


(*)	Not recommended

(**) Not recommended for general use.  This is for debugging purposes where it will go through the motions of patching the asset file (and report that it has done so) but will not actually write to it.    It is largely useless without -trace.     

# Usage Notes

The tool will try to locate your Star Wars: The Old Republic installation, it does this by reading the registry.

The registry value it is lookign for is ```Install Dir```. 
The search order of keys is as follows:

* ```HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\BioWare\Star Wars-The Old Republic``` 
* ```HKEY_LOCAL_MACHINE\SOFTWARE\BioWare\Star Wars-The Old Republic```

If this fails, for whatever reason, you can use the -game option to specify the folder.   Unless ```-nodata``` is used, it will remember the folder on subsequent runs.


e.g.	
```
swtor_restrainingbolt -game "D:\My Games\SWTOR"
```


# Backups

By default, the tool will backup assets in a folder called "SWTOR_MOD\Backup" in the system's "TEMP" folder (whatever is defined in the "TEMP" environment variable).

If it's not defined or accessible, it will use the current folder instead.

You can override this by using the option ```-backup```.

e.g.
```
swtor_restrainingbolt -backup "D:\Temp" 
```

A backup folder will still be created, D:\Temp\SWTOR_MOD\Backup in this case.

Once you specify a backup folder (and unless you are using the ```-nodata``` option), the program will remember the location on subsequent runs and operations.


# Data Storage

By default, the tool will store some data in a folder called "SWTOR_MOD" in the current user's APPDATA folder under "Local". 

(The specifics are listed below under "Data File Format".)

If it's not defined or accessible, it will use the current folder instead.

You can override this by using the option ```-data```

e.g.
```
swtor_restrainingbolt -data "D:\Temp" 
```

A SWTOR_MOD folder will still be created, D:\Temp\SWTOR_MOD in this case.

If you specify ```-nodata```, a data file will not be created, used or updated.    (If it already exists, it will not delete it.).    Obviously, specifying ```-data``` and ```-nodata``` at the same time means that ```-data``` is ignored.


# Multple Switches

You can use multiple switches at the same time, for example:

```
swtor_restrainingbolt -data "D:\My Data" -game "C:\Games\SWTOR" -backup "E:\Backup"
```

# Debugging and Troubleshooting

The switch ```-debug``` will enable debug level messages.    Any DEBUG messages will be prefixed with "[DEBUG]" as shown in this sample:

```
Restraining Bolt v201511181736
Star Wars: The Old Republic (Ship Droid Mod)

[DEBUG] Attempting to read data file at 'C:\Users\lt\AppData\Local\SWTOR_MOD\swtor_restrainingbolt.dat'
[DEBUG] Checking stored backup root
WARNING: Game location not detected or specified, using current folder.
[DEBUG] '.' is the current folder.
[DEBUG] Using '.' as the location for Star Wars: The Old Republic.
[DEBUG] Using 'C:\Source\swtor_restrainingbolt\Backup\Backup' for the backup folder.
[DEBUG] Using 'Assets\assets_swtor_main_version.txt' for the asset version.
```

The switch ```-trace``` shows debug level messages and extra debug messages from function calls.   Trace level messages are prefixed with "[TRACE]" as shown in the following sample.   When compared with the above sample you can see how much more detail is shown.


```
Restraining Bolt v201511181736
Star Wars: The Old Republic (Ship Droid Mod)

[TRACE] Building Data File Path
[TRACE] Using Default Data File Path
[DEBUG] Attempting to read data file at 'C:\Temp\SWTOR_MOD\swtor_restrainingbolt.dat'
[TRACE] readDataFile 'C:\Temp\SWTOR_MOD\swtor_restrainingbolt.dat'
[TRACE] 'C:\Temp\SWTOR_MOD\swtor_restrainingbolt.dat' is open as READ ONLY
[TRACE] 'C:\Temp\SWTOR_MOD\swtor_restrainingbolt.dat' is closed
[TRACE] Data File created with version 201511181736
[TRACE] ***
[TRACE] DATA FILE READ at 'C:\Temp\SWTOR_MOD\swtor_restrainingbolt.dat':
[TRACE]  Data File Version: 201511181736
[TRACE]      Game Location: .
[TRACE]    Backup Location: C:\Temp\swtor_restrainingbolt\Backup
[TRACE]        Asset Patch: 218
[TRACE]         Asset Data: 1596.1.0
[TRACE]       Republic MD5: f24e73989ab2b0abc2d7a3999c4e4ca4
[TRACE]       Imperial MD5: ec25016cb2ec69772fc2132234bff0a4
[TRACE] Assets Are Patched: 1
[TRACE] ***
[DEBUG] Checking stored backup root
[TRACE] Using stored backup location
WARNING: Game location not detected or specified, using current folder.
[TRACE] Building Asset and Backup Paths
[DEBUG] '.' is the current folder.
[DEBUG] Using '.' as the location for Star Wars: The Old Republic.
[DEBUG] Using 'C:\Source\swtor_restrainingbolt\Backup\Backup' for the backup folder.
[DEBUG] Using 'Assets\assets_swtor_main_version.txt' for the asset version.
```


Finally, the switch ```-debug_nopatch``` will go through the motions of patching the asset files but won't actually write to them.    You'll want to have ```-trace``` on if using this as the actual patching is done in a function call.



# How It Works

The asset files are actually archives containing many small sound files.

The tool simply takes two of the asset files (```swtor_en-us_cnv_comp_chars_rep_1```
and ```swtor_en-us_cnv_comp_chars_imp_1```) and replaces the internal filenames 
where the ship droid names appear with ```XXXX```.

When the game tries to play one of those sound files, it can't find it so instead of hearing C2N2 drone on, you instead hear blissful silence instead!


example:

```
cnv_location_companion_characters_multi_republic_c2n2_c2n2_98_m.wem
```

becomes

```
cnv_location_companion_characters_multi_republic_XXXX_XXXX_98_m.wem
```

It gets the asset version information from the ```assets_swtor_main_version.txt``` file in the game's "Assets" folder.


# Data File Format

The data file format has changed between v201511161613 and v201511181736.     

Any existing data file will be automatically updated when the new version of the program is run.

Value|Comment
-----|-------
PROGRAM NAME|Identification
PROGRAM VERSION|Identification
DATA FILE|Literally "DATA FILE"
Game Installation Folder|Star Wars: The Old Republic location
Backup (Root) Folder|Where Asset Backup Files are Stored
Assets Patch Version|Game Asset Patch Level
Assets Data Version|Game Asset Data Level
Checksum of the Republic Asset File|MD5 Hash
Checksum of the Imperial Asset File|MD5 Hash
Patch Applied Flag|0 = No, 1 = Yes

v201511181736 adds the "Backup Folder" field and all the other data is now actually used. 

# Changelog

201511181736
* Revised the data file (it will automatically upgrade the data file)
* Now uses Game Installation and Backup Root locations
* Added ```-nobackup``` option (not recommended but for those who like danger)
* Added ```-nodata``` option (keeps it from using a data file)
* Added ```-trace``` option for those that like lots of debug text
* Improved logic on when to update backups and other validations

NOTE: Unless you use ```-nodata```, you only need to specify things like -game and -backup the first time you run the  software (if you're not using the defaults).  It will remember those locations after that.
	

201511161613
* Initial Version




