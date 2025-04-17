#!/bin/bash

## Video0
v4l2-ctl -d /dev/video0 -c sensor_mode=4
gst-launch-1.0 v4l2src device=/dev/video0 ! xvimagesink -ev

## Vdieo1
#v4l2-ctl -d /dev/video1 -c sensor_mode=4
#gst-launch-1.0 v4l2src device=/dev/video1 ! xvimagesink -ev

## Vdieo2
#v4l2-ctl -d /dev/video2 -c sensor_mode=4
#gst-launch-1.0 v4l2src device=/dev/video2 ! xvimagesink -ev

## Vdieo3
#v4l2-ctl -d /dev/video3 -c sensor_mode=4
#gst-launch-1.0 v4l2src device=/dev/video3 ! xvimagesink -ev

## Vdieo4
#v4l2-ctl -d /dev/video4 -c sensor_mode=4
#gst-launch-1.0 v4l2src device=/dev/video4 ! xvimagesink -ev

## Vdieo5
#v4l2-ctl -d /dev/video5 -c sensor_mode=4
#gst-launch-1.0 v4l2src device=/dev/video5 ! xvimagesink -ev
