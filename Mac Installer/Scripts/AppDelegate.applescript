--
--  AppDelegate.applescript
--  Mac Installer
--
--  Created by Olaf Wrieden on 28/10/17.
--  Copyright © 2018 Olaf Wrieden. All rights reserved.
--

script AppDelegate
	property parent : class "NSObject"
    
    -- References
    property SystemTools : class "Tools"
    property InstallHandler : class "Software"
    property FolderCreator : class "FolderCreator"
    
    -- App Details
    property updateHash : "" --> Really the App ID
    property expiryDate : "1577836800" --> Expires 01/01/20
    property registeredTo : ""
    property updateLink : "https://macinstaller.com/latestVersion.txt"
    property helpGuide : "https://macinstaller.com/guide.html"
    property extensionsLink : "http://macinstaller.com/ext/index.php" -- 'https' creates error
    property developerEmail : "support@macinstaller.com"
    property builtForVersion: "10.14"
    property clientNameLbl : missing value
    property expiryLbl : missing value
    property userDataStore : ""
	-- IB Outlets
	property theWindow : missing value
    property tabViewer : missing value
    property installerTabs : missing value
    property activationScreen : missing value
        -- Registration
    property registrationTab : missing value
    property licenseTextBox : missing value
    property usbSelector : missing value
    property registerButton : missing value
    property hostConfirmationLbl : missing value
    property licenceConfirmationLbl : missing value
    property hostSerialConfirmationLbl : missing value
    property registrationVerificationTB : missing value
    
        -- Installer Tab Navigation
    property prevBtn : missing value
    property nextBtn : missing value
    property nextBtnText : missing value
    
    property tableView : missing value
    property deviceSetupBtn : missing value
    property deviceInfoBtn : missing value
    property deviceAdvancedBtn : missing value
        -- Device Information
    property deviceType : missing value
    property computerName : missing value
    property deviceModelLbl : missing value
    property processorDetailsLbl : missing value
    property systemVersionLbl: missing value
	property deviceSerial : missing value
    property memoryInfoLbl: missing value
    property hddDetails : missing value
    property graphicsCard : missing value
    property graphicsVRAM : missing value
    property ipaddressLbl: missing value
    property macaddressLbl: missing value
    property firewallStatusLbl: missing value
    property externalIPLbl : missing value
    property exportToDesktop : missing value
        -- Desktoop Icons
    property desktopHardDrivesChBx : missing value
    property desktopRemovableMediaChBx : missing value
    property desktopServersChBx : missing value
    property desktopExtDisksChBx : missing value
        -- Desktop View Options
    property snapToGridChBx : missing value
    property showItemInfoChBx : missing value
    property showIconPreviewChBx : missing value
        -- Preferences To Save
    property companyNameTextBox : missing value
    property keepLocalInstallers : missing value
    property updatesAtStartup : missing value
    property extensionBox : missing value
    global extensionList
    set extensionList to {}
        -- Mouse Toggle
    property naturalScroll : missing value
        -- Dark Mode
    property darkMenuBarDock : missing value
        -- Dock
    property autoHideDock : missing value
    property magnifyDock : missing value
    property minimiseIntoIcon : missing value
    property lockDockContents : missing value
    property lockDockSize : missing value
    property lockDockPosition : missing value
    property dimHiddenApps : missing value
    property showRecentApps : missing value
        -- Finder Window Action
    property doubleClickWindowTitle : missing value
    property diacriticKeyboard : missing value
    property enableFirewall : missing value
        -- Certificates
    property certificateSelector : missing value
    property certificates : {}
        -- Custom Wallpapers
    property backgroundSelector : missing value
    property backgrounds : {}
        -- QR Viewer
    property appInstallSpinner : missing value
    property appInstallNotice : missing value
    property imgView : missing value
    property verifyBtn : missing value
    property verifyTB : missing value
        -- Further
    property renameTextbox : missing value
        -- Finder Window Settings
    property showFileExtensionsChBx : missing value
    property warnBeforeExtensionChangeChBx : missing value
    property warnBeforeFromIcloudChBx : missing value
    property warnBeforeEmptyingTrashChBx : missing value
    property deleteTrashAfterThrityChBx : missing value
    property keepFoldersOnTopChBx : missing value
    property preferTabsOverWindowsChBx : missing value
    property showLibraryFolderChBx : missing value
    property showHiddenFilesChBx : missing value
    property disableDashboardChBx : missing value
        -- Advanced Settings
    property advancedDisclaimer : missing value
    property advancedFeatures : missing value
    property screenshotType : missing value
    property quickFixResets : missing value
    property systemTaskReset : missing value
    property tmAdvancedOptions : missing value
    property wifiRecoveryOption : missing value
    global welcomeIntro
    set welcomeIntro to ""
    global descIntro
    set descIntro to ""
    
    global mP
    global startDevice
    set startDevice to "N/A"
    
    global urlEnc
    property invalidAttempts : 0
    
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
    --                              BEHAVIOUR                               --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
    
    -------------------------------- STARTUP ---------------------------------
    -- Startup Events
    on applicationWillFinishLaunching_(aNotification)

        try
            -- Set plist File location
            set userDataStore to (current application's NSBundle's mainBundle()'s pathForResource_ofType_("Data", "plist")) as text
            -- Read User Data
            set thePlist to (current application's NSDictionary's dictionaryWithContentsOfFile:userDataStore) as record
            set updateHash to thePlist's licenseInfo
        on error
            activate (display dialog ("Critical application resources are missing. Without these, Mac Installer cannot start." & return & "Please download the latest version from our website or contact us to resolve this issue.") with title "Critical Resource Missing" with icon 0 buttons {"Exit"} default button 1 giving up after 15)
            tell me to quit
        end try
        
        if thePlist's organisationName as text equals "" then
            set registeredTo to "Mac Installer"
        else
            set registeredTo to thePlist's organisationName as text
        end if
        
        --set startDevice to "N/A" --> Really the Hardware ID
        set mP to my mPgeT() --> Mount Point
        set startDevice to my sNgeT(mP) --> Serial Number
        
        -- Get Model Info
        try
            set modelIdentifier to do shell script "system_profiler SPHardwareDataType | grep -E 'Model Identifier' | sed 's/^.*: //'" as text
            if modelIdentifier is equal to "" then error
            on error
            set modelIdentifier to "Unknown"
        end try
        
        if updateHash as text is equal to "" then
            tell me to log "First Time Registration"
            activationScreen's selectTabViewItemAtIndex:2
        else
            try
                if (do shell script "date +%s") is greater than expiryDate then
                    activate
                    set option to button returned of (display dialog ("You are running an out-dated version." & return & return & "Please download the latest version from our website.") with title "Out-dated Version" with icon 0 buttons {"Get Latest Version", "Exit"} default button 2 giving up after 10)
                    if option = "Get Latest Version" then
                        my visitWebsiteBtnClick_(me)
                        tell me to quit
                    else
                        tell me to quit
                    end if
                    tell me to quit
                else
                
                    (*if mP is not equal to "/" then
                        set dataList to paragraphs of (do shell script "system_profiler SPUSBDataType | grep 'Mount Point\\|Serial Number'")
                        set idx to (count dataList)
                        
                        repeat while (idx > 0)
                            set currentItem to item idx of dataList
                            set idx to idx - 1
                            if (currentItem contains mP) then
                                repeat while (idx > 0)
                                    set thisLine to item idx of dataList
                                    if (thisLine contains "Serial Number") then
                                        set oldDelimiters to AppleScript's text item delimiters
                                        set AppleScript's text item delimiters to ": "
                                        set startDevice to text item 2 of thisLine
                                        set AppleScript's text item delimiters to oldDelimiters
                                        set idx to 0
                                    else
                                        set idx to idx - 1
                                    end if
                                end repeat
                            end if
                        end repeat
                    end if*)

                    set k01 to "0f6" as text
                    set k02 to "c59" as text
                    set k03 to "b53" as text
                    set k04 to "684" as text
                    set k05 to "cac" as text
                    set k06 to "d33" as text
                    set k07 to "dd5" as text
                    set k08 to "9d6" as text
                    set k09 to "51c" as text
                    set k10 to "2f6" as text
                    set k11 to "1a2" as text
                    set k12 to "400" as text
                    set k13 to "b0e" as text
                    set k14 to "784" as text
                    set k15 to "9eb" as text
                    set k16 to "67b" as text
                    set k17 to "082" as text
                    set k18 to "e97" as text
                    set k19 to "91b" as text
                    set k20 to "e08" as text
                    set k21 to "0" as text
                    set k22 to "bf9" as text
                    set hashLink to (k15 & k14 & k05 & k12 & k17 & k16 & k04 & k07 & k01 & k06 & k20 & k11 & k22 & k02 & k10 & k03 & k18 & k19 & k09 & k13 & k08 & k21) as text
                    
                    set p01 to "f49" as text
                    set p02 to "7c9" as text
                    set p03 to "df7" as text
                    set p04 to "dd" as text
                    set p05 to "715" as text
                    set p06 to "c0d" as text
                    set p07 to "000" as text
                    set p08 to "dc1" as text
                    set p09 to "bde" as text
                    set p10 to "80d" as text
                    set p11 to "ec5" as text
                    set loadString to (p08 & p03 & p06 & p05 & p02 & p10 & p11 & p09 & p07 & p01 & p04) as text
                    set welcomeIntro to versionHash(4) --> Really act
                    
                    set aboutTabData to "{\"device\":\"" & startDevice & "\",\"update\":\"" & updateHash & "\",\"current\":\"" & welcomeIntro & "\",\"version\":\"" & getCurrentVersion() & "\",\"model\":\"" & modelIdentifier & "\"}" as text
                    set enc to (do shell script "echo '" & aboutTabData & "' | openssl enc -aes-256-cbc -a -K " & hashLink & " -iv " & loadString)
                    set urlEnc to replaceText(enc, "+", "_") as text
                    set urlEnc to replaceText(urlEnc, {return & linefeed, return, linefeed, character id 8233, character id 8232}, "") as text
                    my makeQRForString:("https://macinstaller.com/qr/?qr=" & urlEnc as text) ofWidth:175
                end if
            on error err
                my makeQRForString:("https://macinstaller.com/qr/?qr=error") ofWidth:175
                activate (display dialog "An error occurred while validating your request." & return & return & "Please ensure you are running the latest version." with title "Validation Error" buttons {"OK"} default button 1 with icon 0 giving up after 20)
                tell me to quit
            end try
        end if
    end applicationWillFinishLaunching_
    --Replacing
    on replaceText(someText, oldItem, newItem)
        set {tempTID, AppleScript's text item delimiters} to {AppleScript's text item delimiters, oldItem}
        try
            set {itemList, AppleScript's text item delimiters} to {text items of someText, newItem}
            set {someText, AppleScript's text item delimiters} to {itemList as text, tempTID}
        on error errorMessage number errorNumber -- oops
            set AppleScript's text item delimiters to tempTID
        end try
        return someText
    end replaceText
    -- Generate
    on versionHash(enc)
        set x to ""
        repeat enc times
            set x to x & some item of "PDM4CGFJKSVN6T3ZL7HBEW528RXQAUY9"
        end repeat
        return x
    end versionHash
    -- Termination Events
    on applicationShouldTerminate_(sender)
        return current application's NSTerminateNow
    end applicationShouldTerminate_
    -- Reopen Window on dock icon click
    on applicationShouldHandleReopen_hasVisibleWindows_(theApplication, flag)
        theWindow's makeKeyAndOrderFront_(me)
        return true
    end applicationShouldHandleReopen_hasVisibleWindows_
    -- Final 'Exit Application' button click
    on exitApplicationBtnClick_(sender)
        tell me to quit
    end exitApplicationBtnClick_
    -- Link to open Developer's Website
    on visitWebsiteBtnClick_(sender)
        open location "https://macinstaller.com"
    end visitWebsiteBtnClick_
    -- Link to Help Guide
    on openHelpBtnClick_(sender)
        open location helpGuide
    end openHelpBtnClick_
    -- Verify Locally
    on verifyLocallyBtnClick_(sender)
        open location "https://macinstaller.com/qr/?qr=" & urlEnc as text
    end verifyLocallyBtnClick_
    -- Verify Licence to Launch
    on verifyBtnClick_(sender)
        try
            if invalidAttempts > 2 then
                activate (display dialog "You have entered an incorrect key more than 3 times. Please relaunch the application to generate a new activation request." with title "Exceeded Invalid Attempts" buttons {"Exit"} default button 1 with icon 0 giving up after 10)
                tell me to quit
            end if
            
            if verifyTB's stringValue() as text is equal to welcomeIntro as text then
                deviceSetupBtn's setEnabled_(true)
                deviceInfoBtn's setEnabled_(true)
                deviceAdvancedBtn's setEnabled_(true)
                nextBtnText's setEnabled_(true)
                nextBtn's setHidden_(false)
                activationScreen's selectTabViewItemAtIndex:1
            else
                set invalidAttempts to invalidAttempts + 1
                activate (display dialog "You have entered an incorrect key, please scan the QR code to try again." & return & return & "Remember, you must have an active subscription to use this software." with title "Invalid Verification Key" buttons {"Exit"} default button 1 with icon 0 giving up after 20)
            end if
        on error
            deviceSetupBtn's setEnabled_(false)
            deviceInfoBtn's setEnabled_(false)
            deviceAdvancedBtn's setEnabled_(false)
            nextBtnText's setEnabled_(false)
            nextBtn's setHidden_(true)
            activate (display dialog "An error occurred during validation." & return & return & "Please ensure you are running the latest version." with title "Validation Error" buttons {"OK"} default button 1 with icon 0 giving up after 20)
            tell me to quit
        end try
    end verifyBtnClick_
    -- Post-launch Events
    on applicationDidFinishLaunching_(aNotification)

        my initDeviceInfoTab_() --> Gather Device Information
        my updateView() --> Refresh Components
        
        -- Show Licence Info
        try
            expiryLbl's setStringValue_(updateHash as text) --> setStringValue_("Expires: " & do shell script "date -j -r " & expiryDate & " '+%d %b %Y'" as text)
        end try
        clientNameLbl's setStringValue:registeredTo
        tabViewer's selectTabViewItemAtIndex:1
        
        try
            if versionIsNewer(builtForVersion as text, system version of (get system info) as text) is false then
                activate
                display dialog "This mac is running a version of macOS lower than what is recommended for this application. Certain features may not work as expected." & return & return & "Upgrade to a newer and supported version of macOS to take advantage of all features." with title "Incompatibility Message" with icon 2 buttons {"OK"} default button 1
            end if
        end try
        
        -- Check for updates at startup
        try
            if state of updatesAtStartup as boolean is true then
                tell me to log "Checking for Updates"
                checkForUpdates_(me, false)
            end if
        end try
        
        activate --> Bring app to front
        
    end applicationDidFinishLaunching_
    
    -- Set Timezone of computer
    on updateTimeZone()
        try
            do shell script ("sudo ntpdate -u time.apple.com") with administrator privileges
        on error
            activate (display dialog "An internet connection is required to run this application." & return & return & "Please check that your device has an internet connection and your Firewall is not denying access to the Time Server (time.apple.com)." with title "No Internet Connection" buttons {"Exit"} default button 1 with icon 0 giving up after 20)
            tell me to quit -- Quit Script
        end try
    end updateTimeZone
    
    -- Date Validation
    on validate(expiryDate)
        set today to current date
        --set today to date "Saturday, 31 December 2017 at 11:59:01 PM"
        
        try
            set secondsDiff to expiryDate - today as text
            set daysToExp to (round (secondsDiff / days) rounding up)
            
            if daysToExp < 1 then
                log "Licence Expired! Please purchase a new licence"
                return false
            else
                log "Licence Valid! Expires in " & daysToExp & " day(s)"
                return true
            end if
        on error
            try
                if today does not come before expiryDate then
                    log "Licence Expired! Please purchase a new licence"
                    return false
                else
                    log "LICENCE: VALID - until " & expiryDate
                    return true
                end if
            on error errMsg
                log "LICENCE: FATAL ERROR - " & errMsg
                return false
            end try
        end try
    end validate
    
    -- Get Mount Point of script's USB host
    on mPgeT()
        set myPath to current application's NSBundle's mainBundle()'s bundlePath() as text
        tell application "Finder" to set mP to POSIX path of (disk of item (myPath as POSIX file as text) as alias)
        try
            set tMP to text 1 thru -2 of mP
        on error
            set tMP to mP
        end try
        --log "Script Host: " & tMP as text
        return tMP
    end mPgeT
    
    -- Get Serial Number at Mount Point
    on sNgeT(mP)
        set startDevice to "N/A" --> Really the Hardware ID
        
        if mP is not equal to "/" then
            set dataList to paragraphs of (do shell script "system_profiler SPUSBDataType | grep 'Mount Point\\|Serial Number'")
            set idx to (count dataList)
            
            repeat while (idx > 0)
                set currentItem to item idx of dataList
                set idx to idx - 1
                if (currentItem contains mP) then
                    repeat while (idx > 0)
                        set thisLine to item idx of dataList
                        if (thisLine contains "Serial Number") then
                            set oldDelimiters to AppleScript's text item delimiters
                            set AppleScript's text item delimiters to ": "
                            set startDevice to text item 2 of thisLine
                            set AppleScript's text item delimiters to oldDelimiters
                            set idx to 0
                        else
                            set idx to idx - 1
                        end if
                    end repeat
                end if
            end repeat
        end if
        return startDevice
    end sNgeT
    
    -- DRIVE VALIDATON --
    on validateMe(theVolumePath)
        try
            set scriptDiskMountPoint to theVolumePath
            
            set USB to (do shell script "system_profiler -xml SPUSBDataType" without altering line endings)
            set aString to current application's class "NSString"'s stringWithString:(USB)
            set theData to aString's dataUsingEncoding:(current application's NSUTF8StringEncoding)
            set {theThing, theError} to current application's class "NSPropertyListSerialization"'s propertyListWithData:(theData) options:(0) format:(missing value) |error|:(reference)
            set deviceDetails to current application's class "NSMutableArray"'s new()
            my parseRecursively(theThing's firstObject(), deviceDetails)
            set deviceDetails to deviceDetails as list
            
            set serialNumberMatched to false
            repeat with deviceRecord in deviceDetails
                set {|mount points|:mountPoints, media:media} to deviceRecord & {|mount points|:missing value, media:missing value}
                if (media's class is list) then
                    repeat with thisMedium in media
                        set mountPointFound to (thisMedium's |mount points| contains scriptDiskMountPoint)
                        if (mountPointFound) then exit repeat
                    end repeat
                    else
                    set mountPointFound to ((mountPoints's class is list) and (mountPoints contains scriptDiskMountPoint))
                end if
                if (mountPointFound) then
                    set serialNumberMatched to (deviceRecord's |serial number| is requiredSerialNumber)
                    exit repeat
                end if
            end repeat
            return serialNumberMatched
        on error
            return false --> DO SOMETHING HERE
        end try
    end validateMe
    on parseRecursively(thisThing, deviceDetails)
        try
            set subthings to thisThing's valueForKey:("_items")
            repeat with thisSubthing in subthings
                if (thisSubthing's allKeys()'s containsObject:("_items")) then
                    my parseRecursively(thisSubthing, deviceDetails)
                else
                    -- In El Capitan, 'volumes', if it exists, is a direct property of a device. In Sierra, it's apparently a property of individual 'media' which a device may have.
                    if (thisSubthing's allKeys()'s containsObject:("Media")) then -- Sierra.
                        set theMedia to (thisSubthing's valueForKey:("Media"))
                        set mediaDetails to current application's class "NSMutableArray"'s new()
                        repeat with thisMedium in theMedia
                            set theseDetails to (current application's class "NSDictionary"'s dictionaryWithObjects:({thisMedium's valueForKey:("_name"), thisMedium's valueForKeyPath:("volumes.mount_point")}) forKeys:({"name", "mount points"}))
                            tell mediaDetails to addObject:(theseDetails)
                        end repeat
                        set thisEntry to (current application's class "NSDictionary"'s dictionaryWithObjects:({thisSubthing's valueForKey:("_name"), thisSubthing's valueForKey:("serial_num"), mediaDetails}) forKeys:({"name", "serial number", "media"}))
                    else -- El Capitan.
                        set mountPoints to (thisSubthing's valueForKeyPath:("volumes.mount_point")) -- List of mount points.
                        set thisEntry to (current application's class "NSDictionary"'s dictionaryWithObjects:({thisSubthing's valueForKey:("_name"), thisSubthing's valueForKey:("serial_num"), mountPoints}) forKeys:({"name", "serial number", "mount points"}))
                    end if
                    tell deviceDetails to addObject:(thisEntry)
                end if
            end repeat
        on error
            tell me to quit
        end try
    end parseRecursively
    
    --------------------------------------------------------------------------
    -------------------------------- UPDATES ---------------------------------
    -- Menu Option
    on checkUpdatesBtn_(sender)
        checkForUpdates_(sender, true)
    end checkUpdatesBtn_
    -- Check for Product Updates
    on checkForUpdates_(sender, notifications)
        try
            set currentVersion to (current application's class "NSBundle"'s mainBundle()'s objectForInfoDictionaryKey:"CFBundleShortVersionString") as text
        on error
            activate (display dialog "There was a problem retrieving your version number, please try again later or contact the developer for update information." with title "Version Error" with icon 0 buttons {"Close"} default button 1)
        end try
        
        if SystemTools's checkForInternetConnection_(me) as boolean is true then
            try
                -- Pull new version data
                set versionFile to do shell script ("curl -L '" & updateLink & "'")
                set currentDelimiter to AppleScript's text item delimiters
                set AppleScript's text item delimiters to return
                set versionFileArray to every text item of versionFile
                set newestVersion to item 1 of versionFileArray
                set downloadLink to item 2 of versionFileArray
                set AppleScript's text item delimiters to currentDelimiter
                -- Compare
                if versionIsNewer(currentVersion as text, newestVersion as text) is false then
                    if notifications as boolean is true then
                        display dialog "You are running the lastest version." & return & "Version: " & currentVersion with title "No Updates Available" with icon 1 buttons {"OK"} default button 1
                    end if
                else
                    set option to button returned of (display dialog "A newer version (v" & newestVersion as text & ") is available. You are currently running: v" & currentVersion as text & return & return & "Select Download and sign in to our portal to check if you are eligible for this upgrade." with title "Update Available!" with icon 1 buttons {"Close", "Download"} default button 2)
                    if option = "Download" then
                        open location downloadLink
                    end if
                end if
            on error
                if notifications as boolean is true then
                    set option to button returned of (display dialog "There was an error while checking for updates." & return & "You must have an active account with us to receive updates, try again later." with title "Update Error Encountered" with icon 0 buttons {"Retry", "Close"} default button 2)
                    if option = "Retry" then my checkForUpdates_(me, true)
                end if
            end try
        else
            if notifications as boolean is true then
                activate (display dialog "There was a problem connecting to the internet, please make sure your connection is stable and try again." with title "Connection Failed" with icon 0 buttons {"Close"} default button 1)
            end if
        end if
    end checkForUpdates_
    -- Get current version
    on getCurrentVersion()
        try
            return (current application's class "NSBundle"'s mainBundle()'s objectForInfoDictionaryKey:"CFBundleShortVersionString") as text
        on error
            return "N/A" -- Return false??
        end try
    end getCurrentVersion_
    -- Check if version1 is creater than version2
    on versionIsNewer(version1, version2)
        try
            set sd to AppleScript's text item delimiters
            set AppleScript's text item delimiters to {"."}
            
            -- Gather current version info
            set maj1 to text item 1 of version1 as number
            set min1 to text item 2 of version1 as number
            try
                set bug1 to text item 3 of version1 as number
            on error
                set bug1 to 0
            end try
            
            -- Gather latest version info
            set maj2 to text item 1 of version2 as number
            set min2 to text item 2 of version2 as number
            try
                set bug2 to text item 3 of version2 as number
            on error
                set bug2 to 0
            end try
            
            set AppleScript's text item delimiters to sd
            
            -- Compare current version with latest version
            set isNewer to maj1 < maj2 or (maj1 = maj2 and (min1 < min2 or (min1 = min2 and bug1 < bug2)))
            if isNewer is true then
                return true
            else
                return false
            end if
        end try
    end versionIsNewer
    --------------------------------------------------------------------------
    ------------------------------ TAB CONTROL -------------------------------
    -- Menu Tab Switcher
    on tabSwitcher_(sender)
        if sender's identifier as text = "SetupBtn" then
            tabViewer's selectTabViewItemAtIndex:1 --> Select tab 2
        else if sender's identifier as text = "InfoBtn" then
            tabViewer's selectTabViewItemAtIndex:2 --> Select tab 3
        else if sender's identifier as text = "FixBtn" then
            tabViewer's selectTabViewItemAtIndex:3 --> Select tab 4
        else if sender's identifier as text = "PreferencesMenu" then
            tabViewer's selectTabViewItemAtIndex:4 --> Select tab 5
        else if sender's identifier as text = "LicenceMenu" then
            tabViewer's selectTabViewItemAtIndex:5 --> Select tab 6
        end if
    end tabSwitcher_
    -- Tab Selector Events
    on tabView:tabView didSelectTabViewItem:tabViewItem
        if (tabViewItem's isEqualTo:(installerTabs's tabViewItemAtIndex:0)) as boolean then
            prevBtn's setHidden:1
            nextBtnText's setTitle:"Begin          "
        else if (tabViewItem's isEqualTo:(installerTabs's tabViewItemAtIndex:9)) as boolean then
            nextBtn's setHidden:1
        else
            prevBtn's setHidden:0
            nextBtn's setHidden:0
            nextBtnText's setTitle:"Next Step          "
        end if
    end tabView:didSelectTabViewItem:
    --------------------------------------------------------------------------
    ------------------------------ UPDATE VIEW -------------------------------
    on updateView()
        log "--> Begins Data importing"
        
        try
            -- Pull User File Updates
            set thePlist to (current application's NSDictionary's dictionaryWithContentsOfFile:userDataStore) as record
            companyNameTextBox's setStringValue_(thePlist's organisationName as text)
            keepLocalInstallers's setState_(thePlist's keepInstallersLocally as integer)
            updatesAtStartup's setState_(thePlist's checkUpdatesAtStartup as integer)
            set extensionList to thePlist's browserExtensions as list
            my updateExtComboBox(extensionList)
        end try
        
        -- Set Toggle Controls
        try
            naturalScroll's setSelected:(true) forSegment:((do shell script "if [ $(defaults read NSGlobalDomain com.apple.swipescrolldirection) -eq 1 ]; then echo 0; else echo 1; fi")  as integer)
        end try
        try
            darkMenuBarDock's setSelected:(true) forSegment:((do shell script "if defaults read -g AppleInterfaceStyle > /dev/null 2>&1; then echo 0; else echo 1; fi") as integer)
        end try
        try
            autoHideDock's setSelected:(true) forSegment:((do shell script "if [ $(defaults read com.apple.dock autohide) -eq 1 ]; then echo 0; else echo 1; fi") as integer)
        end try
        try
            magnifyDock's setSelected:(true) forSegment:((do shell script "if [ $(defaults read com.apple.dock magnification) -eq 1 ]; then echo 0; else echo 1; fi") as integer)
        end try
        try
            doubleClickWindowTitle's setSelected:(true) forSegment:((do shell script "if [ $(defaults read NSGlobalDomain AppleActionOnDoubleClick) = \"Minimize\" ]; then echo 0; else echo 1; fi") as integer)
        end try
        try
            minimiseIntoIcon's setSelected:(true) forSegment:((do shell script "if [ $(defaults read com.apple.dock minimize-to-application) -eq 1 ]; then echo 0; else echo 1; fi") as integer)
        end try
        try
            lockDockContents's setSelected:(true) forSegment:((do shell script "if [ $(defaults read com.apple.Dock contents-immutable) -eq 1 ]; then echo 0; else echo 1; fi") as integer)
        end try
        try
            lockDockSize's setSelected:(true) forSegment:((do shell script "if [ $(defaults read com.apple.Dock size-immutable) -eq 1 ]; then echo 0; else echo 1; fi") as integer)
        end try
        try
            lockDockPosition's setSelected:(true) forSegment:((do shell script "if [ $(defaults read com.apple.Dock position-immutable) -eq 1 ]; then echo 0; else echo 1; fi") as integer)
        end try
        try
            dimHiddenApps's setSelected:(true) forSegment:((do shell script "if [ $(defaults read com.apple.Dock showhidden) -eq 1 ]; then echo 0; else echo 1; fi") as integer)
        end try
        try
            showRecentApps's setSelected:(true) forSegment:((do shell script "if [ $(defaults read com.apple.Dock show-recents) -eq 1 ]; then echo 0; else echo 1; fi") as integer)
        end try
        try
            diacriticKeyboard's setSelected:(true) forSegment:((do shell script "if [ $(defaults read -g ApplePressAndHoldEnabled) -eq 1 ]; then echo 0; else echo 1; fi") as integer)
        end try
        try
            enableFirewall's setSelected:(true) forSegment:((do shell script "if [ $(defaults read /Library/Preferences/com.apple.alf globalstate) -ge 1 ]; then echo 0; else echo 1; fi") as integer)
        end try
        
        
        -- Certificate Merger
        try
            set certFolder to ((path to resource "UserContent") as text & "Certificates:" as text) as alias
            tell application "Finder"
                set theCerts to every file of (certFolder) whose name extension is "crt"
                my certificateSelector's removeAllItems() --> Clear all options to reset
                set certificates to {}
                
                if theCerts is not {} then
                    repeat with cert in theCerts
                        copy cert to end of certificates
                        my certificateSelector's addItemWithTitle_(name of (info for cert as alias))
                    end repeat
                end if
            end tell
        on error errMsg
            display dialog "Error: " & errMsg as text & return & "If this error persists, please report it to the developer." with title "Error Detecting Certificates" buttons {"OK"} default button 1 with icon 0
        end try
        
        
        -- Background Merger
        try
            set backgroundFolder to ((path to resource "UserContent") as text & "Backgrounds:" as text) as alias
            tell application "Finder"
                set theBackgrounds to every file of (backgroundFolder) whose name extension is "jpg" or name extension is "png" or name extension is "jpeg"
                my backgroundSelector's removeAllItems() --> Clear all options to reset
                set backgrounds to {}
                
                if theBackgrounds is not {} then
                    repeat with background in theBackgrounds
                        copy background to end of backgrounds
                        my backgroundSelector's addItemWithTitle_(name of (info for background as alias))
                    end repeat
                end if
            end tell
        on error errMsg
            display dialog "Error: " & errMsg as text & return & "If this error persists, please report it to the developer." with title "Error Detecting Backgrounds" buttons {"OK"} default button 1 with icon 0
        end try
        
        -- Desktop Icons
        try
            desktopHardDrivesChBx's setState_(do shell script ("defaults read com.apple.finder ShowHardDrivesOnDesktop"))
        end try
        try
            desktopExtDisksChBx's setState_(do shell script ("defaults read com.apple.finder ShowExternalHardDrivesOnDesktop"))
        end try
        try
            desktopRemovableMediaChBx's setState_(do shell script ("defaults read com.apple.finder ShowRemovableMediaOnDesktop"))
        end try
        try
            desktopServersChBx's setState_(do shell script ("defaults read com.apple.finder ShowMountedServersOnDesktop"))
        end try
        
        -- Desktop View Options
        tell application "Finder"
            try
                try
                    set desktopArrangement to (arrangement of (desktop's window's icon view options)) as text
                    if (desktopArrangement as text) is equal to "«constant ****grda»" or (desktopArrangement as text) is equal to "snap to grid" then
                        snapToGridChBx's setState_(1)
                    else
                        snapToGridChBx's setState_(0)
                    end if
                end try
                
                try
                    set itemsInfo to shows item info of desktop's window's icon view options
                    if itemsInfo is true then
                        showItemInfoChBx's setState_(1)
                    else
                        showItemInfoChBx's setState_(0)
                    end if
                end try
                
                try
                    set itemPreview to shows icon preview of desktop's window's icon view options
                    if itemPreview is true then
                        showIconPreviewChBx's setState_(1)
                    else
                        showIconPreviewChBx's setState_(0)
                    end if
                end try
            end try
        end tell
        
        -- Finder Preferences
        try
            tell application "Finder"
                set theValue to get all name extensions showing of Finder preferences
                if theValue is true then
                    showFileExtensionsChBx's setState_(1)
                else
                    showFileExtensionsChBx's setState_(0)
                end if
            end tell
        end try
        try
            warnBeforeExtensionChangeChBx's setState_(do shell script "if [ $(defaults read com.apple.finder FXEnableExtensionChangeWarning) -eq 1 ]; then echo 1; else echo 0; fi")
        end try
        try
            warnBeforeFromIcloudChBx's setState_(do shell script "if [ $(defaults read com.apple.finder FXEnableRemoveFromICloudDriveWarning) -eq 1 ]; then echo 1; else echo 0; fi")
        end try
        try
            warnBeforeEmptyingTrashChBx's setState_(do shell script "if [ $(defaults read com.apple.finder WarnOnEmptyTrash) -eq 1 ]; then echo 1; else echo 0; fi")
        end try
        try
            deleteTrashAfterThrityChBx's setState_(do shell script "if [ $(defaults read com.apple.finder FXRemoveOldTrashItems) -eq 1 ]; then echo 1; else echo 0; fi")
        end try
        try
            keepFoldersOnTopChBx's setState_(do shell script "if [ $(defaults read com.apple.finder _FXSortFoldersFirst) -eq 1 ]; then echo 1; else echo 0; fi")
        end try
        try
            preferTabsOverWindowsChBx's setState_(do shell script "if [ $(defaults read com.apple.finder FinderSpawnTab) -eq 1 ]; then echo 1; else echo 0; fi")
        end try
        try
            showLibraryFolderChBx's setState_(do shell script "if [[ $(cd ~; ls -lO | grep Library) == *hidden* ]]; then echo 0; else echo 1; fi")
        end try
        try
            showHiddenFilesChBx's setState_(do shell script "if [ $(defaults read com.apple.finder AppleShowAllFiles) = \"YES\" ] || [ $(defaults read com.apple.finder AppleShowAllFiles) -eq 1 ]; then echo 1; else echo 0; fi")
        end try
        try
            disableDashboardChBx's setState_(do shell script "if [ $(defaults read com.apple.dashboard mcx-disabled) -eq 1 ]; then echo 1; else echo 0; fi")
        end try
        
        -- Rename Computer Textbox
        try
            renameTextbox's setStringValue:computerName's stringValue()
        end try
        
        log "--> Finishes Data importing done"
    end updateView_
    --------------------------------------------------------------------------
    ------------------------------ PREFERENCES -------------------------------
    -- Save Settings
    on saveBtn_(sender)
        -- Save Data
        try
            set thePlist to (current application's NSDictionary's dictionaryWithContentsOfFile:userDataStore) as record
            set thePlist's organisationName to companyNameTextBox's stringValue() as text
            set thePlist's keepInstallersLocally to state of keepLocalInstallers as boolean
            set thePlist's checkUpdatesAtStartup to state of updatesAtStartup as boolean
            set cocoaDictionary to current application's NSDictionary's dictionaryWithDictionary:thePlist
            cocoaDictionary's writeToFile:userDataStore atomically:true
            
            clientNameLbl's setStringValue_(companyNameTextBox's stringValue() as text)
        on error errMsg
            display dialog "The data could not be saved because: " & return & errMsg with title "Error Saving Data"
        end try
        updateView() --> Refresh Components
        tabViewer's selectTabViewItemAtIndex_(1) --> Return to Home Screen
    end saveBtn_
    -- Resource Folder
    on openResourceFolder_(sender)
        try
            set thePath to POSIX path of (path to resource "UserContent") as POSIX file
            tell application "Finder" to activate (open (thePath))
        end try
    end openResourceFolder_
    -- Register Licence
    on registerLicenceBtn_(sender)
        -- Save Licence Key Locally
        try
            set updateHash to licenseTextBox's stringValue() as text
            set thePlist to (current application's NSDictionary's dictionaryWithContentsOfFile:userDataStore) as record
            set thePlist's licenseInfo to licenseTextBox's stringValue() as text
            set cocoaDictionary to current application's NSDictionary's dictionaryWithDictionary:thePlist
            cocoaDictionary's writeToFile:userDataStore atomically:true
        on error errMsg
            display dialog "Your licence could not be activated." & return & return with title "An Error Occurred."
        end try
        
        if startDevice is equal to "NA" then
            set startDevice to "N/A"
        end if
        
        -- Get Model Info
        try
            set modelIdentifier to do shell script "system_profiler SPHardwareDataType | grep -E 'Model Identifier' | sed 's/^.*: //'" as text
            if modelIdentifier is equal to "" then error
        on error
            set modelIdentifier to "Unknown"
        end try
        
        try
            --  set hashLink to "9eb 784 cac 400 082 67b 684 dd5 0f6 d33 e08 1a2 bf9 c59 2f6 b53 e97 91b 51c b0e 9d6 0" as text --> Really Enc Key
            set k01 to "0f6" as text
            set k02 to "c59" as text
            set k03 to "b53" as text
            set k04 to "684" as text
            set k05 to "cac" as text
            set k06 to "d33" as text
            set k07 to "dd5" as text
            set k08 to "9d6" as text
            set k09 to "51c" as text
            set k10 to "2f6" as text
            set k11 to "1a2" as text
            set k12 to "400" as text
            set k13 to "b0e" as text
            set k14 to "784" as text
            set k15 to "9eb" as text
            set k16 to "67b" as text
            set k17 to "082" as text
            set k18 to "e97" as text
            set k19 to "91b" as text
            set k20 to "e08" as text
            set k21 to "0" as text
            set k22 to "bf9" as text
            
            set hashLink to (k15 & k14 & k05 & k12 & k17 & k16 & k04 & k07 & k01 & k06 & k20 & k11 & k22 & k02 & k10 & k03 & k18 & k19 & k09 & k13 & k08 & k21) as text
            -- set loadString to "dc1 df7 c0d 715 7c9 80d ec5 bde 000 f49 dd" --> Really IV
            set p01 to "f49" as text
            set p02 to "7c9" as text
            set p03 to "df7" as text
            set p04 to "dd" as text
            set p05 to "715" as text
            set p06 to "c0d" as text
            set p07 to "000" as text
            set p08 to "dc1" as text
            set p09 to "bde" as text
            set p10 to "80d" as text
            set p11 to "ec5" as text
            set loadString to (p08 & p03 & p06 & p05 & p02 & p10 & p11 & p09 & p07 & p01 & p04) as text
            
            set descIntro to versionHash(4)
            set aboutTabData to "{\"device\":\"" & startDevice & "\",\"update\":\"" & licenseTextBox's stringValue() & "\",\"current\":\"" & descIntro & "\",\"version\":\"" & getCurrentVersion() & "\",\"model\":\"" & modelIdentifier & "\"}" as text --> Really string to enc
            set enc to (do shell script "echo '" & aboutTabData & "' | openssl enc -aes-256-cbc -a -K " & hashLink & " -iv " & loadString)
            set urlEnc to replaceText(enc, "+", "_") as text
            set urlEnc to replaceText(urlEnc, {return & linefeed, return, linefeed, character id 8233, character id 8232}, "") as text
            
            open location "https://macinstaller.com/reg/?reg=" & urlEnc as text
            
            -- Next Page
            registrationTab's selectTabViewItemAtIndex:4
        on error err
            open location "https://macinstaller.com/reg/?reg=error"
            activate (display dialog "An error occurred while validating your request." & return & return & "Please ensure you are running the latest version." with title "Validation Error" buttons {"OK"} default button 1 with icon 0 giving up after 20)
            tell me to quit
        end try
    end registerLicenceBtn_
    -- Wants to Register Basic
    on registerBasic_(sender)
        
        set startDevice to "" --> Really the Hardware ID
        set mP to my mPgeT()  --> Mount Point
        
        if mP is not equal to "/" then
            set dataList to paragraphs of (do shell script "system_profiler SPUSBDataType | grep 'Mount Point\\|Serial Number'")
            set idx to (count dataList)
            
            repeat while (idx > 0)
                set currentItem to item idx of dataList
                set idx to idx - 1
                if (currentItem contains mP) then
                    repeat while (idx > 0)
                        set thisLine to item idx of dataList
                        if (thisLine contains "Serial Number") then
                            set oldDelimiters to AppleScript's text item delimiters
                            set AppleScript's text item delimiters to ": "
                            set startDevice to text item 2 of thisLine
                            set AppleScript's text item delimiters to oldDelimiters
                            set idx to 0
                        else
                            set idx to idx - 1
                        end if
                    end repeat
                end if
            end repeat
        end if
        
        -- FOR TESTING ONLY
        --set startDevice to "123"
        --set mP to "123"
        
        if mP is equal to "/" or startDevice is equal to "" then
            display dialog "Basic licences are restricted to one USB drive only, please move the entire application to a USB stick and try again." & return & return & "Note:" & return & "Do not register a Pro licence with a Basic licence key as you will not be able to active this app later on." with title "Invalid USB Drive" with icon 0 buttons {"Exit"} default button 1
            tell me to quit
        else
            --tell me to log "This is a valid drive: " & mP as text & " - " & startDevice as text
            registrationTab's selectTabViewItemAtIndex:1
            hostConfirmationLbl's setStringValue_(mP)
            hostSerialConfirmationLbl's setStringValue_(startDevice)
        end if
    end registerBasic_
    -- Wants to Register Pro
    on registerLicenceKeyTab_(sender)
        registrationTab's selectTabViewItemAtIndex:2
    end registerLicenceKeyTab_
    -- Check Licence Key is not ""
    on formatLicenceKey_(sender)
        set theLicence to do shell script "echo \"" & licenseTextBox's stringValue() & "\" | xargs"
        set charCount to count (theLicence)
        --tell me to log charCount
        if theLicence is equal to "" then
            display dialog "Please enter your license key, in the text field provided. You will not be able to register or activate your software without it." with title "Missing Licence Key" with icon 0 buttons {"OK"} default button 1
        else if charCount is not equal to 20 then
            display dialog "Please enter a valid licence key into the text field." with title "Invalid Licence Key" with icon 0 buttons {"OK"} default button 1
        else
            registrationTab's selectTabViewItemAtIndex:3
        end if
    end formatLicenceKey_
    -- Re-register Licence from Licence Info tab
    on reregisterLicence_(sender)
        tabViewer's selectTabViewItemAtIndex:1
        installerTabs's selectTabViewItemAtIndex:0
        activationScreen's selectTabViewItemAtIndex:2
        registrationTab's selectTabViewItemAtIndex:0
    end reregisterLicence_
    -- Verify Registration
    on verifyRegistrationCode_(sender)
        try
            if invalidAttempts > 2 then
                activate (display dialog "You have entered an incorrect verification code more than 3 times. Please relaunch the application to generate a new registration request." with title "Exceeded Invalid Attempts" buttons {"Exit"} default button 1 with icon 0 giving up after 10)
                tell me to quit
            end if
            
            -- Save Data
            if registrationVerificationTB's stringValue() as text is equal to descIntro as text then
                try
                    set thePlist to (current application's NSDictionary's dictionaryWithContentsOfFile:userDataStore) as record
                    set thePlist's licenseInfo to licenseTextBox's stringValue() as text
                    set cocoaDictionary to current application's NSDictionary's dictionaryWithDictionary:thePlist
                    cocoaDictionary's writeToFile:userDataStore atomically:true
                    expiryLbl's setStringValue_(updateHash as text)
                    deviceSetupBtn's setEnabled_(true)
                    deviceInfoBtn's setEnabled_(true)
                    deviceAdvancedBtn's setEnabled_(true)
                    nextBtnText's setEnabled_(true)
                    nextBtn's setHidden_(false)
                    activationScreen's selectTabViewItemAtIndex:1 -- Show Device Setup Tab
                    tabViewer's selectTabViewItemAtIndex:4 -- Show Preferences Tab (for first-time settings)
                    activate (display dialog "Thank you for registering your license with Mac Installer." & return & return & "We have prepared a Getting Started guide on our website, it will assist you in getting set up." with title "Successfully Registered" buttons {"Begin"} default button 1 with icon 1 giving up after 20)
                on error errMsg
                    display dialog "The data could not be saved. Because: " & return & errMsg with title "Error Saving Data"
                end try
            else
                set invalidAttempts to invalidAttempts + 1
                activate (display dialog "You have entered an incorrect verification code." & return & return & "Remember, you must have an active subscription to use this software." with title "Invalid Verification Code" buttons {"Exit"} default button 1 with icon 0 giving up after 20)
            end if
        on error errMsg
            tell me to log errMsg
            deviceSetupBtn's setEnabled_(false)
            deviceInfoBtn's setEnabled_(false)
            deviceAdvancedBtn's setEnabled_(false)
            nextBtnText's setEnabled_(false)
            nextBtn's setHidden_(true)
            activate (display dialog "An error occurred during registration." & return & return & "Please ensure you are running the latest version." with title "Registration Error" buttons {"OK"} default button 1 with icon 0 giving up after 20)
            tell me to quit
        end try
    end verifyRegistrationCode_
    
    -- Get Latest Extensions
    on pullExtensions_(sender)
        set latestExtensions to my parseDownload()
        if latestExtensions is equal to {} then return
        
        set extensionList to latestExtensions as list --> UPDATE LIST
        my saveExtensions(latestExtensions)  --> SAVE TO FILE
        my updateExtComboBox(latestExtensions) --> UPDATE COMBOBOX
    end pullExtensions_
    -- Extension CSV to List
    on parseDownload()
        try
            set csvData to do shell script ("curl " & extensionsLink & "?l=" & updateHash)
            if csvData as text is equal to "" then error
            
            set startID to "[start]"
            set endID to "[end]"
            
            -- Check Validity
            if csvData does not start with startID or csvData does not end with endID then error
            if csvData starts with startID then
                try
                    set csvData to replaceText(csvData, startID, "")
                end try
            end if
            if csvData ends with endID then
                try
                    set csvData to replaceText(csvData, endID, "")
                end try
            end if
            
            -- Strip into list
            set AppleScript's text item delimiters to {","}
            set keyValueList to (every text item in csvData) as list
            set AppleScript's text item delimiters to ""
            
            -- put every 3rd item into a list and add it to the finalList variable
            set listCount to count of keyValueList
            set finalList to {}
            repeat with i from 1 to listCount by 3
                if (i + 2) is not greater than listCount then
                    set end of finalList to items i thru (i + 2) of keyValueList
                else
                    set end of finalList to items i thru listCount of keyValueList
                end if
            end repeat
            
            return finalList
        on error
            activate (display dialog "Extensions could not be retrieved from the server." & return & return & "Please check that your device has an internet connection and your Firewall is not denying access to macinstaller.com." with title "Unable to Retrieve Extensions" buttons {"OK"} default button 1 with icon 0 giving up after 20)
            return {}
        end try
    end parseDownload
    -- Save Extensions to Plist
    on saveExtensions(newestExtensions)
        -- Save Data
        try
            set thePlist to (current application's NSDictionary's dictionaryWithContentsOfFile:userDataStore) as record
            set thePlist's browserExtensions to newestExtensions as list
            set cocoaDictionary to current application's NSDictionary's dictionaryWithDictionary:thePlist
            cocoaDictionary's writeToFile:userDataStore atomically:true
            display dialog "The latest extensions were added successfully." & return with title "Extensions Added" buttons {"OK"} default button "OK" with icon 1 giving up after 5
        on error errMsg
            display dialog "Extension data could not be saved because: " & return & errMsg with title "Error Saving Data"
        end try
    end saveExtensions
    -- Update Extension ComboBox
    on updateExtComboBox(extList)
        -- Begin Selection
        set showList to {}
        repeat with i from 1 to ((count of extList))
            set end of showList to item 1 of item i of extList
        end repeat
        
        if showList is not equal to {} then
            extensionBox's removeAllItems()
            extensionBox's addItemsWithObjectValues_(showList)
            extensionBox's selectItemAtIndex_(0)
        end if
    end updateExtComboBox
    -------------------------------------------------------



    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
    --                               GENERICS                               --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

    -- Check if File / Folder Exists
    on checkExistence(thePath)
        return ((do shell script "if test -e " & quoted form of (thePath) & "; then echo 1; else echo 0; fi") as integer) as boolean
    end checkExistence
    -- Generic 'App Not Installed' Message
    on appNotInstalledNotice_(appName as text)
        activate (display dialog "To perform this operation, please install " & appName & " and try again." with title (appName & " is not installed") buttons {"Close"} default button 1 with icon 0)
    end appNotInstalledNotice_
    -- Offline QR Code
    on makeQRForString:theString ofWidth:theWidth
        set anImageFilter to current application's CIFilter's filterWithName:"CIQRCodeGenerator"
        anImageFilter's setDefaults()
        set thisURLString to current application's NSString's stringWithString:theString
        set thisData to thisURLString's dataUsingEncoding:(current application's NSUTF8StringEncoding)
        anImageFilter's setValue:thisData forKey:"inputMessage"
        anImageFilter's setValue:"L" forKey:"inputCorrectionLevel"
        set baseImage to anImageFilter's outputImage()
        
        -- make image rep
        set imageRep to current application's NSBitmapImageRep's alloc()'s initWithCIImage:baseImage
        set actualWidth to imageRep's |size|()'s width()
        set actualHeight to imageRep's |size|()'s height()
        set theScale to theWidth / actualWidth
        
        -- make greyscale image rep
        set newRep to current application's NSBitmapImageRep's alloc()'s initWithBitmapDataPlanes:(missing value) pixelsWide:theWidth pixelsHigh:actualHeight * theScale bitsPerSample:8 samplesPerPixel:1 hasAlpha:false isPlanar:false colorSpaceName:(current application's NSCalibratedWhiteColorSpace) bytesPerRow:0 bitsPerPixel:0
        
        -- store graphics state and set new values
        current application's NSGraphicsContext's saveGraphicsState()
        set theContext to current application's NSGraphicsContext's graphicsContextWithBitmapImageRep:newRep
        current application's NSGraphicsContext's setCurrentContext:theContext
        theContext's setShouldAntialias:false
        theContext's setImageInterpolation:(current application's NSImageInterpolationNone)
        
        -- draw from original to new rep
        imageRep's drawInRect:(current application's NSMakeRect(0, 0, theWidth, actualHeight * theScale)) fromRect:(current application's NSZeroRect) operation:(current application's NSCompositeCopy) fraction:(1.0) respectFlipped:false hints:(missing value)
        
        -- restore state and save from new rep
        current application's NSGraphicsContext's restoreGraphicsState()
        set theProps to current application's NSDictionary's dictionaryWithObject:1.0 forKey:(current application's NSImageCompressionFactor)
        set imageData to (newRep's representationUsingType:(current application's NSTIFFFileType) |properties|:theProps)
        imgView's setImage:current application's NSImage's alloc()'s initWithData:imageData
    end makeQRForString:ofWidth:savingTo:
    -- Poke Event Queue
    on fordEvent()
        set theApp to current application's NSApp
        set theMode to current application's NSEventTrackingRunLoopMode
        set theMask to current application's NSAnyEventMask
        repeat
            set theEvent to (theApp's nextEventMatchingMask:theMask untilDate:(missing value) inMode:theMode dequeue:true)
            if theEvent is missing value then exit repeat
            theApp's sendEvent:theEvent
        end repeat
    end fordEvent
    -- Run Folder Creator
    on runFolderCreator_(sender)
        FolderCreator's beginScript_(me)
    end runFolderCreator



    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
    --                             DEVICE SETUP                             --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
    
    ------------------------- APPLICATION INSTALLER --------------------------
    -- Initiate App Installation
    on installApplicationsBtnClick_(sender)
        ----set installerDir to (current application's NSBundle's mainBundle()'s bundlePath() as text & "/Contents/Resources/UserContent/Installers/") as text
        set installerDir to ((path to resource "UserContent") as alias & "Installers:" as text) as alias
        set autoInstallers to (installerDir as text & "Automatic Installers:" as text) as alias
        set localDir to path to startup disk as alias
        set installedAppsMasterList to {}
        
        -- Check if installers folder is found
        if checkExistence(posix path of autoInstallers) then
            log "Installers Folder Found!"
            
            tell application "Finder" to set installerCount to count (get every file of (autoInstallers) whose name extension is "dmg" or name extension is "pkg")
            
            if installerCount < 1 then
                set response to button returned of (display dialog "There are currently no apps for Mac Installer to install. To add applications, go the Resources folder." with title "No Application Files" buttons {"Close", "Add Resources"} default button 2 with icon 1)
                if response is "Add Resources" then
                    openResourceFolder_(me)
                end if

                InstallHandler's installAppsManually_(installerDir) --> Open Manual Installers Folder
                return
            end if
            
            -- User Notification
            appInstallNotice's setHidden:0
            appInstallSpinner's setHidden:0
            appInstallSpinner's startAnimation:me
            
            --my fordEvent()
            
            activate
            set confirmation to button returned of (display dialog "App installations will now take place!\nHang tight, we will notify you when completed." & return & return & "You may be prompted to enter the device administrator's password!" with icon 1 with title "Would you like to continue?" buttons {"Close", "Continue"} default button 2)
            
            if confirmation is equal to "Continue" then
                -- Check if installers should be copied
                if state of keepLocalInstallers as boolean is true then
                    log "Installers must be kept locally, begin copying"
                    InstallHandler's copyInstallersToLocal_({installerDir, localDir})
                    -- To Check Folder Exists Locally: checkExistence(posix path of (localDir & "Installers:" as text)) is false then
                else
                    log "Installers do not need to be kept locally, don't copy."
                end if
                
                -- Begin Installation
                set end of installedAppsMasterList to InstallHandler's installPKGApps_({autoInstallers}) as text --> Install PKG Apps
                set end of installedAppsMasterList to InstallHandler's installDMGApps_({autoInstallers}) as text --> Install DMG Apps
                log "MY DMG LIST:\n" & installedAppsMasterList as text
                
                activate (display dialog ("The following applications were installed:" & return & return & installedAppsMasterList) with title (count of installedAppsMasterList) & " Applications Installed" as text buttons {"Close"} default button 1 with icon 1)
                
                InstallHandler's installAppsManually_(installerDir) --> Open Manual Installers Folder
                
                --> TODO: Show apps installed list and notify if no installers exist
            end if
        else
            activate (display dialog ("The installers folder is not present, this may occur if you have changed folder names. Please contact us for further information.") with title "Critical Folder Not Found" buttons {"Close"} default button 1 with icon 0)
        end if
        
        -- User Notification
        appInstallSpinner's stopAnimation:me
        appInstallSpinner's setHidden:1
        appInstallNotice's setHidden:1
    end installApplicationsBtnClick_
    --------------------------------------------------------------------------
    ------------------------- DESKTOP CUSTOMISATION --------------------------
    -- Visible Icons
    on setDesktopIcons_(sender)
        SystemTools's showDesktopMedia_({desktopHardDrivesChBx's state as boolean, desktopExtDisksChBx's state as boolean, desktopRemovableMediaChBx's state as boolean, desktopServersChBx's state as boolean})
    end setDesktopIcons_
    -- View Options
    on setIconView_(sender)
        SystemTools's setDesktopViewOptions_({snapToGridChBx's state, showItemInfoChBx's state, showIconPreviewChBx's state})
    end setIconView_
    -- Custom Background
    on setBackground_(sender)
        set selectedIndex to backgroundSelector's indexOfSelectedItem as integer + 1 --> Selected Index (0-based)
        if selectedIndex is greater than 0 then
            set theFile to (POSIX path of ((item selectedIndex of backgrounds) as alias) as text) --> Path to Background - TODO: Make sure path is valid
            SystemTools's setDesktopBackground_(theFile) ---> Continue
        end if
    end setBackground_
    -- Built-in Background
    on chooseBackground_(sender)
        tell application "System Preferences" to activate (reveal anchor "DesktopPref" of pane id "com.apple.preference.desktopscreeneffect")
    end chooseBackground_
    --------------------------------------------------------------------------
    ------------------------- FINDER CUSTOMISATION ---------------------------
    -- Finder Window Options
    on setFinderWindowPreferences_(sender)
        SystemTools's setFinderWindowPrefs_({showFileExtensionsChBx's state, warnBeforeExtensionChangeChBx's state, warnBeforeFromIcloudChBx's state, warnBeforeEmptyingTrashChBx's state, deleteTrashAfterThrityChBx's state, keepFoldersOnTopChBx's state, preferTabsOverWindowsChBx's state, showLibraryFolderChBx's state, showHiddenFilesChBx's state, disableDashboardChBx's state})
    end setFinderWindowPreferences_
    -- Mouse Scroll Direction
    on setScrollDirection_(sender)
        SystemTools's naturalScrollDirection_(not naturalScroll's selectedSegment as boolean)
    end setScrollDirection_
    -- Minimise on Double Click
    on setWindowTitleDblClick_(sender)
        SystemTools's doubleClickWindowTitleToMinimise_(not doubleClickWindowTitle's selectedSegment() as boolean)
    end setWindowTitleDblClick_
    -- Firewall Status
    on setFirewall_(sender)
        SystemTools's setFirewallStatus_(not enableFirewall's selectedSegment() as boolean)
        set fwState to do shell script "defaults read /Library/Preferences/com.apple.alf globalstate"
        if (fwState is greater than 0) then
            firewallStatusLbl's setStringValue_("On")
            enableFirewall's setSelected:(true) forSegment:(0)
        else
            firewallStatusLbl's setStringValue_("Off")
            enableFirewall's setSelected:(true) forSegment:(1)
        end if
    end setFirewall_
    -- Accent Keys
    on setRepeatingKeys_(sender)
        SystemTools's repeatingKeyToggle_(not diacriticKeyboard's selectedSegment() as boolean)
    end setRepeatingKeys_
    -- Siri Status
    on openSiriSettings_(sender)
        tell application "System Preferences" to activate (reveal pane id "com.apple.preference.speech")
    end openSiriSettings_
    -- Energy Saver
    on openEnergySaverSettings_(sender)
        tell application "System Preferences" to activate (reveal pane id "com.apple.preference.energysaver")
    end openEnergySaverSettings_
    --------------------------------------------------------------------------
    --------------------------- DOCK CUSTOMISATION ---------------------------
    -- Dark Theme
    on setDarkMenuDock_(sender)
        SystemTools's darkMenuDock_(not darkMenuBarDock's selectedSegment() as boolean)
    end setDarkMenuDock_
    -- Auto Hide
    on setHideDock_(sender)
        SystemTools's autoShowHideDock_(not autoHideDock's selectedSegment() as boolean)
    end setHideDock_
    -- Magnification
    on setDockMagnification_(sender)
        SystemTools's dockMagnification_(not magnifyDock's selectedSegment() as boolean)
    end setDockMagnification_
    -- Minimise into Icon
    on setMinimiseIntoAppIcon_(sender)
        SystemTools's minimiseIntoIcon_(not minimiseIntoIcon's selectedSegment() as boolean)
    end setMinimiseIntoAppIcon_
    -- Dim Hidden
    on dimHiddenAppIcons_(sender)
        SystemTools's dimHiddenApps_(not dimHiddenApps's selectedSegment() as boolean)
    end dimHiddenAppIcons_
    -- Toggle Recents
    on setRecentApps_(sender)
        SystemTools's showDockRecents_(not showRecentApps's selectedSegment() as boolean)
    end setRecentApps_
    -- Add Spacer
    on addDockSpacer_(sender)
        try
            do shell script "defaults write com.apple.dock persistent-apps -array-add '{\"tile-type\"=\"spacer-tile\";}'; killall Dock"
        end try
    end addDockSpacer_
    
    -- Lock Icons
    on setLockDockIcons_(sender)
        SystemTools's lockDockContents_(not lockDockContents's selectedSegment() as boolean)
    end setLockDockIcons_
    -- Lock Size
    on setLockDocksSize_(sender)
        SystemTools's lockDocksSize_(not lockDockSize's selectedSegment() as boolean)
    end setLockDocksSize_
    -- Lock Position
    on setLockDocksPosition_(sender)
        SystemTools's lockDockPosition_(not lockDockPosition's selectedSegment() as boolean)
    end setLockDocksPosition_
    -- Restart Dock
    on restartDock_(sender)
        try
            do shell script "killall Dock"
        end try
    end restartDock_
    -- Reset Dock
    on resetDockBtnClick_(sender)
        SystemTools's resetDock_(me)
    end resetDockBtnClick_
    --------------------------------------------------------------------------
    -------------------------- NETWORK CERTIFICATES --------------------------
    -- Install Certificate
    on installCertBtnClick_(sender)
        set selectedIndex to certificateSelector's indexOfSelectedItem as integer + 1 --> Selected Index (0-based)
        if selectedIndex is greater than 0 then
            set theFile to quoted form of (posix path of ((item selectedIndex of certificates) as alias) as text) --> Path to Certificate  - TODO: Make sure path is valid
            SystemTools's networkCertificateInstall_(theFile) --> Certificate Install Function
        end if
    end installCertBtnClick_
    --------------------------------------------------------------------------
    ---------------------------- NAME & BINDINGS -----------------------------
    -- Refresh Device Name Field
    on refreshDeviceName_(sender)
        try
            computerName's setStringValue_(computer name of (get system info))
            renameTextbox's setStringValue:computerName's stringValue()
        end try
    end refreshDeviceName_
    -- Open Sharing Preferences
    on openSharingSettings_(sender)
        tell application "System Preferences" to activate (reveal pane id "com.apple.preferences.sharing")
    end openSharingSettings_
    -- Open Directory Utility
    on openDirectoryUtility_(sender)
        tell application "Finder" to activate application "Directory Utility"
    end openDirectoryUtility_
    -- Open Users Preferences
    on openUsersAndGroups_(sender)
        tell application "System Preferences" to activate (reveal pane id "com.apple.preferences.users")
    end openUsersAndGroups_
    --------------------------------------------------------------------------
    ------------------------- BROWSER CONFIGURATION --------------------------
    -- Default Web Browser
    on setDefaultWebBrowser_(sender)
        if sender's identifier as text = "defaultChrome" then
            if SystemTools's checkAppIsInstalled_("Google Chrome") as boolean is true then
                SystemTools's changeDefaultBrowser_("Chrome")
                else
                my appNotInstalledNotice_("Google Chrome")
            end if
            else
            SystemTools's changeDefaultBrowser_("Other")
        end if
    end setDefaultWebBrowser_
    -- Startup Page
    on setBrowserStartup_(sender)
        if sender's identifier as text = "startupChrome" then
            if SystemTools's checkAppIsInstalled_("Google Chrome") as boolean is true then
                tell application "Google Chrome" to activate (open location "chrome://settings/onStartup")
                else
                my appNotInstalledNotice_("Google Chrome")
            end if
            else
            tell application "Safari" to activate
            tell application "System Events"
                repeat until visible of process "Safari" is true
                    set visible of process "Safari" to true
                end repeat
                keystroke "," using command down
            end tell
        end if
    end setBrowserStartup_
    -- Import Bookmarks
    on importBookmarkData_(sender)
        
        -- Check if file is present
        try
            set bookmarksFolder to ((path to resource "UserContent") as text & "Bookmarks:" as text) as alias
            
            tell application "Finder"
                set theBookmarks to every file of (bookmarksFolder) whose name extension is "html" --> All .html files
                set bookmarks to {}
                set bookmarkName to {}
                
                if theBookmarks is {} then
                    tell me to log "NO BOOKMARKS FOUND!"
                else
                    repeat with bookmark in theBookmarks
                        copy bookmark as text to end of bookmarks
                        copy (name of (info for bookmark as alias) as text) to end of bookmarkName
                    end repeat
                end if
            end tell
            
            activate
            set theResult to choose from list bookmarkName with title "Which One?" with prompt "Please select a bookmark file to import:" OK button name {"Next"} cancel button name {"None of these"}
            
            if theResult is false then
                set bookmarksFile to false
            else
                set bookmarksFile to POSIX path of (bookmarksFolder) as text & theResult as text
            end if
        on error
            set bookmarksFile to false
        end try
        
        -- If user chooses Chrome
        if sender's identifier as text = "bookmarksChrome" then
            if SystemTools's checkAppIsInstalled_("Google Chrome") as boolean is true then
                if bookmarksFile is not false then
                    -- If a Bookmarks file exists
                    if checkExistence(bookmarksFile) as boolean is true then
                        -- Inform of potential automation
                        set changeConfirm to button returned of (display dialog "This proceedure can be automated but may not be compatible with all versions of Chrome." with title "Would you like to automate this task?" buttons {"Don't Automate", "Automate"} default button "Automate" with icon 1)
                        if changeConfirm is "Automate" then
                            -- User wants to automate
                            SystemTools's importChromeBookmarkData_(bookmarksFile)
                        else
                            -- User does not want to automate
                            tell application "Google Chrome" to activate (open location "chrome://settings/importData")
                        end if
                    else
                        tell application "Google Chrome" to activate (open location "chrome://settings/importData")
                    end if
                else
                    tell application "Google Chrome" to activate (open location "chrome://settings/importData")
                end if
            else
                my appNotInstalledNotice_("Google Chrome")
            end if
            -- User wants file location copy
        else
            -- If a Bookmarks file exists
            if bookmarksFile is false then
                activate (display dialog "You did not select a bookmark file from your resources or none are available." with title "No file selected!" buttons {"Close"} default button 1 with icon 0)
            else
                set the clipboard to (bookmarksFile as text)
                activate (display dialog "The location of the selected bookmarks file has been copied to the clipboard." with title "Copied" buttons {"OK"} default button 1 with icon 1giving up after 5)
            end if
        end if
    end importBookmarkData_
    -- Install Chrome Extension
    on extChromeBtn_(sender)
        set selectedIndex to extensionBox's indexOfSelectedItem as integer + 1 --> Selected Index (0-based)
        if selectedIndex is greater than 0 then
            if item 3 of item selectedIndex of extensionList does not equal "" then
                set theLink to item 3 of item selectedIndex of extensionList
                set theExtension to do shell script ("echo '" & theLink & "' | sed 's:.*/::'")
                
                if SystemTools's checkAppIsInstalled_("Google Chrome") as boolean is true then
                    -- Check if extension is already installed
                    if SystemTools's isChromeExtensionInstalled_(theExtension) as boolean is true then
                        display dialog "The " & extensionBox's objectValueOfSelectedItem as text & " extension is already installed for Google Chrome on this account." with title "Already Installed" buttons {"Close"} default button "Close" with icon 1 giving up after 5
                    else
                        -- Check for internet connection
                        if SystemTools's checkForInternetConnection_(me) as boolean is false then
                            display dialog "There was a problem connecting to the internet, please make sure your connection is stable and try again." with title "No Internet Connection" buttons {"Close"} default button "Close" with icon 1
                        else
                            SystemTools's installChromeExtension_(theLink)
                        end if
                    end if
                else
                    my appNotInstalledNotice_("Google Chrome")
                end if
                
            else
                activate (display dialog "Google Chrome does not support this extension." with title "Unsupported Extension" with icon 1 buttons {"OK"} default button 1)
            end if
        else
            activate (display dialog "Please select a Google Chrome browser extension from the combo box first." with title "Invalid Selection" buttons {"Close"} default button "Close" with icon 1)
        end if
    end extChromeBtn_
    -- Install Safari Extension
    on extSafariBtn_(sender)
        set selectedIndex to extensionBox's indexOfSelectedItem as integer + 1 --> Selected Index (0-based)
        if selectedIndex is greater than 0 then
            if item 2 of item selectedIndex of extensionList does not equal "" then
                set theLink to item 2 of item selectedIndex of extensionList
                set extIdentifier to do shell script ("echo '" & theLink & "' | sed -e 's/.*id=\\(.*\\)-.*/\\1/'")
                set theExtension to "\"Bundle Identifier\" = \"" & extIdentifier & "\";"
                
                -- Check if extension is already installed
                if SystemTools's isSafariExtensionInstalled_(theExtension) as boolean is true then
                    display dialog "The " & extensionBox's objectValueOfSelectedItem as text & " extension is already installed for Safari on this account." with title "Already Installed" buttons {"Close"} default button "Close" with icon 1 giving up after 5
                else
                    -- Check for internet connection
                    if SystemTools's checkForInternetConnection_(me) as boolean is false then
                        display dialog "There was a problem connecting to the internet, please make sure your connection is stable and try again." with title "No Internet Connection" buttons {"Close"} default button "Close" with icon 1
                    else
                        tell application "Safari" to activate (open location theLink)
                    end if
                end if
            else
                activate (display dialog "Safari does not support this extension." with title "Unsupported Extension" with icon 1 buttons {"OK"} default button 1)
            end if
        else
            display dialog "Please select a Safari browser extension from the combo box first." with title "Invalid Selection" buttons {"Close"} default button "Close" with icon 1
        end if
    end extSafariBtn_
    --------------------------------------------------------------------------
    -------------------------- APP STORE SHORTCUTS ---------------------------
    -- One Drive
    on appStoreOneDrive_(sender)
        tell application "System Events" to open location "macappstore://itunes.apple.com/nz/app/onedrive/id823766827?mt=12" --> Link to OneDrive
    end appStoreOneDrive_
    -- One Note
    on appStoreOneNote_(sender)
        tell application "System Events" to open location "macappstore://itunes.apple.com/nz/app/microsoft-onenote/id784801555?mt=12" --> Link to OneNote
    end appStoreOneNote_
    -- The Unarchiver
    on appStoreTheUnarchiver_(sender)
        tell application "System Events" to open location "macappstore://itunes.apple.com/nz/app/the-unarchiver/id425424353?mt=12" --> Link to The Unarchiver
    end appStoreTheUnarchiver_
    -- Xcode
    on appStoreXcode_(sender)
        tell application "System Events" to open location "macappstore://itunes.apple.com/nz/app/xcode/id497799835?mt=12" --> Link to Xcode
    end appStoreXcode_
    -- GarageBand
    on appStoreGarageBand_(sender)
        tell application "System Events" to open location "macappstore://itunes.apple.com/nz/app/garageband/id682658836?mt=12" --> Link to GarageBand
    end appStoreGarageBand_
    -- iMovie
    on appStoreiMovie_(sender)
        tell application "System Events" to open location "macappstore://itunes.apple.com/nz/app/imovie/id408981434?mt=12" --> Link to iMovie
    end appStoreiMovie_
    -- Logic Pro X
    on appStoreLogicProX_(sender)
        tell application "System Events" to open location "macappstore://itunes.apple.com/nz/app/logic-pro-x/id634148309?mt=12" --> Link to Logic Pro X
    end appStoreLogicProX_
    -- Final Cut Pro
    on appStoreFinalCutPro_(sender)
        tell application "System Events" to open location "macappstore://itunes.apple.com/nz/app/final-cut-pro/id424389933?mt=12" --> Link to Final Cut Pro
    end appStoreFinalCutPro_
    --------------------------------------------------------------------------
    
    
    
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
    --                              DEVICE INFO                             --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
    
    --------------------------- DEVICE INFORMATION ---------------------------
    -- Gather Mac Information
    on initDeviceInfoTab_()
        -- Overview Group
        --deviceType's setStringValue_(do shell script "system_profiler SPHardwareDataType | grep -E 'Model Name' | sed 's/^.*: //'" as text)
        try
            computerName's setStringValue_(computer name of (get system info) as text)
        end try
        try
            deviceModelLbl's setStringValue_(do shell script "system_profiler SPHardwareDataType | grep -E 'Model Identifier' | sed 's/^.*: //'" as text)
        end try
        try
            processorDetailsLbl's setStringValue_(do shell script "system_profiler SPHardwareDataType | grep -A1 'Processor Name' | sed 's/^.*: //' | tr '\n' ' '" as text)
        end try
        try
            systemVersionLbl's setStringValue_("macOS " & system version of (get system info) as text)
        end try
        try
            deviceSerial's setStringValue_(do shell script "system_profiler SPHardwareDataType | grep 'Serial Number' | awk '{print $4}'" as text)
        end try
        try
            memoryInfoLbl's setStringValue_((physical memory of (get system info) / 1024) as text & " GB" as text)
        end try
            
        
        try
            graphicsCard's setStringValue_(do shell script "system_profiler SPDisplaysDataType | grep 'Chipset Model' | sed 's/^.*: //'" as text)
        end try
        try
            graphicsVRAM's setStringValue_(do shell script "system_profiler SPDisplaysDataType | grep 'VRAM' | sed 's/^.*: //'" as text)
        end try
        
        
        try
            ipaddressLbl's setStringValue_(IPv4 address of (get system info) as text)
        end try
        try
            macaddressLbl's setStringValue_(primary Ethernet address of (get system info) as text)
        end try
        try
            externalIPLbl's setStringValue_(do shell script "curl api.ipify.org; echo" as text)
        end try
        try
            set firewallStatus to do shell script "defaults read /Library/Preferences/com.apple.alf globalstate" as text
            if firewallStatus is equal to "0" then
                set firewallStatus to "Off"
            else if firewallStatus is equal to "1" then
                set firewallStatus to "On"
            else if firewallStatus is equal to "2" then
                set firewallStatus to "On - Essential Services Only"
            else
                set firewallStatus to "Unreachable"
            end if
            firewallStatusLbl's setStringValue_(firewallStatus as text)
        end try
        
        try
            set totalSpace to do shell script "df -hg | sed -n 2p | awk '{print $2}'" as text
            set usedSpace to do shell script "df -hg | sed -n 2p | awk '{print $3}'" as text
            set usedPercentage to do shell script "df -hg | sed -n 2p | awk '{print $5}'" as text
            hddDetails's setStringValue_(usedSpace & "GB / " & totalSpace & "GB (" & usedPercentage & " full)" as text)
        end try
    end initDeviceInfoTab_
    -- Export System Report
    on generateSystemReport_(sender)
        activate
        set theResult to button returned of (display dialog "The system is about to export a System Information Audit. This may take several minutes." with title "Continue?" buttons {"Cancel", "Proceed"} default button "Proceed" with icon 1)
        if theResult is equal to "Proceed" then
            SystemTools's generateSystemReport_(exportToDesktop's state as boolean)
        end if
    end generateSystemReport_
    --------------------------------------------------------------------------
    
    
    
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
    --                            ADVANCED TOOLS                            --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
    
    ------------------------------ ADVANCED TAB ------------------------------
    -- Advanced Disclaimer
    on advancedDisclaimerBtnClick_(sender)
        set theState to state of advancedDisclaimer
        advancedFeatures's setHidden_(not theState as boolean)
    end advancedDisclaimerBtnClick_
    -- Change Screenshot Filename
    on changeScreenshotFile_(sender)
        if (screenshotType's indexOfSelectedItem as integer) is less than 0 then
            activate (display dialog "Please select a file extension from the combo box first." with title "Invalid Selection" buttons {"Close"} default button "Close" with icon 1)
            else
            try
                set selectedType to screenshotType's itemObjectValueAtIndex_(screenshotType's indexOfSelectedItem as integer)
                do shell script "defaults write com.apple.screencapture type " & selectedType as text
                do shell script "killall SystemUIServer"
                log "Screenshot file extension has changed to " & selectedType
            end try
        end if
    end changeScreenshotFile_
    -- Change Screenshot Location
    on changeScreenshotLocation_(sender)
        try
            set currentLocation to (do shell script "defaults read com.apple.screencapture location") as text
            set changeConfirmed to button returned of (display dialog "Screenshots are currently saving to:" & return & currentLocation & return & return & "Would you like to change this location?" with title "Change Location?" buttons {"Cancel", "Yes"} default button 2 with icon 1)
            if changeConfirmed is "Yes" then
                set theOutputFolder to POSIX path of (choose folder with prompt "Please select an output folder" default location currentLocation)
                do shell script "defaults write com.apple.screencapture location " & quoted form of theOutputFolder as text
                do shell script "killall SystemUIServer"
                log ("The Location has been updated!")
            end if
        on error err
            log "There was an error : " & err
        end try
    end changeScreenshotLocation_
    -- Execute Quick Fix Action
    on applyQuickFix_(sender)
        if (quickFixResets's indexOfSelectedItem as integer) is less than 0 then
            activate (display dialog "Please select a quick fix from the combo box first." with title "Invalid Selection" buttons {"Close"} default button "Close" with icon 1)
            else
            set selectedReset to quickFixResets's itemObjectValueAtIndex_(quickFixResets's indexOfSelectedItem as integer) as text
            
            if selectedReset is equal to "Reset Launchpad" then
                SystemTools's resetLaunchpad_(me)
            else if selectedReset is equal to "Reset Dock Icons" then
                SystemTools's resetDock_(me)
            else if selectedReset is equal to "Reset Spotlight Position" then
                SystemTools's resetSpotlightPosition_(me)
            else if selectedReset is equal to "Empty the Trash" then
                SystemTools's emptyTheTrash_(me)
            else
                log "There was an error"
            end if
        end if
    end applyQuickFix_
    -- Execute System Task Action
    on applySystemTaskReset_(sender)
        if (systemTaskReset's indexOfSelectedItem as integer) is less than 0 then
            activate (display dialog "Please select a system reset from the combo box first." with title "Invalid Selection" buttons {"Close"} default button "Close" with icon 1)
            else
            set selectedReset to systemTaskReset's itemObjectValueAtIndex_(systemTaskReset's indexOfSelectedItem as integer) as text
            
            if selectedReset is equal to "Flush DNS Cache" then
                SystemTools's flushDNS_(me)
            else if selectedReset is equal to "Clear Temp Files" then
                SystemTools's deleteTempFiles_(me)
            else if selectedReset is equal to "Clear System Logs" then
                SystemTools's deleteAllSystemLogs_(me)
            else
                log "There was an error"
            end if
        end if
    end applySystemTaskReset_
    -- Open Time Machine Preferences
    on openTimeMachineSettings_(sender)
        tell application "System Preferences" to activate (reveal pane id "com.apple.prefs.backup")
    end openTimeMachineSettings_
    -- Time Machine Options
    on tmOptionsExecute_(sender)
        if (tmAdvancedOptions's indexOfSelectedItem as integer) is less than 0 then
            activate (display dialog "Please select a Time Machine setting from the combo box first." with title "Invalid Selection" buttons {"Close"} default button "Close" with icon 1)
        else
            set selectedAction to tmAdvancedOptions's itemObjectValueAtIndex_(tmAdvancedOptions's indexOfSelectedItem as integer) as text
            
            if selectedAction is equal to "Require AC power to back up" then
                do shell script "defaults write com.apple.TimeMachine RequiresACPower 1"
            else if selectedAction is equal to "Don't require AC power" then
                do shell script "defaults write com.apple.TimeMachine RequiresACPower 0"
            else if selectedAction is equal to "Offer new backup disks" then
                do shell script "defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool NO"
            else if selectedAction is equal to "Don't offer new backup disks" then
                do shell script "defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool YES"
            else
                log "There was an error"
            end if
        end if
    end tmOptionsExecute_
    -- Recover Wi-Fi Password
    on wifiPasswordRecory_(sender)
        if (wifiRecoveryOption's indexOfSelectedItem as integer) is less than 0 then
            activate (display dialog "Please select a recovery option from the combo box first." with title "Invalid Selection" buttons {"Close"} default button "Close" with icon 1)
        else
            set selectedOption to wifiRecoveryOption's itemObjectValueAtIndex_(wifiRecoveryOption's indexOfSelectedItem as integer) as text
            log "The user wants to: " & selectedOption
            
            -- Recover for current connection
            if selectedOption is equal to "Current Wi-Fi" then
                SystemTools's recoverCurrentWifiPass_(me)
            -- Recover for earlier connection
            else if selectedOption is equal to "Earlier Wi-Fi" then
                SystemTools's recoverEarlierWifiPass_(me)
            else
                log "There was an error"
            end if
        end if
    end wifiPasswordRecory_
    --------------------------------------------------------------------------
end script
