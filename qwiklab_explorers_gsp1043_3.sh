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


# Step 3: Prompting for Project ID
echo "${BOLD}${YELLOW}Getting Project ID${RESET}"
echo
get_project_id() {

  read -p "Please enter PROJECT_ID: " PROJECT_ID

  export PROJECT_ID="$PROJECT_ID"
}

# Call the function
get_project_id

echo

# Step 5: Create a View in customer_dataset
echo "${BOLD}${BLUE}Creating View in customer_dataset${RESET}"
bq mk \
--use_legacy_sql=false \
--view "SELECT cities.zip_code, cities.city, cities.state_code, customers.last_name, customers.first_name
FROM \`${DEVSHELL_PROJECT_ID}.customer_dataset.customer_info\` as customers
JOIN \`${PROJECT_ID}.data_publisher_dataset.authorized_view\` as cities
ON cities.state_code = customers.state" \
${DEVSHELL_PROJECT_ID}:customer_dataset.customer_table


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
