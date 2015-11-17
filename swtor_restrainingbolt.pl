#
#	Star Wars: The Old Republic
#	DroidMod
#
#=============================================================================

use strict;
use warnings;

use Env;
use Digest::MD5;
use File::Copy;
use Getopt::Long;
use File::Spec;
use Win32::TieRegistry;

use constant{
	PROGRAM_VERSION => "201511161613",
	PROGRAM_SHORT_NAME => "restrainingbolt",
	PROGRAM_NAME => "Restraining Bolt",
	PROGRAM_DESCRIPTION => "Ship Droid Mod",
	GAME_NAME => "Star Wars: The Old Republic",

	#	Defaults

	DEFAULT_DEBUG => 0,				# 0 Debug Off, 1 DEBUG, 2 DEBUG TRACE
	DEFAULT_NO_WRITE => 0,				# 0 Normal, 1 Don't actually patch
	DEFAULT_USE_JUMPBACK => 0,
	DEFAULT_GAME_ROOT => ".",
	DEFAULT_BACKUP_ROOT => ".",
	DEFAULT_DATA_ROOT => ".",
	FOLDER_BACKUP => "Backup",
	FOLDER_DATA => "SWTOR_MOD",
	DEBUG => 1,
	TRACE => 2,
	MOD_FILE_COUNT => 2,
	DATA_FILE => "swtor_restrainingbolt.dat",

	#	SWTOR

	SWTOR_ASSET_MAGIC_LEN => 3,
	SWTOR_ASSET_MAGIC => "MYP",
	SWTOR_ASSETS_FOLDER => "Assets",
	SWTOR_NAME_REPUBLIC => "Republic",
	SWTOR_NAME_IMPERIAL => "Imperial",
	SWTOR_ASSET_VERSION_FILENAME => "assets_swtor_main_version.txt",
	SWTOR_ASSET_FILE_REPUBLIC => "swtor_en-us_cnv_comp_chars_rep_1",
	SWTOR_ASSET_FILE_IMPERIAL => "swtor_en-us_cnv_comp_chars_imp_1",
	SWTOR_ASSET_SOURCE_REPUBLIC => "c2n2",
	SWTOR_ASSET_SOURCE_IMPERIAL => "2vr8",
	SWTOR_FILE_EXTENSION => "tor",
	SWTOR_X64_REGISTRY_KEY => "HKEY_LOCAL_MACHINE\\SOFTWARE\\Wow6432Node\\BioWare\\Star Wars-The Old Republic",
	SWTOR_X86_REGISTRY_KEY => "HKEY_LOCAL_MACHINE\\SOFTWARE\\BioWare\\Star Wars-The Old Republic",
	SWTOR_REGISTRY_VALUE => "Install Dir",
	REPLACE_REPUBLIC => "XXXX",
	REPLACE_IMPERIAL => "XXXX",

	#	Data Buffering

	READ_BUFFER_SIZE => 0,			#	Use File Length
#	READ_BUFFER_SIZE => 262144,		#	256KB
#	READ_BUFFER_SIZE => 1048576,		#	1MB
#	READ_BUFFER_SIZE => 67108864,		#	64MB
#	READ_BUFFER_SIZE => 268435456,		#	256MB
#	READ_BUFFER_SIZE => 536870912,		#	512MB

#	Strings

	REPAIR_ADVICE_MUST => "You will need to perform a repair from the launcher to restore the originals.",
	REPAIR_ADVICE_MAY => "You may need to perform a repair from the launcher to restore the originals.",
	MSG_MOD_ABORT => "Modification Cancelled",
	MSG_MOD_OK => "Modification Successful!",
	MSG_MOD_ALREADY_PATCHED => "Modification Already In Place!",
	MSG_MOD_FAIL => "Modification Failed",
	MSG_UNINSTALL => "To restore original assets:",
	MSG_FAIL_TIP1 => "Before attempting to run this again,",
	MSG_FAIL_TIP2 => "you may need to restore original assets:",
	MSG_RESTORE_OK => "Restore Successful!",
	MSG_RESTORE_FAIL => "Restore Failed!",
	TIP_MANUAL => "* Manually copy assets from backup folder to game assets folder",
	TIP_RESTORE => "* Run this tool with -restore option",
	TIP_REPAIR => "* Perform a repair from the launcher",
};


# Variables, Arrays and Structures

my $debug;

my $backuproot;
my $gameroot;
my $dataroot;

my $folder_assets;
my $folder_data;
my $folder_backup;

my $assetpathname;
my $backuppathname;
my $active_path;

my $asset_version_patch;
my $asset_version_data;
my $hash_asset_republic;
my $hash_asset_imperial;

my $stored_version_patch;
my $stored_version_data;
my $stored_hash_asset_republic;
my $stored_hash_asset_imperial;
my $stored_is_patched;

my $retval;
my $retcode;

my $buffer;

my $use_jumpback = DEFAULT_USE_JUMPBACK;

my $pathname_republic_asset;
my $pathname_imperial_asset;
my $pathname_republic_backup;
my $pathname_imperial_backup;
my $pathname_datafile;
my $pathname_asset_version;

my $search_republic;
my $search_imperial;

my $replace_republic;
my $replace_imperial;

my $game_name;

my $file_asset_version;
my $file_republic_assets;
my $file_imperial_assets;
my $file_data;

my $name_republic;
my $name_imperial;

my $ext_assets;

my $start_run_time;
my $finish_run_time;
my $elapsed_run_time;
my $registry_key;
my $registry_value;

my $temp_path;

my $flag_updated_assets = 0;
my $flag_data_file_read = 0;
my $flag_new_data_file = 0;
my $flag_assets_already_patched = 0;
my $flag_success = 0;
my $flag_backup_ok = 1;
my $flag_backup_success = 0;
my $flag_skip_backup = 0;
my $flag_debug_no_op = DEFAULT_NO_WRITE;
my $flag_restore_operation = 0;
my $flag_exit = 0;

