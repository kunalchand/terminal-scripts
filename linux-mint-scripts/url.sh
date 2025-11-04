#!/bin/bash

read -p "Enter keyword: " command
read -p "Enter URL: " url

# Get the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Initialize the boolean variable
command_updated=false
git_push=false
status=""

while IFS= read -r line
do
    if [[ $line == *":"* ]]; then
        cmd=${line%%:*}
        if [ "$cmd" = "$command" ]; then
            command_updated=true # To NOT duplicate the command
            existing_url=${line#*:[[:space:]]}
            echo -e "Existing Command: \033[96m$cmd: $existing_url\033[0m"
            echo -e "New Command: \033[93m$command: $url\033[0m"
            echo "Confirm to update an EXISTSING command? (y/n)"
            read -r update_confirmation < /dev/tty
            if [ "$update_confirmation" = "y" ]; then
              sed -i "/^$cmd:/c\\$command: $url" "$SCRIPT_DIR/commands.txt"
              echo "Existing command updated!"
              git_push=true
              status="Updated"
              break
            else
              echo "Existing command updation aborted!"
              break
            fi
        fi
    fi
done < "$SCRIPT_DIR/commands.txt"

# Check if the command was updated
if [ "$command_updated" = false ]; then
  echo -e "\033[93m$command: $url\033[0m"
  echo "Confirm a NEW command? (y/n)"
  read -r new_command_confirmation < /dev/tty

  if [ "$new_command_confirmation" = "y" ]; then
      # Count the number of lines in the file
      num_lines=$(wc -l < "$SCRIPT_DIR/commands.txt")
      # Count the number of newline characters in the file
      num_newlines=$(grep -c $'\n' "$SCRIPT_DIR/commands.txt")
      # If the number of lines is equal to the number of newline characters, the file ends with a newline
      if [ "$num_lines" -eq "$num_newlines" ]; then
        # The file ends with a newline, no need to append another
        echo "$command: $url" >> "$SCRIPT_DIR/commands.txt"
      else
        # The file does not end with a newline, append one before the command
        echo "" >> "$SCRIPT_DIR/commands.txt"
        echo "$command: $url" >> "$SCRIPT_DIR/commands.txt"
      fi

      # Count the number of lines in the file
      num_lines=$(wc -l < "$SCRIPT_DIR/bashrc_alias.txt")
      # Count the number of newline characters in the file
      num_newlines=$(grep -c $'\n' "$SCRIPT_DIR/bashrc_alias.txt")
      # If the number of lines is equal to the number of newline characters, the file ends with a newline
      if [ "$num_lines" -eq "$num_newlines" ]; then
        # The file ends with a newline, no need to append another
        echo "alias $command='~/Documents/mint-scripts/browser.sh $command'" >> "$SCRIPT_DIR/bashrc_alias.txt"
      else
        # The file does not end with a newline, append one before the command
        echo "" >> "$SCRIPT_DIR/bashrc_alias.txt"
        echo "alias $command='~/Documents/mint-scripts/browser.sh $command'" >> "$SCRIPT_DIR/bashrc_alias.txt"
      fi

      echo "New command added!"
      git_push=true
      status="Added"
  else
    echo "New command addition aborted!"
  fi
fi

if [ "$git_push" = true ]; then
    cd /home/kunalchand/Documents/mint-scripts
    git add *
    git commit -m "$status '$command' command"
    git push

    echo -e "\e[95m\e[3mPlease run '. ~/.bashrc' or 'source ~/.bashrc' to update the current shell with new aliases.\e[0m"
fi