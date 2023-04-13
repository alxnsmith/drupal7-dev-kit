#!/usr/bin/env bash

# Command is first argument
command=$1

# Command must be provided
if [ -z "$command" ]; then
    echo "Command must be provided"
    exit 1
fi

# Function for replace interpolations in files
fill_templates() {
  local project_dir=$1
  local project_name=$2

  # Walk recursive and replace {{{project_name}}} with sed and provided name
  find $project_dir -type f -exec sed -i '' "s/{{{project_name}}}/$project_name/g" {} +
}

# function startproject
startproject() {
    # Get project name
    local project_name=$2

    # Project name must be provided
    if [ -z "$project_name" ]; then
        echo "Project name must be provided"
        exit 1
    fi

    echo "Start $project_name project"
    
    # If $project_name folder exists - ask replace
    if [ -d "$project_name" ]; then
        read -p "Folder $project_name already exists. Replace? [y/n] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf $project_name
        else
            echo "Exit"
            exit 1
        fi
    fi
    
    # Create project folder
    mkdir -p $project_name/{backup,config,db-data,drupal-data,git}
    cp -r .stubs/{docker-compose.yml,mysqldump.sh,.env,config} $project_name
    

    fill_templates "$project_name" $project_name


    # Ask git repository address
    read -p "Git repository address: " git_repo
    if [ -z "$git_repo" ]; then
        echo "Git repository address must be provided"
        exit 1
    fi

    # Ask git branch
    read -p "Git branch [master]: " git_branch
    if [ -z "$git_branch" ]; then
        git_branch="master"
    fi

    git clone --branch $git_branch $git_repo $project_name/git
}

$command $@
