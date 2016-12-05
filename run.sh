#!/bin/sh

pub get &&
pub build &&
dart bin/server_main.dart;
