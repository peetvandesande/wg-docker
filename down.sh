#!/bin/bash

# Source the config file
source config

# Function to del routes
del_routes() {
	local ip="$1"
	local networks="$2"

	echo "deleting routes"

	if [[ -z "$networks" ]]; then
		echo "No networks specified, skipping."
		return
	fi

	# Convert the comma-separated networks into an array
	IFS=',' read -r -a network_array <<< "$networks"

	# Add routes
	for network in "${s2s_network_array[@]}"; do
		echo "Removing route to $network via $ip"
		sudo ip route del "$network" via "$ip"
	done
}

# Start containers
docker compose down
if [ $? -eq 0 ]; then
	echo "Docker Compose ended successfully."

	# Check and del routes for S2S
	if [[ -n "$S2S_NETWORKS" ]]; then
		echo "S2S_NETWORKS set"
		del_routes "$S2S_IP" "$S2S_NETWORKS"
	else
		echo "S2S_NETWORKS not set"
	fi
	
	# Check and del routes for CVPN
	if [[ -n "$CVPN_NETWORKS" ]]; then
		echo "CVPN_NETWORKS set"
		del_routes "$CVPN_IP" "$CVPN_NETWORKS"
	else
		echo "CVPN_NETWORKS not set"
	fi
else
	echo "Docker Compose failed to start."
fi
