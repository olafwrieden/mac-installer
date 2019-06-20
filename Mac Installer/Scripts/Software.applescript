--
--  Software.applescript
--  Mac Installer
--
--  Created by Olaf Wrieden on 06/11/17.
--  Copyright © 2018 Olaf Wrieden. All rights reserved.
--

script Software
    
    property parent : class "AppDelegate"
    
    -- Copy Installer Files to local 'Shared' user
    on copyInstallersToLocal_(args)
        try
            tell application "Finder" to duplicate folder (item 1 of args as text) to folder (item 2 of args as text) with replacing
        end try
    end copyInstallersToLocal_
    
    -- Install PKG Apps
    on installPKGApps_(args)
        try
            set installedPKGApps to {}
            
            tell application "Finder"
                set allPKGFiles to every file of ((item 1 of args as text) as alias) whose name extension is "pkg"
                if allPKGFiles is not {} then
                    tell me to log ("---- There are " & (count of allPKGFiles) as text) & " PKG files to be installed."
                    
                    repeat with pkgFile from 1 to count of allPKGFiles
                        try
                            set currentPKG to (item pkgFile of allPKGFiles) as text
                            set installPath to quoted form of (posix path of currentPKG as text)
                            set mainName to name of (info for currentPKG as alias)
                            do shell script ("installer -pkg " & installPath & " -target /") with administrator privileges --> Installs PKG
                            set end of installedPKGApps to mainName as text & return
                            tell me to log "App Installed: " & mainName as text
                        end try
                    end repeat
                    
                end if
            end tell
            
            log "---- Installation of " & (count of allPKGFiles) & " PKG files completed."
            return installedPKGApps as text
        on error errorMsg
            display dialog errorMsg
            return installedPKGApps as text
        end try
    end installPKGApps_
    
    -- Show Manual Apps to Install
    on installAppsManually_(installersDir)
        try
            set manualInstallDir to installersDir as text & "Manual Installers:"
            tell application "Finder"
                set totalManualInstallers to count of (files in folder manualInstallDir of desktop whose name extension is "dmg" or name extension is "pkg")
                if totalManualInstallers > 0 then
                    activate (display dialog "For security / licensing reasons " & (totalManualInstallers as integer) & " app(s) need to be installed manually." & return & return & "Click 'Continue' and manually install all apps in the folder." with title "Manual Installers" buttons {"Continue"} default button 1 with icon 1)
                    open (manualInstallDir)
                    activate
                end if
            end tell
        end try
    end InstallAppsManually_
    
    -- Install DMG Apps
    on installDMGApps_(args)
        try
            set installedDMGApps to {}
            
            tell application "Finder"
                set allDMGFiles to every file of (item 1 of args as text as alias) whose name extension is "dmg"
                if allDMGFiles is not {} then
                    tell me to log ("---- There are " & (count of allDMGFiles) as text) & " DMG files to be installed."
                    
                    repeat with dmgFile from 1 to count of allDMGFiles
                        try
                            set mountedDisk to my mountDMG_(item dmgFile of allDMGFiles) --> Mount the DMG
                            if mountedDisk is missing value then error "Could not mount the disk: " & (item dmgFile of allDMGFiles) as text
                            set theApp to my getAppFileOnDisk_(mountedDisk) --> Find app file to install
                            if theApp is missing value then error "Could not find the application to install from disk: " & mountedDisk
                            move {theApp} to (path to applications folder) with replacing --> Installs DMG
                            set end of installedDMGApps to mountedDisk as text & return
                            tell me to log "App Installed: " & mountedDisk as text
                            my ejectDisk_(mountedDisk) --> Eject the mounted DMG
                        end try
                    end repeat
                    
                end if
            end tell
            
            log "---- Installation of " & (count of allDMGFiles) & " DMG files completed."
            return installedDMGApps as text
        on error errorMsg
            display dialog errorMsg
            return installedDMGApps as text
        end try
    end installDMGApps_
    
    -- Mount a .dmg file
    on mountDMG_(dmgPath)
        set dmgPOSIXPath to POSIX path of (dmgPath as text)
        try
            set hdiutilResult to do shell script "/usr/bin/hdiutil attach -noverify " & quoted form of dmgPOSIXPath & " | /usr/bin/awk '/Apple_HFS/'"
            set {TID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, "Apple_HFS"}
            set rawMountPoint to text item 2 of hdiutilResult
            set AppleScript's text item delimiters to TID
            repeat while character 1 of rawMountPoint is not "/"
                set rawMountPoint to text 2 thru -1 of (get rawMountPoint)
            end repeat
            return rawMountPoint as POSIX file as alias
        on error
            return missing value
        end try
    end mountDMG_
    
    -- Return .app Files on Disk
    on getAppFileOnDisk_(diskName)
        tell application "Finder"
            set theApp to {}
            try
                set theApp to files of (entire contents of disk diskName) whose name extension is "app"
            on error errMsg
                log errMsg
                try
                    set theApp to first file of (entire contents of disk diskName) whose name extension is "app"
                end try
            end try
        end tell
        return {theApp}
    end getAppFileOnDisk_

    -- Eject Input Disk
    on ejectDisk_(diskName)
        try
            tell application "Finder" to eject disk diskName
        end try
    end ejectDisk_
    
end script
