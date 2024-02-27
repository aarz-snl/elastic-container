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

echo "Listing all agent policies for debugging purposes:"
# Make the API call to list all agent policies
list_response=$(curl -k --silent --user "${ELASTIC_USERNAME}:${ELASTIC_PASSWORD}" -X GET "${LIST_POLICIES_ENDPOINT}" "${HEADERS[@]}")

echo "$list_response" | jq

# Ensure you have the correct policy ID from the list obtained above

# Endpoint for creating an enrollment token for Fleet
CREATE_ENROLLMENT_TOKEN_ENDPOINT="${LOCAL_KBN_URL}/api/fleet/enrollment-api-keys"

# Use the correct policy ID here
POLICY_ID="CorrectPolicyIdHere"  # Make sure this is replaced with the actual policy ID from the list

# The data payload for creating an enrollment token
DATA_PAYLOAD="{\"name\":\"EnrollmentTokenForScript\",\"policy_id\":\"${POLICY_ID}\"}"

echo "Attempting to create an enrollment token for policy ID: ${POLICY_ID}"

# Make the API call to create an enrollment token
response=$(curl -k --silent --user "${ELASTIC_USERNAME}:${ELASTIC_PASSWORD}" -X POST "${CREATE_ENROLLMENT_TOKEN_ENDPOINT}" "${HEADERS[@]}" -d "${DATA_PAYLOAD}")

# Debug: Print the full API response
echo "API Response for enrollment token creation: $response"

# Extract the enrollment token from the response
token=$(echo $response | jq -r '.item.api_key')
echo "Enrollment Token: $token"
