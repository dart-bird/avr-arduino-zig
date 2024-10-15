#!/bin/bash
zig build
# zig build upload -Dtty=/dev/cu.usbserial-AL03J4QA // 실습용
zig build upload -Dtty=/dev/cu.usbserial-1420