#!/bin/bash
# zig build monitor -Dtty=/dev/cu.usbserial-AL03J4QA 
zig build monitor -Dtty=/dev/cu.usbserial-1420 
# ctrl + A && ctrl + \