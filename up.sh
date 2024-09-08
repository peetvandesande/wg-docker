#!/bin/bash

# Source the config file
source config

# Function to add routes
add_routes() {
	local ip="$1"
	local networks="$2"

	if [[ -z "$networks" ]]; then
		echo "No networks specified, skipping."
		return
	fi

	# Convert the comma-separated networks into an array
	IFS=',' read -r -a network_array <<< "$networks"

	# Add routes
	for network in "${network_array[@]}"; do
		echo "Adding route to $network via $ip"
		sudo ip route add "$network" via "$ip"
	done
}

# Start containers
docker compose up -d
if [ $? -eq 0 ]; then
	echo "Docker Compose started successfully."

	# Check and add routes for S2S
	if [[ -n "$S2S_NETWORKS" ]]; then
		add_routes "$S2S_IP" "$S2S_NETWORKS"
	else
		echo "S2S_NETWORKS not set"
	fi
	
	# Check and add routes for CVPN
	if [[ -n "$CVPN_NETWORKS" ]]; then
		add_routes "$CVPN_IP" "$CVPN_NETWORKS"
	else
		echo "CVPN_NETWORKS not set"
	fi
else
	echo "Docker Compose failed to start."
fi