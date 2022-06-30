import strformat

# Package

version = "1.1.0"
author = "timwedde"
description = "A tiny helper to access scoped environment variables."
license = "MIT"
srcDir = "src"
bin = @["eget"]

# Dependencies

requires "nim >= 1.6.6"

# Tasks

task eget, "Executes 'nimble run' with extra compiler options.":
  let args = join(commandLineParams[3..^1], " ")
  exec(&"nimble --gc:orc run eget {args}")

task build_macos_arm64, "Builds for macOS (arm64)":
  exec("nimble build -d:danger --gc:orc --os:macosx --cpu:arm64 -d:strip -y")
  exec("mkdir -p bin/arm64/macos && mv eget bin/arm64/macos")
  # exec("upx --best bin/amd64/macos/*") # not supported yet

task build_macos_amd64, "Builds for macOS (amd64)":
  exec("nimble build -d:danger --gc:orc --os:macosx --cpu:amd64 -d:strip -y")
  exec("mkdir -p bin/amd64/macos && mv eget bin/amd64/macos")
  exec("upx --best bin/amd64/macos/*")

task build_linux_amd64, "Builds for linux (amd64)":
  exec("nimble build -d:danger --gc:orc --os:linux --cpu:amd64 -d:strip -y")
  exec("mkdir -p bin/amd64/linux && mv eget bin/amd64/linux")
  exec("upx --best bin/amd64/linux/*")

task build_linux_i386, "Builds for linux (i386)":
  exec("nimble build -d:danger --gc:orc --os:linux --cpu:i386 -d:strip -y")
  exec("mkdir -p bin/i386/linux && mv eget bin/i386/linux")
  exec("upx --best bin/i386/linux/*")

task build_windows_amd64, "Builds for Windows (amd64)":
  exec("nimble build -d:danger --gc:orc -d:mingw --cpu:amd64 -d:strip -y")
  exec("mkdir -p bin/amd64/windows && mv eget.exe bin/amd64/windows")
  exec("upx --best bin/amd64/windows/*")

task build_windows_i386, "Builds for Windows (i386)":
  exec("nimble build -d:danger --gc:orc -d:mingw --cpu:i386 -d:strip -y")
  exec("mkdir -p bin/i386/windows && mv eget.exe bin/i386/windows")
  exec("upx --best bin/i386/windows/*")

