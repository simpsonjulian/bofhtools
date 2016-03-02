#!/bin/bash

recipient=$1
subject=$2
message=$3

cat <<-EOF | /usr/bin/osascript
  tell application "Mail"
    make new outgoing message with properties {visible:true,¬
    subject:"$subject",content:"$message"}
    tell result
        make new to recipient with properties {address:"$recipient"}
    end tell
end tell
EOF
