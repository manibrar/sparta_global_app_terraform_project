#!/bin/bash

export LC_ALL=c
cd /home/ubuntu/app
npm install

pm2 start app.js
