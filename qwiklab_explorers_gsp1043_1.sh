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


#----------------------------------------------------start--------------------------------------------------#


# Step 1: Get User IDs
echo
echo "${BOLD}${BLUE}Getting User IDs${RESET}"
echo
get_users_ids() {

  read -p "Please enter PUB_USER: " PUB_USER
  echo
  read -p "Please enter TWIN_USER: " TWIN_USER

  export PUB_USER="$PUB_USER"
  export TWIN_USER="$TWIN_USER"
}

# Call the function
get_users_ids

echo

# Step 2: Create BigQuery Table
export PROJECT_ID=$DEVSHELL_PROJECT_ID
export DATASET=demo_dataset
export TABLE=authorized_table

bq query \
--location=US \
--use_legacy_sql=false \
--destination_table=${PROJECT_ID}:${DATASET}.${TABLE} \
--replace \
--nouse_cache \
'SELECT * FROM (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY state_code ORDER BY area_land_meters DESC) AS cities_by_area
  FROM `bigquery-public-data.geo_us_boundaries.zip_codes`
) cities
WHERE cities_by_area <= 10
ORDER BY cities.state_code
LIMIT 1000;' > /dev/null

# Step 3: Show Dataset Info
bq show --format=prettyjson ${PROJECT_ID}:${DATASET} > temp_dataset.json

# Step 4: Modify Dataset Access Policy
jq ".access += [
  {
    \"role\": \"READER\",
    \"userByEmail\": \"${PUB_USER}\"
  },
  {
    \"role\": \"READER\",
    \"userByEmail\": \"${TWIN_USER}\"
  }
]" temp_dataset.json > updated_dataset.json

# Step 5: Update Dataset Permissions
bq update --source=updated_dataset.json ${PROJECT_ID}:${DATASET}

# Step 6: Create IAM Policy File
echo "${BOLD}${GREEN}Creating IAM Policy File${RESET}"
cat <<EOF > policy.json
{
  "bindings": [
    {
      "members": [
        "user:${PUB_USER}",
        "user:${TWIN_USER}"
      ],
      "role": "roles/bigquery.dataViewer"
    }
  ]
}
EOF

# Step 7: Set IAM Policy on Table
echo "${BOLD}${RED}Setting IAM Policy on Table${RESET}"
bq set-iam-policy ${PROJECT_ID}:${DATASET}.${TABLE} policy.json


# Step 8: Prompt to Login with Publisher Account
echo
echo "${BOLD}${BLUE}Now, Login with Data Publisher Username${RESET}"




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
