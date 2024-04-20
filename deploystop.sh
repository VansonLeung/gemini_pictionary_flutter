#!/bin/bash

# Stop server_4.py using pm2
pm2 stop gemini_pictionary_flutter

# Remove from pm2 process list
pm2 delete gemini_pictionary_flutter

# Print status
pm2 status


