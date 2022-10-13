# disable spotlight indexing
echo "Disabling Spotlight indexing..."
sudo mdutil -i off -a

# create new admin
echo "Creating admin user..."
sudo /usr/bin/dscl . -create /Users/guiadmin
sudo /usr/bin/dscl . -create /Users/guiadmin UserShell /bin/bash
sudo /usr/bin/dscl . -create /Users/guiadmin RealName "GUI Admin"
sudo /usr/bin/dscl . -create /Users/guiadmin UniqueID 1013
sudo /usr/bin/dscl . -create /Users/guiadmin PrimaryGroupID 80
sudo /usr/bin/dscl . -create /Users/guiadmin NFSHomeDirectory /Users/guiadmin
sudo /usr/bin/dscl . -passwd /Users/guiadmin gui123
sudo /usr/bin/dscl . -append /Groups/admin GroupMembership guiadmin

# create their preferences directory
echo "Skipping Setup Assistant..."
sudo mkdir -p /Users/guiadmin/Library/Preferences
sudo chown -R 1013 /Users/guiadmin
# login as new admin to trigger some first-login actions (required for
# `defaults` to work
sudo su -l guiadmin &
# we want to skip as many setup things as possible
sw_vers=$(sw_vers -productVersion)
sw_build=$(sw_vers -buildVersion)
sudo -u guiadmin defaults write com.apple.SetupAssistant.managed SkipAppearance -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant.managed SkipCloudSetup -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant.managed SkipiCloudStorageSetup -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant.managed SkipPrivacySetup -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant.managed SkipSiriSetup -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant.managed SkipTrueTone -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant.managed SkipScreenTime -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant.managed SkipTouchIDSetup -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant.managed SkipFirstLoginOptimization -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant.managed DidSeeCloudSetup -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant.managed LastPrivacyBundleVersion "2"
sudo -u guiadmin defaults write com.apple.SetupAssistant.managed LastSeenCloudProductVersion "${sw_vers}"
sudo -u guiadmin defaults write com.apple.SetupAssistant.managed LastSeenDiagnosticsProductVersion "${sw_vers}"
sudo -u guiadmin defaults write com.apple.SetupAssistant.managed LastSeenSiriProductVersion "${sw_vers}"
sudo -u guiadmin defaults write com.apple.SetupAssistant.managed LastSeenBuddyBuildVersion "${sw_build}"      
sudo -u guiadmin defaults write com.apple.SetupAssistant SkipAppearance -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant SkipCloudSetup -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant SkipiCloudStorageSetup -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant SkipPrivacySetup -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant SkipSiriSetup -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant SkipTrueTone -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant SkipScreenTime -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant SkipTouchIDSetup -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant SkipFirstLoginOptimization -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant DidSeeCloudSetup -bool true
sudo -u guiadmin defaults write com.apple.SetupAssistant LastPrivacyBundleVersion "2"
sudo -u guiadmin defaults write com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
sudo -u guiadmin defaults write com.apple.SetupAssistant LastSeenDiagnosticsProductVersion "${sw_vers}"
sudo -u guiadmin defaults write com.apple.SetupAssistant LastSeenSiriProductVersion "${sw_vers}"
sudo -u guiadmin defaults write com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"      

## adding elastic agent
curl -L -O https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-8.4.3-darwin-x86_64.tar.gz
tar xzvf elastic-agent-8.4.3-darwin-x86_64.tar.gz
cd elastic-agent-8.4.3-darwin-x86_64
sudo ./elastic-agent install --url=https://a3d5eb79fcb741e2af3179ea7138e470.fleet.europe-west1.gcp.cloud.es.io:443 --enrollment-token=R0FNOXhvTUJyRElaN1lKY2ZFNGE6QWd3Q2ZHTUxUbUdGaUxha1doV0xsQQ==

# allow remote access for new admin
echo "Enabling remote access..."
sudo rm -f /Library/Preferences/com.apple.windowserver.plist
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -access -off -restart -agent -privs -all -allowAccessFor -allUsers
# Reverse tunnel to screen share port
echo "Opening tunnel..."
mkdir /tmp/gui
curl -o /tmp/gui/z.$$ https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-darwin-amd64.zip && (cd /tmp/gui && unzip /tmp/gui/z.$$) && rm /tmp/gui/z.$$
/tmp/gui/ngrok authtoken --config /tmp/gui/ngrok.yml 27CC6ppM3Rqnc26fR4hUjcOQByn_4Spr6gUi7w3o8mVn8Pevo
/tmp/gui/ngrok tcp 5900 -log=stdout --config /tmp/gui/ngrok.yml