my $flag_assets_exist = 0;
my $flag_backups_exist = 0;

my $local_temp = $ENV{TEMP};
my $local_appdata = $ENV{LOCALAPPDATA};

my $mod_file_count = MOD_FILE_COUNT;

$gameroot = DEFAULT_GAME_ROOT;
$backuproot = DEFAULT_BACKUP_ROOT;
$dataroot = DEFAULT_DATA_ROOT;

$folder_backup  = FOLDER_BACKUP;
$folder_data = FOLDER_DATA;
$folder_assets = SWTOR_ASSETS_FOLDER;

$file_republic_assets = SWTOR_ASSET_FILE_REPUBLIC;
$file_imperial_assets = SWTOR_ASSET_FILE_IMPERIAL;
$file_asset_version = SWTOR_ASSET_VERSION_FILENAME;
$file_data = DATA_FILE;

$search_republic = SWTOR_ASSET_SOURCE_REPUBLIC;
$search_imperial = SWTOR_ASSET_SOURCE_IMPERIAL;

$replace_republic = REPLACE_REPUBLIC;
$replace_imperial = REPLACE_IMPERIAL;

$ext_assets = SWTOR_FILE_EXTENSION;

$name_republic = SWTOR_NAME_REPUBLIC;
$name_imperial = SWTOR_NAME_IMPERIAL;

$game_name = GAME_NAME;

$debug = DEFAULT_DEBUG;

$assetpathname = "";
$backuppathname = "";

$stored_version_patch = -1;
$stored_version_data = -1;
$stored_hash_asset_republic = -1;
$stored_hash_asset_imperial = -1;
$stored_is_patched = -1;

$retval = 0;
$retcode = 0;

#-----------------------------------------------------------
# Program Start
#-----------------------------------------------------------

$start_run_time = time;

$active_path = File::Spec->curdir();

writelog(PROGRAM_NAME . " v" . PROGRAM_VERSION);
writelog(GAME_NAME . " (" . PROGRAM_DESCRIPTION . ")");
writelog();

writelog("DEBUG MODE ENABLED",DEBUG);
writelog("TRACE MODE ENABLED",TRACE);

if (READ_BUFFER_SIZE > 0) {
	writelog("Data Buffer Size: " . READ_BUFFER_SIZE,DEBUG);
	if ($use_jumpback) {
		writelog("Using JumpBack Scanning");
	}
}

if ($flag_debug_no_op) {
	writelog("NO ACTUAL PATCHES WILL OCCUR",DEBUG);
}

#	Locate SWTOR Install (command line can override)

writelog("Attempting to locate game installation",TRACE);
$registry_value = $Registry->{SWTOR_X64_REGISTRY_KEY . "\\" . SWTOR_REGISTRY_VALUE} or $registry_key = "";
if ($registry_value) {
	$gameroot = $registry_value;
} else {
	$registry_value = $Registry->{SWTOR_X86_REGISTRY_KEY . "\\" . SWTOR_REGISTRY_VALUE} or $registry_key = "";
	if ($registry_value) {
		$gameroot = $registry_value;
	}
}
if ($registry_value) {
	writelog("Installation located at '$gameroot'",TRACE);
} else {
	writelog("Could not locate game installation",TRACE);
}

#	Check Local Temp for use as Backup Root

writelog("Configuring Default Data and Backup Locations",TRACE);
if ($local_temp) {
	if (-d $local_temp) {
		writelog("Attempting to use '$local_temp' for backups",TRACE);
		$backuproot = File::Spec->catfile($local_temp, $folder_data);
		if (-d $backuproot) {
			writelog("'$backuproot' exists",TRACE);
		} else {
			writelog("Creating '$backuproot'",TRACE);
			if (mkdir $backuproot) {
				writelog("Created '$backuproot' OK",TRACE);
			} else {
				$backuproot = DEFAULT_BACKUP_ROOT;
				writelog("Backup root fallback to '$backuproot'",TRACE);			}
		}
	}
} else {
	$backuproot = DEFAULT_BACKUP_ROOT;
	writelog("Backup root fallback to '$backuproot'",TRACE);
}

if ($local_appdata) {
	if (-d $local_appdata) {
		$dataroot = $local_appdata;
		writelog("Using '$dataroot' for data storage",TRACE);
	} else {
		$dataroot = DEFAULT_DATA_ROOT;
		writelog("Data root fallback to '$dataroot'",TRACE);
	}
} else {
	$dataroot = DEFAULT_DATA_ROOT;
	writelog("Data root fallback to '$dataroot'",TRACE);
}

#	Process Options

my $result = GetOptions (
			"backup=s" => \$backuproot,
			"game=s" => \$gameroot,
			"data=s" => \$dataroot,
			"version|ver" => sub{showVersion()},
			"help|?" => sub{showHelp()},
			"restore|r" => \$flag_restore_operation,
			"debug" =>\$debug,
);



if ($gameroot eq DEFAULT_GAME_ROOT) {
	writelog("WARNING: $game_name location not detected or specified.");
} 

if ($backuproot eq DEFAULT_BACKUP_ROOT) {
	writelog("WARNING: backup location not specified, using current folder.");
} 

if ($dataroot eq DEFAULT_DATA_ROOT) {
	# 	Using current folder for data
} 

#	Build Paths

writelog("Building Paths",TRACE);

$pathname_republic_asset = File::Spec->catfile($gameroot, $folder_assets);
$pathname_republic_asset = File::Spec->catfile($pathname_republic_asset, "$file_republic_assets.$ext_assets");

$pathname_republic_backup = File::Spec->catfile($backuproot, $folder_backup);
$pathname_republic_backup = File::Spec->catfile($pathname_republic_backup, "$file_republic_assets.$ext_assets");

