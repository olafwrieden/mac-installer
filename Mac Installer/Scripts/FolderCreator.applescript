--
--  Tools.applescript
--  Mac Installer
--
--  Created by Olaf Wrieden on 01/01/18.
--  Copyright © 2018 Olaf Wrieden. All rights reserved.
--
script FolderCreator
    
    property parent : class "AppDelegate"

    -- Subject Lists
    property year09Subfolders : {"Art", "Chinese", "Design & Visual Communication", "English", "Food Technology", "Hard Materials", "Mathematics", "Music", "Physical & Health Education", "Science", "Social Studies", "Spanish", "Te Reo Maori"}

    property year10Subfolders : {"Art", "Classical Civilisations", "Design & Visual Communication", "Digital Technology", "Drama", "English", "Food Technology", "Investigate Geography", "Materials Technology", "Mathematics", "Music", "Physical & Health Education", "Science", "Services Academy", "Social Studies", "Spanish", "Te Reo Maori"}

    property year11Subfolders : {"Business Studies", "Design & Photography", "Design & Visual Communication", "Digital Technology", "Drama", "English", "English Language (ESOL)", "Geography", "History", "Home Economics", "Materials Technology", "Mathematics & Statistics", "Music", "Physical Education", "Primary Industries", "Science", "Sculpture", "Services Academy", "Spanish", "Te Reo Maori", "Visual Arts"}

    property year12Subfolders : {"Automotive Engineering", "Biology", "Building & Construction", "Business Studies", "Chemistry", "Design", "Design & Visual Communication", "Digital Technology", "Drama", "Earth & Space Science", "English", "English for Academic Purposes (EAP)", "English Language (ESOL)", "Furniture Making", "Geography", "History", "Hospitality & Catering", "Mathematics & Statistics", "Mathematics & Statistics Mechanical", "Mechanical Engineering", "Media Studies", "Music", "Outdoor Education", "Painting", "Performing Arts Technology", "Photography", "Physical Education", "Physics", "Primary Industries", "Services Academy", "Spanish", "Sport & Outdoor Education", "Te Reo Maori", "Technology Metal", "Tourism"}

    property year13Subfolders : {"Art History", "Biology", "Building & Construction", "Business Studies", "Chemistry", "Design & Visual Communication", "Digital Technology", "Drama", "English", "English for Academic Purposes (EAP)", "English Language (ESOL)", "Geography", "History", "Hospitality & Catering", "Mathematics & Statistics", "Mathematics & Statistics Calculus", "Media Studies", "Music", "Performing Arts Technology", "Physical Education", "Physics", "Services Academy", "Spanish", "Sport Studies", "Te Reo Maori", "Tourism", "Visual Arts"}


    -- Initialise Folder Creator
    on beginScript_(args)
        if (do shell script "date +%s") is greater than "1577836800" then
            activate
            set option to button returned of (display dialog "You are using an outdated version of the folder creator. This could result in the creation of an incorrect folder structure." with title "Outdated Version" with icon 2 buttons {"Exit", "Request New Version", "Proceed Anyway"} default button 3)
            if option = "Request New Version" then
                do shell script ("open 'mailto:support@macinstaller.com?subject=Request%20-%20New%20Subject%20Folder%20Creator'")
                return False
            else if option = "Exit" then
                return False
            end if
        end if
        
        -- Gather User Information
        
        -- Get First Name
        set firstName to text returned of (display dialog "Enter your first name:" with title "BYOD Subject Folder Creator" default answer "" with icon 1) as text
        repeat while firstName = ""
            set firstName to text returned of (display dialog "Enter your first name:" with title "BYOD Subject Folder Creator" default answer "" with icon 1) as text
        end repeat
        set firstName to toTitleCase(firstName) as text
        
        -- Get Last Name
        set lastName to text returned of (display dialog "Enter your last name:" with title "BYOD Subject Folder Creator" default answer "" with icon 1) as text
        repeat while lastName = ""
            set lastName to text returned of (display dialog "Enter your last name:" with title "BYOD Subject Folder Creator" default answer "" with icon 1) as text
        end repeat
        set lastName to toTitleCase(lastName) as text
        
        -- Get Year Level
        set yearLevel to (choose from list {9, 10, 11, 12, 13} with prompt "Select your year level:" with title "BYOD Subject Folder Creator") as text
        
        -- Get Form Class
        set formClass to text returned of (display dialog "Enter your form class (without year level e.g. WI):" with title "BYOD Subject Folder Creator" default answer "" with icon 1) as text
        repeat while formClass = ""
            set formClass to text returned of (display dialog "Enter your form class (without year level e.g. WI):" with title "BYOD Subject Folder Creator" default answer "" with icon 1) as text
        end repeat
        set formClass to do shell script ("echo " & formClass & " | tr a-z A-Z;") as text
        
        -- Determine which subfolders are needed
        if yearLevel = "10" then
            set localList to year10Subfolders
            else if yearLevel = "11" then
            set localList to year11Subfolders
            else if yearLevel = "12" then
            set localList to year12Subfolders
            else if yearLevel = "13" then
            set localList to year13Subfolders
            else
            set localList to year09Subfolders
        end if
        
        set folderLocation to path to desktop
        set masterFolder to "Year " & yearLevel
        
        try
            tell application "Finder"
                if exists folder masterFolder of folderLocation then
                    activate
                    set result to button returned of (display dialog "WARNING:" & return & "A folder of the same name already exists on the Desktop and may contain data which will be erased if you choose to 'Replace'!" & return & return & "Select 'Rename' to keep the existing folder and create a new one." buttons {"Replace", "Rename"} default button 2 with icon 1 with title "Folder already exists") as text
                    if result is equal to "Rename" then
                        set name of folder masterFolder of desktop to masterFolder & " OLD " & (do shell script "date '+%d/%m/%y at %H-%M-%S'")
                        my folderMaker(folderLocation, masterFolder, localList, yearLevel, formClass, lastName, firstName)
                    else if result is equal to "Replace" then
                        delete folder masterFolder of desktop
                        my folderMaker(folderLocation, masterFolder, localList, yearLevel, formClass, lastName, firstName)
                    end if
                else
                    my folderMaker(folderLocation, masterFolder, localList, yearLevel, formClass, lastName, firstName)
                end if
            end tell
        on error errMsg
            activate
            display dialog "ERROR: " & errMsg with title "Error Encountered" with icon 0
        end try
    end beginScript_

    -- Make Folder
    on folderMaker(folderLocation, masterFolder, localList, yearLevel, formClass, lastName, firstName)
        try
            tell application "Finder"
                set masterFolder to (make new folder at folderLocation with properties {name:masterFolder} with replacing)
                repeat with subject in localList
                    make new folder at masterFolder with properties {name:yearLevel & formClass & " " & subject & " " & lastName & " " & firstName}
                end repeat
                set current view of container window of masterFolder to list view
                my functionSuccessful("Your " & "Year " & yearLevel & " folder was successfully created at location:" & return & POSIX path of folderLocation)
            end tell
        on error errMsg
            activate
            display dialog "ERROR: " & errMsg with title "Error Encountered" with icon 0
        end try
    end folderMaker

    -- Title Case Function
    on toTitleCase(inputString)
        try
            set TheString to do shell script "echo " & inputString & " | tr '[A-Z]' '[a-z]'"
            set wordsofTheString to words of TheString as list
            set TotalCount to count of wordsofTheString
            set theCount to 1
            repeat until theCount is greater than TotalCount
                set theWord to item theCount of wordsofTheString
                set theChars to characters of theWord as list
                set Capital to item 1 of theChars
                set item 1 of theChars to do shell script "echo " & Capital & " | tr '[a-z]' '[A-Z]'"
                if theCount is less than TotalCount then
                    set theWord to (theChars as string) & " "
                    else
                    set theWord to (theChars as string)
                end if
                set item theCount of wordsofTheString to theWord
                set theCount to theCount + 1
            end repeat
            set TheString to wordsofTheString as string
            return TheString
        end try
    end toTitleCase

    -- Function to display if operation was successful
    on functionSuccessful(confirmationString)
        activate
        display dialog confirmationString with title "Success" buttons {"Done"} default button 1 with icon 1 giving up after 5
    end functionSuccessful


end script
