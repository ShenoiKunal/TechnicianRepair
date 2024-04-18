#!/bin/sh

#Create Array of programs to keep in Dock
declare -a apps=(
    '/System/Applications/Launchpad.app'
    '/Applications/Safari.app'
    '/Applications/Firefox.app'
    '/System/Applications/Messages.app'
    '/System/Applications/FaceTime.app'
);

#Function to add apps to Dock from Array
function add_app_to_dock {
    app="${1}"
	
    #If app exists in directory, continue
    if [ -d "${app}" ]; then
        echo "$app added to the Dock."

        defaults write com.apple.dock persistent-apps -array-add "<dict>
                <key>tile-data</key>
                <dict>
                    <key>file-data</key>
                    <dict>
                        <key>_CFURLString</key>
                        <string>${app}</string>
                        <key>_CFURLStringType</key>
                        <integer>0</integer>
                    </dict>
                </dict>
            </dict>"
    else
        echo "ERROR: Application $1 not found."
    fi
}

#Clear apps in Dock
defaults delete com.apple.dock persistent-apps

#Add apps to Dock from Array
for app in "${apps[@]}"; do
    add_app_to_dock "$app"
done

#Restart dock to initiate changes
killall Dock

#Update macOS
sudo softwareupdate -i -a -R
