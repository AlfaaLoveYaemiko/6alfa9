#!/bin/bash
# Pterodactyl-style entrypoint.
#
# Pterodactyl panel sets $STARTUP to whatever the operator typed in the
# "Startup Command" field (with {{VAR}} placeholders for egg variables).
# We expand those placeholders, print the resolved command, then exec it.

cd /home/container || exit 1

# Print a banner so operators can confirm which yolk is running.
echo "Container@6alfa9: $(uname -srm)"
echo "Container@6alfa9: python=$(python3 --version 2>&1)  chromium=$(chromium --version 2>&1 | head -1)  chromedriver=$(chromedriver --version 2>&1 | head -1)"

# Convert {{VAR}} -> ${VAR} so the shell expands panel-injected variables.
MODIFIED_STARTUP=$(echo -e "$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')")
echo ":/home/container$ ${MODIFIED_STARTUP}"

exec ${MODIFIED_STARTUP}