$pathname_imperial_asset = File::Spec->catfile($gameroot, $folder_assets);
$pathname_imperial_asset = File::Spec->catfile($pathname_imperial_asset, "$file_imperial_assets.$ext_assets");

$pathname_imperial_backup = File::Spec->catfile($backuproot, $folder_backup);
$pathname_imperial_backup = File::Spec->catfile($pathname_imperial_backup, "$file_imperial_assets.$ext_assets");

$pathname_asset_version = File::Spec->catfile($gameroot, $folder_assets);
$pathname_asset_version = File::Spec->catfile($pathname_asset_version, $file_asset_version);

$pathname_datafile = File::Spec->catfile($dataroot, $folder_data);
$pathname_datafile = File::Spec->catfile($pathname_datafile, $file_data);

writelog("'$active_path' is the current folder.",DEBUG);
writelog("Using '$gameroot' as the location for $game_name.");
writelog("Using '$backuproot\\$folder_backup' for the backup folder.");
writelog("Using '$pathname_asset_version' for the asset version.",DEBUG);
writelog("Using '$pathname_datafile' for the data file.",DEBUG);

#	Get Asset Version

if (-e $pathname_asset_version) {
	$retval = getAssetVersion($pathname_asset_version);
	($asset_version_patch,$asset_version_data) = split(/\|/,$retval,2);
	if ($asset_version_patch == -1) {
		writelog("ERROR: Failed to parse asset version file.");
	} else {
		writelog("Asset Version is Patch: $asset_version_patch; Data: $asset_version_data",TRACE);
	}
} else {
	writelog("ERROR: Could not locate asset version file.");
}

if (-e $pathname_datafile) {
	writelog("Attempting to read data file at '$pathname_datafile'",DEBUG);
	if (readDataFile($pathname_datafile)) {
		$flag_data_file_read = 1;
	} else {
		writelog("ERROR: Failed to read data file. Creating new one.",DEBUG);
		$flag_data_file_read = 0;
		$flag_new_data_file = 1;
	}
} else {
	writelog("ERROR: No data file. Creating new one.",DEBUG);
	$flag_data_file_read = 0;
	$flag_new_data_file = 1;
}

if ($flag_data_file_read) {
	writelog("Using Data File: '$pathname_datafile'.",DEBUG);
} else {
	writelog("Creating New Data File: '$pathname_datafile'.",DEBUG);
	if (-d $dataroot) {
		writelog("Folder '$dataroot' Exists",DEBUG);
		$temp_path = File::Spec->catfile($dataroot, $folder_data);
		if (-d $temp_path) {
			writelog("Folder '$temp_path' Exists",DEBUG);
		} else {
			writelog("Folder '$temp_path' Does Not Exist",DEBUG);
			if (mkdir $temp_path) {
				writelog("Created '$temp_path' OK",DEBUG);
			} else {
				writelog("Attempt to Create '$temp_path' FAILED",DEBUG);
			}
		}
	} else {
		writelog("ERROR: Data folder '$dataroot' does not exist!");
	}
}

#	Run Restore Operation (if selected)

if ($flag_restore_operation) {
	if (restoreAssets()) {
		if ($flag_data_file_read) {
			writelog("Verifying Assets for Data File",TRACE);

			$flag_assets_already_patched = assetsPatched();

			$retval = 0;

			writelog("Getting MD5 hashes for assets.",TRACE);
			writelog("Getting MD5 hash for $name_republic asset file.",TRACE);

			$hash_asset_republic = getFileHash($pathname_republic_asset);
			if ($hash_asset_republic eq "ERROR") {
				writelog("ERROR: Failed to get MD5 hash for $name_republic asset file.",TRACE);
			} else {
				if ($stored_hash_asset_republic ne "ERROR") {
					if ($stored_hash_asset_republic eq $hash_asset_republic) {
						$retval++
					}
				}
			}

			writelog("Getting MD5 hash for $name_imperial asset file.",TRACE);
			$hash_asset_imperial = getFileHash($pathname_imperial_asset);
			if ($hash_asset_imperial eq "ERROR") {
				writelog("ERROR: Failed to get MD5 hash for $name_imperial asset file.",TRACE);
			} else {
				if ($stored_hash_asset_imperial ne "ERROR") {
					if ($stored_hash_asset_imperial eq $hash_asset_imperial) {
						$retval++
					}
				}
			}

			if ($retval == $mod_file_count) {
				writelog("Asset hashes match the originals",TRACE);
				$stored_is_patched = 0;
			} else {
				writelog("WARNING: Assets may still be patched!  Checksums do not match");
			}

			if ($flag_assets_already_patched == $mod_file_count) {
				$stored_is_patched = 1;
				writelog("WARNING: Assets are still patched!");
			} else {
				$stored_is_patched = 0;
			}
			

			if ($retval == $mod_file_count) {
				if ($flag_assets_already_patched == 0 ) {
					writelog("Assets Verified");
				}
			}

			writelog("Updating Data File '$pathname_datafile'",TRACE);

			$retval = writeDataFile($pathname_datafile);

			if ($retval) {
				writelog("Data File Written OK",DEBUG);
			} else {
				writelog("ERROR: Could not write data file.");
			}
		} else {
			writelog("No data file.",DEBUG);
		}
	} else {
		writelog("restoreAssets failed",TRACE);
	}
	$flag_exit = 1;
	exit(0);
}

#	Verify Assets

writelog("Verifying $game_name Assets");

writelog("$name_republic Asset Pathname: $pathname_republic_asset",DEBUG);
writelog("$name_republic Backup Pathname: $pathname_republic_backup",DEBUG);
writelog("$name_imperial Asset Pathname: $pathname_imperial_asset",DEBUG);
writelog("$name_imperial Backup Pathname: $pathname_imperial_backup",DEBUG);

