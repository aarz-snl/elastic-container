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

# Endpoint for creating an enrollment token for Fleet
CREATE_ENROLLMENT_TOKEN_ENDPOINT="${LOCAL_KBN_URL}/api/fleet/enrollment-api-keys"

# Create an enrollment token (replace YourPolicyIdHere with your actual policy ID)
POLICY_ID="YourPolicyIdHere" # You need to replace this with your actual policy ID

# The data payload for creating an enrollment token
DATA_PAYLOAD="{\"name\":\"EnrollmentTokenForScript\",\"policy_id\":\"${POLICY_ID}\"}"

# Make the API call to create an enrollment token
response=$(curl -k --silent --user "${ELASTIC_USERNAME}:${ELASTIC_PASSWORD}" -X POST "${CREATE_ENROLLMENT_TOKEN_ENDPOINT}" "${HEADERS[@]}" -d "${DATA_PAYLOAD}")

# Extract the enrollment token from the response
token=$(echo $response | jq -r '.item.api_key')
echo "Enrollment Token: $token"
