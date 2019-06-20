--
--  Tools.applescript
--  Mac Installer
--
--  Created by Olaf Wrieden on 06/11/17.
--  Copyright © 2018 Olaf Wrieden. All rights reserved.
--

script Tools
    
    property parent : class "NSObject"
    
    -- Dock Reset
    on resetDock_()
        try
            set resetDockConfirmed to button returned of (display dialog "Would you like to reset the Dock to its default?" with title "Are you sure?" buttons {"No", "Yes"} default button "Yes" with icon 1)
            if resetDockConfirmed is "Yes" then
                do shell script ("defaults delete com.apple.dock; killall Dock") --> TODO: Potentially Needs Admin Rights
                log ("The Dock has been reset!")
            end if
        end try
    end resetDock_
    
    -- Launchpad Reset
    on resetLaunchpad_()
        try
            set resetConfirmed to button returned of (display dialog "Would you like to reset Launchpad to its default? This will remove any customisation, inluding folders." with title "Are you sure?" buttons {"No", "Yes"} default button "Yes" with icon 1)
            if resetConfirmed is "Yes" then
                do shell script ("defaults write com.apple.dock ResetLaunchPad -bool true; killall Dock")
                log ("Launchpad has been reset!")
            end if
        end try
    end resetLaunchpad_
    
    -- Launchpad Reset
    on emptyTheTrash_()
        tell application "Finder"
            try
                if (count of items in the trash) > 0 then
                    set resetConfirmed to button returned of (display dialog "Would you like to permanently remove the items in the Trash?" with title "Are you sure?" buttons {"No", "Yes"} default button "Yes" with icon 2)
                    if resetConfirmed is "Yes" then
                        try
                            tell application "Finder" to empty the trash
                            tell me to log ("The trash has been emptied!")
                        on error err
                            tell me to log ("The trash has not been emptied! : " & err)
                        end try
                    end if
                else
                    tell me to activate (display dialog "The Trash is already empty." with title "Already Empty" buttons {"OK"} default button 1 with icon 1)
                end if
            end try
        end tell
        tell me to activate
    end emptyTheTrash_

    -- Delete System Logs
    on deleteAllSystemLogs_()
        try
            set resetConfirmed to button returned of (display dialog "Would you like to delete all system logs?" with title "Are you sure?" buttons {"No", "Yes"} default button "Yes" with icon 1)
            if resetConfirmed is "Yes" then
                do shell script ("rm -rf /private/var/log/*") with administrator privileges
                log ("System Log files have been deleted!")
            end if
        on error err
            log err
        end try
    end deleteAllSystemLogs_
    
    -- Delete Temp Files
    on deleteTempFiles_()
        try
            set resetConfirmed to button returned of (display dialog "Would you like to delete all temporary files? Please ensure you close all running apps before continuing." with title "Are you sure?" buttons {"No", "Yes"} default button "Yes" with icon 1)
            if resetConfirmed is "Yes" then
                do shell script ("sudo cd /private/var/tmp/; rm -rf TM*") with administrator privileges
                log ("Temp files have been deleted!")
            end if
        on error err
            log err
        end try
    end deleteTempFiles_

    -- Launchpad Reset
    on flushDNS_()
        try
            set resetConfirmed to button returned of (display dialog "Would you like to flush the DNS Cache?" with title "Are you sure?" buttons {"No", "Yes"} default button "Yes" with icon 1)
            if resetConfirmed is "Yes" then
                try
                    do shell script ("sudo killall -HUP mDNSResponder") with administrator privileges
                    log ("DNS Cache has been flushed!")
                on error
                    try
                        do shell script ("sudo killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache;") with administrator privileges
                        log ("Error, but DNS Cache has been flushed!")
                    on error
                        log "Error flushing"
                    end try
                end try
            end if
        end try
    end flushDNS_

    -- Adjust Backup Time
    on adjustBackupInterval_(theSeconds as text)
        log (theSeconds & " - Needs to be configured.")
        --do shell script ("sudo defaults write /System/Library/LaunchDaemons/com.apple.backupd-auto StartInterval -int " & theSeconds) with administrator privileges
        --log "Backup time changed."
    end adjustBackupInterval_

    -- Dashboard Toggle
    on dashboardToggle_(state)
        try
            do shell script ("defaults write com.apple.dashboard mcx-disabled -boolean " & state & "; killall Dock")
            log ("Dashboard Turned " & state as text)
        end try
    end dashboardToggle_
    
    -- Quick Look's Text Selection Toggle
    on textSelectionInQuickLook_(state)
        try
            do shell script ("defaults write com.apple.finder QLEnableTextSelection -bool " & state & "; killall Finder")
            log ("Quick Look Text Selection Turned " & state as text)
        end try
    end textSelectionInQuickLook_

    -- Repeating Key / Special Characters Toggle
    on repeatingKeyToggle_(state as boolean)
        try
            do shell script ("defaults write -g ApplePressAndHoldEnabled -bool " & state)
            do shell script ("killall Finder")
            log ("Repeating Keys Turned " & state)
        end try
    end repeatingKeyToggle_

    -- Natural Scroll Direction Toggle
    on naturalScrollDirection_(state)
        try
            do shell script "defaults write NSGlobalDomain com.apple.swipescrolldirection -bool " & state
            do shell script "killall Finder"
        end try
    end naturalScrollDirection_
    
    -- Install Network Certificate
    on networkCertificateInstall_(certificatePath)
        try
            do shell script ("sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain " & certificatePath) with administrator privileges
            display dialog "If you correctly entered an administrator's password and clicked to add this certificate, it was successfully added to this mac." with icon 1 with title "Success" buttons {"Close"} default button 1 giving up after 8
        end try
    end networkCertificateInstall_
    
    -- Set the Desktop Picture
    on setDesktopBackground_(backgroundPath)
        try
            set desktopPicturesFolder to (POSIX path of (path to library folder from local domain) & "Desktop Pictures/")
            do shell script ("cp '" & backgroundPath & "' " & quoted form of desktopPicturesFolder) with administrator privileges
            tell application "Finder" to set desktop picture to (desktopPicturesFolder & name of (info for backgroundPath as text)) as POSIX file
        end try
    end setDesktopBackground_
    
    -- Show Media Types on Desktop
    on showDesktopMedia_(args)
        try
            tell application "Finder"
                --open window of Finder preferences
                set desktop shows hard disks of Finder preferences to item 1 of args as text
                set desktop shows external hard disks of Finder preferences to item 2 of args as text
                set desktop shows removable media of Finder preferences to item 3 of args as text
                set desktop shows connected servers of Finder preferences to item 4 of args as text
                close window of Finder preferences
            end tell
        on error
            do shell script ("defaults write com.apple.finder ShowHardDrivesOnDesktop -bool " & item 1 of args as text) --> HDDs
            do shell script ("defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool " & item 2 of args as text) --> External Disks
            do shell script ("defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool " & item 3 of args as text) --> Removable Media
            do shell script ("defaults write com.apple.finder ShowMountedServersOnDesktop -bool " & item 4 of args as text & "; killall Finder") --> Servers
        end try
    end showDesktopMedia_

    -- Set Finder Window Preferences
    on setFinderWindowPrefs_(args)
        (*
         showFileExtensionsChBx's setState_(do shell script ("defaults read com.apple.finder AppleShowAllExtensions"))
         warnBeforeExtensionChangeChBx's setState_(do shell script "if [ $(defaults read com.apple.finder FXEnableExtensionChangeWarning) -eq 1 ]; then echo 1; else echo 0; fi")
         warnBeforeFromIcloudChBx's setState_(do shell script ("defaults read com.apple.finder FXEnableRemoveFromICloudDriveWarning"))
         warnBeforeEmptyingTrashChBx's setState_(do shell script ("defaults read com.apple.finder WarnOnEmptyTrash"))
         deleteTrashAfterThrityChBx's setState_(do shell script "if [ $(defaults read com.apple.finder FXRemoveOldTrashItems) -eq 1 ]; then echo 1; else echo 0; fi")
         keepFoldersOnTopChBx's setState_(do shell script "if [ $(defaults read com.apple.finder _FXSortFoldersFirst) -eq 1 ]; then echo 1; else echo 0; fi")
         preferTabsOverWindowsChBx's setState_(do shell script "if [ $(defaults read com.apple.finder FinderSpawnTab) -eq 1 ]; then echo 1; else echo 0; fi")
         showLibraryFolderChBx's setState_(do shell script "if [[ $(cd ~; ls -lO | grep Library) == *hidden* ]]; then echo 0; else echo 1; fi")
         showHiddenFilesChBx's setState_(do shell script "if [ $(defaults read com.apple.finder AppleShowAllFiles) == YES ]; then echo 1; else echo 0; fi")
         disableDashboardChBx's setState_(do shell script "if [ $(defaults read com.apple.dashboard mcx-disabled) -eq 1 ]; then echo 1; else echo 0; fi")
         *)
        
        try
            tell application "Finder"
                set all name extensions showing of Finder preferences to item 1 of args as boolean
            end tell
            --do shell script ("defaults write com.apple.finder AppleShowAllExtensions " & item 1 of args as text) --> NOT WORKING
            do shell script ("defaults write com.apple.finder FXEnableExtensionChangeWarning " & item 2 of args as text)
            do shell script ("defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning " & item 3 of args as text)
            do shell script ("defaults write com.apple.finder WarnOnEmptyTrash " & item 4 of args as text)
            do shell script ("defaults write com.apple.finder FXRemoveOldTrashItems " & item 5 of args as text)
            do shell script ("defaults write com.apple.finder _FXSortFoldersFirst " & item 6 of args as text)
            do shell script ("defaults write com.apple.finder FinderSpawnTab " & item 7 of args as text)
            
            if (item 8 of args as text = "1") then
                do shell script ("chflags nohidden ~/Library/")
            else
                do shell script ("chflags hidden ~/Library/")
            end if
            
            if (item 9 of args as text = "1") then
                do shell script ("defaults write com.apple.finder AppleShowAllFiles YES")
            else
                do shell script ("defaults write com.apple.finder AppleShowAllFiles NO")
            end if
            
            if (item 10 of args as text = "1") then
                do shell script ("defaults write com.apple.dashboard mcx-disabled -boolean YES")
            else
                do shell script ("defaults write com.apple.dashboard mcx-disabled -boolean NO")
            end if
            
            do shell script ("killall Dock; killall Finder;")
        on error err
            log err
        end try
    end setFinderWindowPrefs_

    -- Set the Desktop Icons' View
    on setDesktopViewOptions_(args)
        try
            tell application "Finder"
                if item 1 of args as boolean is equal to true then
                    set arrangement of desktop's window's icon view options to snap to grid
                else
                    set arrangement of desktop's window's icon view options to not arranged
                end if
                
                set shows item info of desktop's window's icon view options to item 2 of args as boolean
                set shows icon preview of desktop's window's icon view options to item 3 of args as boolean
                do shell script ("killall Finder")
            end tell
        end try
    end setDesktopViewOptions_

    -- Dark Menu bar and Dock
    on darkMenuDock_(state as boolean)
        try
            tell application "System Events" to tell appearance preferences to set dark mode to state
        end try
    end darkMenuDock_
    
    -- Show Recent Apps in Dock
    on showDockRecents_(state as boolean)
        try
            do shell script "defaults write com.apple.dock show-recents -bool " & state
            do shell script "killall Dock"
        end try
    end showDockRecents_
    
    -- Dock Magnification
    on dockMagnification_(state as boolean)
        try
            tell application "System Events" to tell dock preferences to set magnification to state
        end try
    end dockMagnification_
    
    -- Auto Show / Hide Dock
    on autoShowHideDock_(state as boolean)
        try
            tell application "System Events" to tell dock preferences to set autohide to state
        end try
    end autoShowHideDock_

    -- Double Click Window Title
    on doubleClickWindowTitleToMinimise_(state as boolean)
        try
            if state is true then
                do shell script "defaults write NSGlobalDomain AppleActionOnDoubleClick Minimize"
            else
                do shell script "defaults write NSGlobalDomain AppleActionOnDoubleClick None"
            end if
        end try
    end doubleClickWindowTitleToMinimise_

    -- Auto Show / Hide Dock
    on minimiseIntoIcon_(state as boolean)
        try
            do shell script "defaults write com.apple.dock minimize-to-application -bool " & state
            do shell script "killall Dock"
        end try
    end minimiseIntoIcon_

    -- Check if an app is installed
    on checkAppIsInstalled_(appName as text)
        try
            tell application "Finder" to set appInstalled to exists application file ((path to applications folder as string) & appName)
            if appInstalled then
                return true
            else
                return false
            end if
        on error
            return false
        end try
    end checkAppIsInstalled_
    
    -- Reset Spotlight Positions
    on resetSpotlightPosition_()
        do shell script "defaults delete com.apple.Spotlight userHasMovedWindow; defaults delete com.apple.Spotlight windowHeight; killall Spotlight"
    end resetSpotlightPosition_
    
    -- Lock Dock Size
    on lockDocksSize_(state as boolean)
        try
            do shell script "defaults write com.apple.Dock size-immutable -bool " & state
        end try
    end lockDocksSize_
    
    -- Lock Dock Position
    on lockDockPosition_(state as boolean)
        try
            do shell script "defaults write com.apple.Dock position-immutable -bool " & state
        end try
    end lockDockPosition_
    
    -- Lock Dock Contents
    on lockDockContents_(state as boolean)
        try
            do shell script "defaults write com.apple.Dock contents-immutable -bool " & state
        end try
    end lockDockContents_
    
    -- Dim Hidden Apps
    on dimHiddenApps_(state as boolean)
        try
            do shell script "defaults write com.apple.Dock showhidden -bool " & state
            do shell script "killall Dock"
        end try
    end dimHiddenApps_
    
    -- Set Firewall
    on setFirewallStatus_(state as boolean)
        try
            log state
            if state is true then
                do shell script "defaults write /Library/Preferences/com.apple.alf globalstate 1" with administrator privileges
                return "On"
            else
                do shell script "defaults write /Library/Preferences/com.apple.alf globalstate 0" with administrator privileges
                return "Off"
            end if
        end try
    end setFirewallStatus_
    
    -- Change Default Web Browser
    on changeDefaultBrowser_(newDefault as text)
        -- Get Current Default Web Browser
        set currentDefault to do shell script ("export VERSIONER_PERL_PREFER_32_BIT=yes; perl -MMac::InternetConfig -le 'print +(GetICHelper \"http\")[1]'")
        
        if currentDefault contains newDefault then
            display dialog currentDefault & " is already the default web browser for this account. You don't need to make any changes." with title "Default Web Browser" with icon 1 buttons "Close" default button "Close" giving up after 8
        else
            if newDefault contains "Chrome" then
                -- Set Default to Chrome
                tell application "System Events" to set chromeRunning to exists (processes where name is "Google Chrome")
                    
                if chromeRunning as boolean is true then
                    set quitChrome to button returned of (display dialog "A Google Chrome session / process is currently running. To avoid data loss, please close it now and try again." with title "Quit Google Chrome?" buttons {"Quit Chrome", "Cancel"} default button "Cancel" with icon 1)
                    if quitChrome is "Quit Chrome" then tell application "Google Chrome" to quit
                end if
                
                try
                    delay 0.5
                    do shell script "open -a \"Google Chrome\" --args --make-default-browser"
                end try
            else
                set changeConfirm to button returned of (display dialog "This must be done through System Preferences.\nClick Change to open." with title "Change Default Web Browser" buttons {"Cancel", "Change"} default button "Change" with icon 1)
                if changeConfirm is "Change" then
                    tell application "System Preferences" to activate (reveal pane id "com.apple.preference.general")
                else
                    log "User doesn't want to change default browser."
                end if
            end if
        end if
    end changeDefaultBrowser_
    
    -- Auto Import Chrome Bookmarks
    on importChromeBookmarkData_(bookmarksFile as text)
        try
            tell application "Google Chrome"
                activate (open location "chrome://settings/importData")
                delay 4
                tell application "System Events"
                     repeat 2 times
                        keystroke tab
                    end repeat
                    keystroke space
                    delay 0.2
                    keystroke "b"
                    delay 0.2
                    keystroke return
                    delay 0.2
                    repeat 3 times
                        keystroke tab
                    end repeat
                    delay 0.2
                    keystroke return
                    delay 1
                    keystroke "g" using {shift down, command down}
                    delay 0.5
                    keystroke bookmarksFile
                    delay 4
                    repeat 2 times
                        delay 0.5
                        keystroke return
                    end repeat
                    delay 5
                    set visible of application process "Google Chrome" to false
                end tell
            end tell
        end try
    end importChromeBookmarkData_
    
    -- Check if Chrome has ABP Installed
    on isChromeExtensionInstalled_(extID as text)
        try
            set fileExists to do shell script ("find \"$HOME/Library/Application Support/Google/Chrome/Default/Extensions\" -iname " & extID & " 2>/dev/null")
            if fileExists is not "" then
                return true
            else
                return false
            end if
        on error
            return false
        end try
    end isChromeExtensionInstalled_
    
    -- Check if Safari has ABP Installed
    on isSafariExtensionInstalled_(extID as text)
        try
            set entryExists to do shell script ("defaults read ~/Library/Safari/Extensions/Extensions.plist | grep '" & extID & "'")
            set extApp to checkAppIsInstalled_(extID as text)
            if entryExists is not "" or extApp is true then
                return true
            else
                return false
            end if
        on error
            return false
        end try
    end isSafariExtensionInstalled_
    
    -- Check if Internet is Up
    on checkForInternetConnection_()
        try
            do shell script ("curl --max-time 4 'www.google.com'")
            return true
        on error
            return false
        end try
    end checkForInternetConnection_
    
    -- Auto Install ABP for Chrome
    on installChromeExtension_(theLink as text)
        try
            tell application "Google Chrome"
                activate (open location theLink)
                delay 1
                my waitToLoad_()
                delay 1
                repeat 3 times
                    tell application "Google Chrome" to activate
                    tell application "System Events" to keystroke tab -- Navigate to 'Add to Chrome'
                    delay 0.2
                end repeat
                tell application "System Events" to keystroke return -- Click 'Add to Chrome'
            end tell
        end try
    end installChromeExtension_

    -- Wait for Chrome page to load
    on waitToLoad_()
        try
            --tell application "Google Chrome" to set chromeLoading to loading of active tab of window 1
            repeat while chromeLoading = true
                log "WAIT"
                delay 1
                activate
                --tell application "Google Chrome" to set chromeLoading to loading of active tab of window 1
            end repeat
            log "NOW"
        end try
    end waitToLoad_
    
    -- Recover Current Wifi Password
    on recoverCurrentWifiPass_()
        try
            set currentSSID to do shell script ("/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport -I | grep '\\sSSID:' | sed 's/.*: //'")
            set thePassword to (do shell script "security find-generic-password -D \"AirPort network password\" -a " & currentSSID & " -gw") as text
            activate (display dialog "The password for the current Wi-Fi connection is:" & return & thePassword as text with title "Retrieved Password" buttons {"OK"} default button "OK" with icon 1 giving up after 10)
        on error
            activate (display dialog "The current Wi-Fi password could not be found in your Keychain, it must be saved to be retrievable." with title "Unable to retrieve password" buttons {"OK"} default button "OK" with icon 1)
        end try
    end recoverCurrentWifiPass_

    -- Recover Earlier Wi-Fi Password
    on recoverEarlierWifiPass_()
        try
            activate
            set theSSID to text returned of (display dialog "Enter the name of a Wi-Fi network you previously connected to. Captitalisation and spelling matters." with title "What was its name?" default answer "" buttons {"Cancel", "Continue"} default button "Continue" with icon 1)
            set thePassword to (do shell script "security find-generic-password -D \"AirPort network password\" -a " & theSSID & " -gw") as text
            activate (display dialog "The password for that Wi-Fi connection was:" & return & thePassword as text with title "Retrieved Password" buttons {"OK"} default button "OK" with icon 1 giving up after 10)
        on error
            activate (display dialog "The Wi-Fi password for that network could not be found in your Keychain, it must be saved to be retrievable." with title "Unable to retrieve password" buttons {"OK"} default button "OK" with icon 1)
        end try
    end recoverEarlierWifiPass_

    -- Export Device Info
    on generateSystemReport_(toDesktop as boolean)
        try
            tell application "Finder"
                set saveLocation to container of ((POSIX file (current application's NSBundle's mainBundle()'s bundlePath() as text)) as alias) as text
                if not (exists saveLocation & "System Audits") then make new folder at saveLocation with properties {name:"System Audits"}
            end tell
            
            set filename to do shell script "echo $(date +'%d%m%y-%H%M%S').spx"
            
            set reportTypes to {"1. Mini (fast, no personal info, serials or IDs)", "2. Basic (medium, hardware and network info)", "3. Full (slow, all available information)"}
            set reportLevel to choose from list reportTypes with title "Audit Level" with prompt "Which type of report would you like to generate?" default items "1. Mini (fast, no personal info, serials or IDs)"
            delay 1
            
            if (reportLevel as text) starts with "1" then
                do shell script "cd " & quoted form of (POSIX path of saveLocation & "System Audits") & "; system_profiler -detailLevel mini -xml > " & filename
                if toDesktop is true then do shell script "cd " & quoted form of (POSIX path of saveLocation & "System Audits") & "; cp " & filename & " ~/Desktop"
                activate (display dialog "A mini system report has been saved." with title "Successfully Audited" buttons {"OK"} default button 1 with icon 1 giving up after 10)
            else if (reportLevel as text) starts with "2" then
                do shell script "cd " & quoted form of (POSIX path of saveLocation & "System Audits") & "; system_profiler -detailLevel basic -xml > " & filename
                if toDesktop is true then do shell script "cd " & quoted form of (POSIX path of saveLocation & "System Audits") & "; cp " & filename & " ~/Desktop"
                activate (display dialog "A basic system report has been saved." with title "Successfully Audited" buttons {"OK"} default button 1 with icon 1 giving up after 10)
            else if (reportLevel as text) starts with "3" then
                do shell script "cd " & quoted form of (POSIX path of saveLocation & "System Audits") & "; system_profiler -detailLevel full -xml > " & filename
                if toDesktop is true then do shell script "cd " & quoted form of (POSIX path of saveLocation & "System Audits") & "; cp " & filename & " ~/Desktop"
                activate (display dialog "A full system report has been saved." with title "Successfully Audited" buttons {"OK"} default button 1 with icon 1 giving up after 10)
            end if
            
        on error err
            activate (display dialog err with title "An error prevented the audit" buttons {"OK"} default button 1 with icon 0)
        end try
    end generateSystemReport_


end script