if (-e $pathname_republic_asset) {
	if (verifyAssetFile($pathname_republic_asset)) {
		$flag_assets_exist++ 
	} else {
		writelog("ERROR: $name_republic asset file is invalid.");
		$flag_exit = 1;
	}
} else {
	writelog("ERROR: Could not find $name_republic asset file.");
	$flag_exit = 1;
}

if (-e $pathname_imperial_asset) {
	if (verifyAssetFile($pathname_imperial_asset)) {
		$flag_assets_exist++ 
	} else {
		writelog("ERROR: $name_imperial asset file is invalid.");
		$flag_exit = 1;
	}
} else {
	writelog("ERROR: Could not find $name_imperial asset file.");
	$flag_exit = 1;
}

if ($flag_assets_exist == $mod_file_count) {
	$flag_assets_already_patched = assetsPatched();

	if (-e $pathname_republic_backup) {
		$flag_backups_exist++;
	}

	if (-e $pathname_imperial_backup) {
		$flag_backups_exist++;
	}
} else {
	writelog("Could not locate one or more asset files");
	writelog("Modification Cancelled");
	$flag_backup_ok = -2;
	$flag_skip_backup = 1;
	$flag_success = 0;
	$flag_exit = 1;
}

if ($flag_assets_already_patched ==  $mod_file_count) {
	$flag_success = 2;
	$flag_backup_ok = 255;
	$flag_skip_backup = 1;
	$flag_exit = 1;
}

if ($flag_exit) {
	#	Exiting
} else {
	if (($stored_version_patch != $asset_version_patch) || ($stored_version_data ne $asset_version_data)) {
		$flag_updated_assets = 1;

		if ($flag_new_data_file == 1) {
			writelog("New Data.",DEBUG);
		} else {
			writelog("Updating Data.",DEBUG);			
		}

		# Data Has Changed or is new

		writelog("Getting MD5 hashes for assets.",DEBUG);
		writelog("Getting MD5 hash for $name_republic asset file.",DEBUG);

		$hash_asset_republic = getFileHash($pathname_republic_asset);
		if ($hash_asset_republic eq "ERROR") {
			writelog("ERROR: Failed to get MD5 hash for $name_republic asset file.",DEBUG);
		}

		writelog("Getting MD5 hash for $name_imperial asset file.",DEBUG);
		$hash_asset_imperial = getFileHash($pathname_imperial_asset);
		if ($hash_asset_imperial eq "ERROR") {
			writelog("ERROR: Failed to get MD5 hash for $name_imperial asset file.",DEBUG);
		}

		writelog("$name_republic Asset Hash: $hash_asset_republic",DEBUG);
		writelog("$name_imperial Asset Hash: $hash_asset_imperial",DEBUG);

		if ($flag_new_data_file) { 
			$stored_version_patch = $asset_version_patch;
			$stored_version_data = $asset_version_data;
			$stored_hash_asset_republic = $hash_asset_republic;
			$stored_hash_asset_imperial = $hash_asset_imperial;
			if ($flag_assets_already_patched == $mod_file_count) {
				$stored_is_patched = 1;
			} else {
				$stored_is_patched = 0;
			}
			writelog("Current Asset Version is Patch: $asset_version_patch; Data: $asset_version_data",DEBUG);
		} else {
			# TO DO
			#	update file
			#	right now it just does the same thing but shuld probably be smarter

			$stored_version_patch = $asset_version_patch;
			$stored_version_data = $asset_version_data;
			$stored_hash_asset_republic = $hash_asset_republic;
			$stored_hash_asset_imperial = $hash_asset_imperial;
			if ($flag_assets_already_patched == $mod_file_count) {
				$stored_is_patched = 1;
			} else {
				$stored_is_patched = 0;
			}

			writelog(" Stored Asset Version is Patch: $stored_version_patch; Data: $stored_version_data",DEBUG);
			writelog("Current Asset Version is Patch: $asset_version_patch; Data: $asset_version_data",DEBUG);
		}

		$retval = writeDataFile($pathname_datafile);

		if ($retval) {
			writelog("Data File Written OK",DEBUG);
		} else {
			writelog("ERROR: Could not write data file.");
		}
	} else {
		# Data Version is the same

		writelog("Data Unchanged",DEBUG);
		writelog("Asset Version is Patch: $asset_version_patch; Data: $asset_version_data",DEBUG);

		$flag_updated_assets = 0;
	}
}

if ($flag_exit) {
	# Exiting
} else {
	if ($flag_backups_exist == $mod_file_count) {
		# Determine if backups are needed

		if ($flag_updated_assets) {
			writelog("Backups Will Be Refreshed");
			$flag_skip_backup = 0;
		} else {
			writelog("Backups Already Exist, Skipping");
			$flag_skip_backup = 1;
		}


	} else {
		$flag_skip_backup = -1;
	}
}

if ($flag_exit) {
	# Exiting
} else {
	if ($flag_skip_backup == 0) {
		if ($flag_assets_already_patched) {
			writelog("Assets Are Already Patched!");
			$flag_skip_backup = 3;
			if ($flag_backups_exist == $mod_file_count) {
				$retval = 0;
				$retval = isPatched($pathname_republic_backup,$replace_republic);
				if ($retval > 0) {
					$retval++;
				}
				$retval = isPatched($pathname_imperial_backup,$replace_imperial);
				if ($retval > 0) {
					$retval++;
				}	

				if ($retval > 0) {
					writelog("Backups are not clean!  Restore will not be available.");
					$flag_skip_backup = 6;
				}
			}

			
		}
	}
}

writelog(" Asset Status: $flag_assets_exist",DEBUG);
writelog("Backup Status: $flag_backups_exist",DEBUG);
writelog("Flags:",DEBUG);
writelog("   	          Exit: $flag_exit",DEBUG);
writelog("           Skip Backup: $flag_skip_backup",DEBUG);
writelog("        Data File Read: $flag_data_file_read ($flag_new_data_file)",DEBUG);
writelog("        Assets Updated: $flag_updated_assets",DEBUG);
writelog("Assets Already Patched: $flag_assets_already_patched",DEBUG);


