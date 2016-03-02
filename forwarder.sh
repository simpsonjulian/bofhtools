#!/bin/bash
. env.sh

$GAM_DIR/gam.py all users show forward | grep 'Enabled:true' | awk '{print $2,$3}'
