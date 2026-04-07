on run {daemon_file, agent_file, user}

  set sh1 to "echo " & quoted form of daemon_file & " > /Library/LaunchDaemons/com.kdesk.desktop_service.plist && chown root:wheel /Library/LaunchDaemons/com.kdesk.desktop_service.plist;"

  set sh2 to "echo " & quoted form of agent_file & " > /Library/LaunchAgents/com.kdesk.desktop_server.plist && chown root:wheel /Library/LaunchAgents/com.kdesk.desktop_server.plist;"

  set sh3 to "mkdir -p /var/root/Library/Preferences/com.kdesk.desktop && cp -rf /Users/" & user & "/Library/Preferences/com.kdesk.desktop/RustDesk.toml /var/root/Library/Preferences/com.kdesk.desktop/;"

  set sh4 to "mkdir -p /var/root/Library/Preferences/com.kdesk.desktop && cp -rf /Users/" & user & "/Library/Preferences/com.kdesk.desktop/RustDesk2.toml /var/root/Library/Preferences/com.kdesk.desktop/;"

  set sh5 to "launchctl load -w /Library/LaunchDaemons/com.kdesk.desktop_service.plist;"

  set sh to sh1 & sh2 & sh3 & sh4 & sh5

  do shell script sh with prompt "RustDesk wants to install daemon and agent" with administrator privileges
end run