#	Back Up Asset Files (if needed)

if ($flag_exit) {
	#	Exiting
} else {
	if ($flag_skip_backup > 0) {
		$flag_backup_ok = 255;

		if ($flag_skip_backup == 3) {
			$flag_backup_ok = -1;
		}

		if ($flag_skip_backup == 6) {
			$flag_backup_ok = -2;
		}

	} else {

		#	Check Backup Location

		writelog("Checking backup root: '$backuproot'",DEBUG);
		if (-d $backuproot ) {
			$temp_path = File::Spec->catfile($backuproot, $folder_backup);
			writelog("Checking folder: '$temp_path'",DEBUG);
			if (-d $temp_path) {
				writelog("Backup folder exists",DEBUG);
			} else {
				writelog("Creating backup folder",DEBUG);
				if (mkdir $temp_path) {
					writelog("Created backup folder OK",DEBUG);
				} else {
					writelog("Created backup folder FAILED",DEBUG);
				}
					
			}
		} else {
			writelog("ERROR: $backuproot does not exist.");
		}

		writelog("Backing Up Assets");
		writelog("Backing Up Asset File: $name_republic");
		$retval = backupFile($pathname_republic_asset,$pathname_republic_backup);
		if ($retval > 0) {
			$flag_backup_success++;
		} else {
			$flag_backup_ok = 0;
		}
	
		writelog("Backup: $retval = $pathname_republic_asset to $pathname_republic_backup",DEBUG);

		writelog("Backing Up Asset File: $name_imperial");
		$retval = backupFile($pathname_imperial_asset,$pathname_imperial_backup);
		if ($retval > 0) {
			$flag_backup_success++;
		} else {
			$flag_backup_ok = 0;
		}

		writelog("Backup: $retval = $pathname_imperial_asset to $pathname_imperial_backup",DEBUG);

		if ($flag_backup_success == $mod_file_count) {
			writelog("Backups Successful",DEBUG);
			$flag_backup_ok = 1;
		} else {
			writelog("Backups Failed",DEBUG);
			$flag_backup_ok = 0;
		}
	}
} 


#	Patch Assets

if ($flag_backup_ok > 0) {
	if ($flag_exit) {
		#	Exiting
	} else {
		$flag_success = 0;

		writelog("Patching Assets");

		writelog("Patching Assets: $name_republic");
		$retval = patchFile($pathname_republic_asset,$search_republic,$replace_republic);
		if ($retval > 0) {
			$flag_success++;
		}

		writelog("Patching Assets: $name_imperial");
		$retval = patchFile($pathname_imperial_asset,$search_imperial,$replace_imperial);
		if ($retval > 0) {
			$flag_success++;
		}
		
		if ($flag_success == $mod_file_count) {
			$stored_is_patched = 1;

			$retval = writeDataFile($pathname_datafile);

			if ($retval) {
				writelog("Data File Written OK",DEBUG);
			} else {
				writelog("ERROR: Could not write data file.");
			}
		}
	}
} else {
	if ($flag_exit) {
		# 	Exiting
	} else {
		writelog("Error Backing Up Assets, Modification Cancelled");	
		$flag_success = 0;
	}
}

#	Report Status

if ($flag_success == $mod_file_count) {
	if ($flag_assets_already_patched ==  $mod_file_count) {
		writelog(MSG_MOD_ALREADY_PATCHED);
	} else {
		writelog(MSG_MOD_OK);
	}
	writelog();
	writelog(MSG_UNINSTALL);
	writelog(TIP_MANUAL);
	writelog(TIP_RESTORE);
	writelog(TIP_REPAIR);
	writelog();
} else {
	if ($flag_exit) {
		# 	Exiting
	} else {
		writelog(MSG_MOD_FAIL);
		writelog();
		writelog(MSG_FAIL_TIP1);
		writelog(MSG_FAIL_TIP2);
		writelog(TIP_MANUAL);
		writelog(TIP_RESTORE);
		writelog(TIP_REPAIR);
		writelog();
	}
}

$finish_run_time = time;
$elapsed_run_time = $finish_run_time - $start_run_time;

writelog("Execution time was $elapsed_run_time second(s)");
writelog("Program Completed");

#-----------------------------------------------------------
# FUNCTIONS
#-----------------------------------------------------------

#-----------------------------------------------------------
# Write Log
#-----------------------------------------------------------
sub writelog{
	my $temp_string = shift;
	my $debug_message = shift;
	my $flag_show_message = 1;
	my $prefix_message = "";

	$debug_message = 0 unless defined $debug_message;
	$temp_string = "" unless defined $temp_string;

	if ($debug_message) {
		$flag_show_message = 0;

		if ($debug > 0) {
			if (($debug == DEBUG) && ($debug_message == DEBUG)) {
				$prefix_message = "DEBUG";
				$flag_show_message = 1;
			}

			if (($debug == TRACE) && ($debug_message == TRACE)) {
				$prefix_message = "TRACE";
				$flag_show_message = 1;
			}
		}
	}

	
	if ($flag_show_message) {
		if ($prefix_message) {
			$temp_string = "[$prefix_message] $temp_string";
		}
		print "$temp_string\n";
	}

	return;
}

