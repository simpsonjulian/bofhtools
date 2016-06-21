SAAS Admin Scripts
======

Scripts for Google Apps Manager, and other things

## User provisioning scripts
* `create_user.sh`: Create a Google Apps user, email them, put them in a 2FA exception group
* `remove_user.sh`: Start the process (currently using CloudPages) to remove the user (and keep backups)
* `dropbox.sh`: Add or remove users in DropBox.
* `trello.sh`: Invite a user to your Trello organisation
* `slack.sh`: Inite a user to your Slack organisation
* `aws_user.sh`: Add an IAM user to Amazon Web Services

## Misc scripts
* `forwarder.sh`: report on who is forwarding email
* `inactive_users.sh`: report on who isn't using their accounts
