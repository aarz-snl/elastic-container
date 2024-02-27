#!/bin/bash

# Load environment variables from .env file
if [ -f .env ]; then
    source .env
else
    echo ".env file not found"
    exit 1
fi

# Define common headers
HEADERS=(
  -H "kbn-version: ${STACK_VERSION}"
  -H "kbn-xsrf: kibana"
  -H 'Content-Type: application/json'
)

# Endpoint to list all agent policies
LIST_POLICIES_ENDPOINT="${LOCAL_KBN_URL}/api/fleet/agent_policies"

# Make the API call to list all agent policies
list_response=$(curl -k --silent --user "${ELASTIC_USERNAME}:${ELASTIC_PASSWORD}" -X GET "${LIST_POLICIES_ENDPOINT}" "${HEADERS[@]}")

# Extract the policy ID for "Endpoint Policy"
POLICY_NAME="Endpoint Policy"
policy_id=$(echo "$list_response" | jq -r --arg POLICY_NAME "$POLICY_NAME" '.items[] | select(.name == $POLICY_NAME) | .id')

if [ -z "$policy_id" ]; then
    echo "Policy named '$POLICY_NAME' not found"
    exit 1
fi

echo "Policy ID for '$POLICY_NAME': $policy_id"

# Endpoint for creating an enrollment token for Fleet
CREATE_ENROLLMENT_TOKEN_ENDPOINT="${LOCAL_KBN_URL}/api/fleet/enrollment-api-keys"

# The data payload for creating an enrollment token
DATA_PAYLOAD="{\"name\":\"EnrollmentTokenForScript\",\"policy_id\":\"${policy_id}\"}"

echo "Attempting to create an enrollment token for policy ID: ${policy_id}"

# Make the API call to create an enrollment token
response=$(curl -k --silent --user "${ELASTIC_USERNAME}:${ELASTIC_PASSWORD}" -X POST "${CREATE_ENROLLMENT_TOKEN_ENDPOINT}" "${HEADERS[@]}" -d "${DATA_PAYLOAD}")

# Debug: Print the full API response
echo "API Response for enrollment token creation: $response"

# Extract the enrollment token from the response
token=$(echo $response | jq -r '.item.api_key')
echo "Enrollment Token: $token"
