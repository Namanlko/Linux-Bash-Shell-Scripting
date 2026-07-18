#!/bin/bash
# Quick System Summary
# Displays a brief overview of the current system state.

echo "=========================================="
echo "       🚀 QUICK SYSTEM SUMMARY 🚀         "
echo "========================================تهم"

echo "📅 Date/Time: $(date)"
echo "👤 Current User: $(whoami)"
echo "💻 Hostname: $(hostname)"
echo "🐧 Kernel: $(uname -r)"
echo "⏱️  Uptime: $(uptime -p)"
echo "------------------------------------------"
echo "💾 Disk Usage (Root):"
df -h / | awk 'NR==2 {print "Used: " $3 " / Total: " $2 " (" $5 ")"}'
echo "------------------------------------------"
echo "🧠 RAM Usage:"
free -h | awk 'NR==2 {print "Used: " $3 " / Total: " $2}'
echo "=========================================="