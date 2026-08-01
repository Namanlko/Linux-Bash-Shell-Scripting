#!/bin/bash
# Service Status Checker Script
# Checks whether a Linux service is running.
# If the service is stopped, asks the user whether to start it.
# Verifies if the service starts successfully.

echo "=========================================="
echo "     🔍 SERVICE STATUS CHECKER 🔍"
echo "=========================================="

echo "📥 Enter the service name:"
read service

echo "------------------------------------------"
echo "🔎 Checking if the service exists..."

# Check whether the service exists
if ! systemctl status "$service" > /dev/null 2>&1
then
    echo "❌ Service '$service' does not exist."
    exit 1
fi

echo "------------------------------------------"
echo "📊 Checking service status..."

# Check if the service is already running
if systemctl is-active --quiet "$service"
then
    echo "✅ Service '$service' is already running."

else
    echo "⚠️ Service '$service' is currently stopped."

    echo "------------------------------------------"
    echo "❓ Do you want to start the service? (yes/no)"
    read choice

    # User chooses to start the service
    if [ "$choice" = "yes" ]
    then
        echo "▶️ Starting the service..."
        sudo systemctl start "$service"

        echo "------------------------------------------"
        echo "🔎 Verifying service status..."

        # Verify whether the service started successfully
        if systemctl is-active --quiet "$service"
        then
            echo "✅ Service '$service' has been started successfully."
        else
            echo "❌ Failed to start the service."
        fi

    # User chooses not to start the service
    elif [ "$choice" = "no" ]
    then
        echo "ℹ️ As you selected 'no', the service remains stopped."

    # Handle invalid input
    else
        echo "❌ Invalid input. Please enter 'yes' or 'no'."
    fi
fi

echo "=========================================="
echo "🎉 Script Execution Completed!"
echo "=========================================="