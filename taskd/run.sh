#!/bin/bash

taskd server --daemon
tail -f /tmp/taskd.log 
