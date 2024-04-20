#!/bin/bash

# Change to the directory where server_4.py is located
cd ./src

# Start server_6.py using pm2
pm2 start gemini_pictionary_server.py --interpreter=../venv/bin/python3 --name gemini_pictionary_flutter

# Print status
pm2 status

cd ../