#-----------------------------------------------------------
# Verify SWTOR Asset File
#-----------------------------------------------------------
sub verifyAssetFile{
	my $pathname = shift;
	my $retval = 0;
	my $flag_magic_ok = 0;
		
	return $retval unless defined $pathname;

	writelog("verifyAssetFile '$pathname'",TRACE);

 	if (open(my $fh, '<', $pathname)) {
		binmode($fh);
		writelog("'$pathname' is open in binary mode",TRACE);
		read($fh, $buffer, 48);
		writelog("'$pathname' is closed",TRACE);	
		close($fh);
		if (substr($buffer,0,SWTOR_ASSET_MAGIC_LEN) eq SWTOR_ASSET_MAGIC) {
			$flag_magic_ok = 1;
		}
	} else {
		writelog("Could not open '$pathname'",TRACE);	
	}
	
	if ($flag_magic_ok) {
		$retval = 1;
	}

	return $retval;
}
	
#-----------------------------------------------------------
# Are Assets Already Patched?
#-----------------------------------------------------------
sub assetsPatched{
	my $tempval;
	my $retval = 0;

	writelog("assetsPatched()",TRACE);

	$tempval = 0;

	$tempval = isPatched($pathname_republic_asset,$replace_republic);
	if ($tempval > 0) {
		$retval++;
	}

	$tempval = isPatched($pathname_imperial_asset,$replace_imperial);
	if ($tempval > 0) {
		$retval++;
	}

	return $retval;
}

#-----------------------------------------------------------
# Check if Asset Already Patched
#-----------------------------------------------------------
sub isPatched{
	my $pathname = shift;
	my $searchfor = shift;

	my $flag_eof = 0;
	my $flag_loop = 1;
	my $flag_search = 1;

	my $retval = -1;

	my $index = 0;
	my $index_position;

	my $file_pointer;
	my $file_pointer_offset;

	my $string_location;
	my $match_counter = 0;
	my $read_counter = 0;
	my $jump_back = 0;
	my $read_buffer_size = 0;

	$read_buffer_size = READ_BUFFER_SIZE;

	return $retval unless defined $pathname;
	return $retval unless defined $searchfor;

	writelog("isPatched '$pathname'",TRACE);

	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($pathname);

	$size = 0 unless defined $size;

	if ($size == 0) {
		return $retval;
	}

	if ($read_buffer_size == 0) {
		$read_buffer_size = $size;
		$use_jumpback = 0;
	}

	if ($read_buffer_size > $size) {
		$read_buffer_size = $size;
		$use_jumpback = 0;
	}

	writelog("Searching '$pathname' for '$searchfor'",DEBUG);
	writelog("Asset file is $size bytes",DEBUG);

	if ($use_jumpback) {
		writelog("Using Jumpback Feature",DEBUG);
	}
	if ($read_buffer_size == $size) {
		writelog("Not buffering data",DEBUG);
	} else {
		writelog("Buffering data $read_buffer_size bytes",DEBUG);
	}

 	if (open(my $fh, '+<', $pathname)) {
		binmode($fh);
		writelog("'$pathname' is open in binary mode",TRACE);

		$retval = 0;

		while( $flag_loop) {
			$read_counter++;
			read($fh, $buffer, $read_buffer_size);
			$file_pointer = tell($fh);
			$file_pointer_offset = $file_pointer - $read_buffer_size;
			if ($file_pointer_offset < 1) {
				$file_pointer_offset = 0;
			}
			$flag_search = 1;
			$index_position = 0;
			writelog("Frame $read_counter, read " . length($buffer) . " bytes",TRACE);
			while ($flag_search) {
				$index = index($buffer,$searchfor,$index_position);
				if ($index >= 0) {
					$string_location = $file_pointer_offset + $index;
					$index_position = $index + 1;
					$match_counter++;
				} else {
					$flag_search = 0;
				}
			}

			# EOF Checks

			if (length($buffer) <= $read_buffer_size) {
				writelog("Buffer is smaller or equal to read buffer size",TRACE);	
				if (eof($fh)) {
					$flag_eof = 1;
				}
				if (length($buffer) == $read_buffer_size) {
					$flag_eof = 1;
				}
				if ($flag_eof) {
					$flag_loop = 0;
				}
			} else {
				if ($use_jumpback) {
					$jump_back = length($searchfor) * 2;
					if ($file_pointer - $jump_back > 0) {
						writelog("Jumping back $jump_back bytes",TRACE);		
						$file_pointer = $file_pointer - $jump_back;
					}
				}
			}
		}
		writelog("'$pathname' is closed",TRACE);	
		close($fh);
	} else {
		writelog("ERROR: Could not open the asset file.");
	}

	if ($match_counter > 0) {
		$retval = 1;
	}

	if ($retval > 0) {
		writelog("Found $match_counter matches of '$searchfor'",TRACE);
	} else {
		if ($retval == 0) {
			writelog(" Read Frames: $read_counter",TRACE);
			writelog("     Matches: $match_counter",TRACE);
		}
	}

	return $retval;
}

