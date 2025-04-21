clear

#!/bin/bash
# Define color variables

BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`

# Array of color codes excluding black and white
TEXT_COLORS=($RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN)
BG_COLORS=($BG_RED $BG_GREEN $BG_YELLOW $BG_BLUE $BG_MAGENTA $BG_CYAN)

# Pick random colors
RANDOM_TEXT_COLOR=${TEXT_COLORS[$RANDOM % ${#TEXT_COLORS[@]}]}
RANDOM_BG_COLOR=${BG_COLORS[$RANDOM % ${#BG_COLORS[@]}]}

#----------------------------------------------------start--------------------------------------------------#


# Step 1: Getting Project ID & User ID

get_value() {

  read -p "Please enter PROJECT_ID: " PROJECT_ID
  echo
  read -p "Please enter TWIN_USER: " TWIN_USER

  export PROJECT_ID="$PROJECT_ID"
  export TWIN_USER="$TWIN_USER"
}

# Call the function
get_value

echo

# Step 2: Create Authorized View in Data Publisher Dataset

bq mk \
--use_legacy_sql=false \
--view "SELECT * FROM \`${PROJECT_ID}.demo_dataset.authorized_table\` WHERE state_code = 'NY' LIMIT 1000" \
${DEVSHELL_PROJECT_ID}:data_publisher_dataset.authorized_view

# Step 3: Show Dataset Info

bq show --format=prettyjson $DEVSHELL_PROJECT_ID:data_publisher_dataset > temp_dataset.json

# Step 4: Add View Access to Dataset

jq ".access += [{
  \"view\": {
    \"datasetId\": \"data_publisher_dataset\",
    \"projectId\": \"${DEVSHELL_PROJECT_ID}\",
    \"tableId\": \"authorized_view\"
  }
}]" temp_dataset.json > updated_dataset.json

# Step 5: Update Dataset Permissions

bq update --source=updated_dataset.json $DEVSHELL_PROJECT_ID:data_publisher_dataset

# Step 6: Create IAM Policy File

cat <<EOF > policy.json
{
  "bindings": [
    {
      "members": [
        "user:${TWIN_USER}"
      ],
      "role": "roles/bigquery.dataViewer"
    }
  ]
}
EOF

# Step 7: Set IAM Policy on the View
echo "${BOLD}${MAGENTA}Setting IAM Policy on authorized_view${RESET}"
bq set-iam-policy ${DEVSHELL_PROJECT_ID}:data_publisher_dataset.authorized_view policy.json

# Step 8: Prompt to Login as Data Twin
echo
echo "${BOLD}${BLUE}Now, Login with Customer (Data Twin) Username${RESET}"


# Display a random congratulatory message
random_congrats

echo -e "\n"  # Adding one blank line

cd

remove_files() {
    # Loop through all files in the current directory
    for file in *; do
        # Check if the file name starts with "gsp", "arc", or "shell"
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            # Check if it's a regular file (not a directory)
            if [[ -f "$file" ]]; then
                # Remove the file and echo the file name
                rm "$file"
                echo "File removed: $file"
            fi
        fi
    done
}

remove_files