#-----------------------------------------------------------
# Patch File
#-----------------------------------------------------------
sub patchFile{
	my $pathname = shift;
	my $searchfor = shift;
	my $replace = shift;

	my $flag_eof = 0;
	my $flag_loop = 1;
	my $flag_search = 1;

	my $retval = -1;

	my $index = 0;
	my $index_position;

	my $file_pointer;
	my $file_pointer_offset;

	my $string_location;
	my $match_counter = 0;
	my $read_counter = 0;
	my $replace_counter = 0;
	my $string_buffer = "";
	my $jump_back = 0;
	my $read_buffer_size = 0;

	$read_buffer_size = READ_BUFFER_SIZE;

	return $retval unless defined $pathname;
	return $retval unless defined $searchfor;
	return $retval unless defined $replace;

	writelog("patchFile '$pathname'",TRACE);

	if ((length($searchfor)) != (length($replace))) {
		writelog("ERROR: Search string and replace string are not the same length!");
		writelog("'$searchfor' is " . length($searchfor) . " bytes",DEBUG);
		writelog("'$replace' is " . length($replace) . " bytes",DEBUG);
		return $retval;
	}

	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat($pathname);

	$size = 0 unless defined $size;

	if ($size == 0) {
		return $retval;
	}

	if ($read_buffer_size == 0) {
		$read_buffer_size = $size;
		$use_jumpback = 0;
	}

	if ($read_buffer_size > $size) {
		$read_buffer_size = $size;
		$use_jumpback = 0;
	}

	writelog("Searching '$pathname' to replace '$searchfor' with '$replace'",DEBUG);
	writelog("Asset file is $size bytes",DEBUG);

	if ($use_jumpback) {
		writelog("Using Jumpback Feature",DEBUG);
	}
	if ($read_buffer_size == $size) {
		writelog("Not buffering data",DEBUG);
	} else {
		writelog("Buffering data $read_buffer_size bytes",DEBUG);
	}

 	if (open(my $fh, '+<', $pathname)) {
		binmode($fh);
		writelog("'$pathname' is open in binary mode",TRACE);
		$retval = 0;

		while( $flag_loop) {
			$read_counter++;
			read($fh, $buffer, $read_buffer_size);
			$file_pointer = tell($fh);
			$file_pointer_offset = $file_pointer - $read_buffer_size;
			if ($file_pointer_offset < 1) {
				$file_pointer_offset = 0;
			}
			$flag_search = 1;
			$index_position = 0;
			writelog("Frame $read_counter, read " . length($buffer) . " bytes",DEBUG);
			while ($flag_search) {
				$index = index($buffer,$searchfor,$index_position);
				if ($index >= 0) {
					$string_location = $file_pointer_offset + $index;
					$index_position = $index + 1;
					$match_counter++;
					writelog("Found '$searchfor' at $index near $file_pointer ($string_location) - buffer page $read_counter",TRACE);
					seek($fh,$string_location,0);
					read($fh,$string_buffer,length($searchfor));
					if ($string_buffer eq $searchfor) {
						seek($fh,$string_location,0);
						if ($flag_debug_no_op) {
							writelog("NO OP: Replacing '$searchfor' with '$replace' at $string_location",TRACE);
						} else {
							writelog("Replacing '$searchfor' with '$replace' at $string_location",TRACE);
							print $fh $replace;
						}
						$replace_counter++;
					}
				} else {
					$flag_search = 0;
				}
			}

			# EOF Checks

			if (length($buffer) <= $read_buffer_size) {
				writelog("Buffer is smaller or equal to read buffer size",TRACE);	
				if (eof($fh)) {
					$flag_eof = 1;
				}
				if (length($buffer) == $read_buffer_size) {
					$flag_eof = 1;
				}
				if ($flag_eof) {
					$flag_loop = 0;
				}
			} else {
				if ($use_jumpback) {
					$jump_back = length($searchfor) * 2;
					if ($file_pointer - $jump_back > 0) {
						writelog("Jumping back $jump_back bytes",TRACE);		
						$file_pointer = $file_pointer - $jump_back;
					}
				}
			}
		}
		writelog("'$pathname' is closed",TRACE);	
		close($fh);
	} else {
		writelog("ERROR: Could not open the asset file.");
	}

	if ($match_counter > 0) {
		if ($match_counter eq $replace_counter) {
			$retval = 1;
		}
	}

	if ($retval > 0) {
		writelog("Found $match_counter matches of '$searchfor', changed $replace_counter matches to '$replace'",DEBUG);
	} else {
		if ($retval == 0) {
			writelog(" Read Frames: $read_counter",TRACE);
			writelog("     Matches: $match_counter",TRACE);
			writelog("Replacements: $replace_counter",TRACE);
		}
	}

	return $retval;
}


#-----------------------------------------------------------
# Backup Copy
#-----------------------------------------------------------
sub backupFile{
	my $source = shift;
	my $target = shift;
	my $retval = -1;

	return $retval unless defined $source;
	return $retval unless defined $target;

	writelog("backupFile '$source' to '$target'",TRACE);

	if (-e $source) {
		$retval = copy($source,$target);
	}

	return $retval;
}

#-----------------------------------------------------------
# Restore Assets
#-----------------------------------------------------------
sub restoreAssets{
	my $retval = 0;
	my $tempret = 0;

	$tempret = 0;
	if (-e $pathname_republic_backup) {
		$tempret++;
	} else {
		writelog("$name_republic backup is missing!",TRACE);
	}

	if (-e $pathname_imperial_backup) {
		$tempret++;
	} else {
		writelog("$name_imperial backup is missing!",TRACE);
	}

	if ($tempret == $mod_file_count) {
		writelog("Backup files are present.",TRACE);	
	} else {
		writelog("One or more backup files are missing!");
		writelog(REPAIR_ADVICE_MUST);
		return $retval;
	}

	$tempret = 0;
	$tempret = isPatched($pathname_republic_backup,$replace_republic);
	if ($tempret > 0) {
		writelog("$name_republic backup is patched!",TRACE);
		$tempret++;
	}

	$tempret = isPatched($pathname_imperial_backup,$replace_imperial);
	if ($tempret > 0) {
		writelog("$name_imperial backup is patched!",TRACE);
		$tempret++;
	}	

	if ($tempret > 0) {
		writelog("One or more backups are patched versions!");
		writelog(REPAIR_ADVICE_MUST);
		return $retval;
	} else {
		writelog("Backup files are not patched",DEBUG);
	}

	writelog("Attempting to Restore Assets");

	writelog("Attempting to Restore Asset File: $name_republic");
	$tempret = backupFile($pathname_republic_backup,$pathname_republic_asset);
	if ($tempret > 0 ) {
		$retval++;
	} else {
		writelog("ERROR: Failed to Restore Asset File: $name_republic");
	}

	writelog("Attempting to Restore Asset File: $name_imperial");
	$tempret = backupFile($pathname_imperial_backup,$pathname_imperial_asset);
	if ($tempret > 0 ) {
		$retval++;
	} else {
		writelog("ERROR: Failed to Restore Asset File: $name_imperial");
	}

	if ($retval == $mod_file_count) {
		writelog(MSG_RESTORE_OK);
		$retval = 1;
	} else {
		writelog(MSG_RESTORE_FAIL);
		writelog(REPAIR_ADVICE_MAY);
		$retval = 0;
	}

	return $retval;
}

#-----------------------------------------------------------
# Read Data File
#-----------------------------------------------------------
sub readDataFile{
	my $pathname = shift;
	my $retval = -1;
	my $fh;
	my @content;

	return $retval unless defined $pathname;
	
	writelog("readDataFile '$pathname'",TRACE);

	if (open($fh, "<", $pathname)) {
		writelog("'$pathname' is open",TRACE);
		@content = <$fh>;
		writelog("'$pathname' is closed",TRACE);	
		close($fh);

		$buffer = $content[0];		# PROGRAM NAME
		chop $buffer;

		if ($buffer ne PROGRAM_NAME) {
			writelog("WARNING: Data file name does not match! ($buffer)",DEBUG);
		}

		$buffer = $content[1];		# VERSION
		chop $buffer;

		writelog("Data File created with version $buffer",TRACE);

		$buffer = $content[2];		# "DATA FILE"
		chop $buffer;

		if ($buffer ne "DATA FILE") {
			writelog("WARNING: Data file chunk missing!",DEBUG);
		}

		$buffer = $content[3];		# gameroot
		chop $buffer;

		#	 not used right now
		
		$buffer = $content[4];		# Assets Patch
		chop $buffer;

		$stored_version_patch = $buffer;

		$buffer = $content[5];		# Assets Data
		chop $buffer;

		$stored_version_data = $buffer;


		$buffer = $content[6];		# Republic Asset Hash
		chop $buffer;

		$stored_hash_asset_republic = $buffer;


		$buffer = $content[7];		# Imperial Asset Hash
		chop $buffer;

		$stored_hash_asset_imperial = $buffer;


		$buffer = $content[8];		# Is Patched
		chop $buffer;

		$stored_is_patched = $buffer;
	
		$retval = 1;		
		
	} else {
		writelog("Could not open '$pathname'",TRACE);	
	}
	

	return $retval;
}

#-----------------------------------------------------------
# Write Data File
#-----------------------------------------------------------
sub writeDataFile{
	my $pathname = shift;
	my $fh;
	my $retval = -1;

	return $retval unless defined $pathname;

	writelog("writeDataFile '$pathname'",TRACE);

	if (-e $pathname) {
		writelog("Deleting '$pathname'",TRACE);
		unlink $pathname;
	}

	if (open($fh, ">", $pathname)) {
		writelog("'$pathname' is open",TRACE);
		print $fh PROGRAM_NAME . "\n";
		print $fh PROGRAM_VERSION . "\n";
		print $fh "DATA FILE\n";
		print $fh "$gameroot\n";
		print $fh "$stored_version_patch\n";
		print $fh "$stored_version_data\n";
		print $fh "$stored_hash_asset_republic\n";
		print $fh "$stored_hash_asset_imperial\n";
		print $fh "$stored_is_patched\n";
		writelog("'$pathname' is closed",TRACE);	
		close($fh);
	} else {
		writelog("Could not open '$pathname'",TRACE);	
	}

	return $retval;
}


#-----------------------------------------------------------
# Get Asset Version
#-----------------------------------------------------------
sub getAssetVersion{
	my $pathname = shift;
	my $retval = "-1\|-1";
	my $ver_patch = "";
	my $ver_data = "";
	my $fh;
	my $buffer = "";

	return $retval unless defined $pathname;
	
	writelog("getAssetVersion using '$pathname'",TRACE);

	if (open($fh, "<", $pathname)) {
		writelog("'$pathname' is open",TRACE);
		$buffer = <$fh>;
		chomp $buffer;
		writelog("'$pathname' is closed",TRACE);	
		close($fh);
	} else {
		writelog("Could not open '$pathname'",TRACE);	
	}


	$ver_patch = $buffer;
	$ver_data = $buffer;

	if ($ver_patch =~ /(\d+)/ ) {
		$ver_patch = $1;
	} else {
		$ver_patch = -1;
	}

	if ($ver_data =~ /(\d+\.\d+\.\d+)/ ) {
		$ver_data = $1;
	} else {
		$ver_data = -1;
	}

	$retval = "$ver_patch\|$ver_data";

	return $retval;
}

#-----------------------------------------------------------
# Get File Hash
#-----------------------------------------------------------
sub getFileHash{
	my $pathname = shift;
	my $hash = "ERROR";
	my $fh;

	return $hash unless defined $pathname;

	writelog("getFileHash '$pathname'",TRACE);

	if (open($fh, "<", $pathname)) {
		binmode($fh);
		writelog("'$pathname' is open in binary mode.",TRACE);
		$hash = Digest::MD5->new->addfile($fh)->hexdigest;
		writelog("'$pathname' is closed",TRACE);	
		close($fh);
	} else {
		writelog("Could not open '$pathname'",TRACE);	
	}


	return $hash;
}

#-----------------------------------------------------------
# Show Version
#-----------------------------------------------------------
sub showVersion{
	exit(0);
}


#-----------------------------------------------------------
# Show Help
#-----------------------------------------------------------
sub showHelp{
	writelog("This mod will silence the audio for the ship droids");
	writelog("in the game '$game_name'.");
	writelog();
	writelog();
	writelog("Commands:");	
	writelog();
	writelog("-restore 		restore from backups");
	writelog("-version		show version");
 	writelog("-debug			show debug messages");
	writelog("-help			this screen");
	writelog();
	writelog();
	writelog("Optional:");
	writelog();
	writelog("-backup folder		specify backup folder");
	writelog("-game folder		specify game folder");
	writelog("-data folder		specify data folder");
	writelog();
	exit(0);
}
