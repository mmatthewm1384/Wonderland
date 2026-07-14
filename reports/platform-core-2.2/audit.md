# Platform Core 2.2 Audit

Generated: 2026-06-29T18:21:50Z

## Core module sizes
    1854 total
     344 lib/core/command_registry.sh
     153 lib/core/release_command.sh
     121 lib/core/health.sh
     117 lib/core/release_history.sh
     115 lib/core/validation.sh
     109 lib/core/release_manifest.sh
      81 lib/core/context.sh
      64 lib/core/state.sh
      59 lib/core/handoff.sh
      53 lib/core/services.sh
      46 lib/core/certify.sh
      46 lib/core/capability.sh
      46 lib/core/baseline.sh
      45 lib/core/checkpoint.sh
      43 lib/core/command_inventory.sh
      38 lib/core/json.sh
      37 lib/core/health-state.sh
      35 lib/core/health-v2.sh
      34 lib/core/artifacts.sh
      31 lib/core/release.sh
      29 lib/core/runtime.sh
      29 lib/core/boot.sh
      26 lib/core/core.sh
      25 lib/core/storage.sh
      23 lib/core/profile.sh
      19 lib/core/start.sh
      19 lib/core/load.sh
      18 lib/core/env.sh
      16 lib/core/release_paths.sh
      15 lib/core/output.sh
      10 lib/core/errors.sh
       8 lib/core/bootstrap.sh

## Duplicate function names
wl_result

## Release functions
lib/core/release_command.sh:100:wl_release_validate_all() {
lib/core/release_command.sh:124:wl_release_main() {
lib/core/release_command.sh:28:wl_release_promote() {
lib/core/release_command.sh:3:wl_release_build() {
lib/core/release_command.sh:54:wl_release_rollback() {
lib/core/release_command.sh:76:wl_release_status() {
lib/core/release_history.sh:18:wl_release_history() {
lib/core/release_history.sh:3:wl_release_history_append() {
lib/core/release_history.sh:32:wl_release_repair_history() {
lib/core/release_history.sh:73:wl_release_validate_history() {
lib/core/release_manifest.sh:12:wl_release_write_manifest() {
lib/core/release_manifest.sh:3:wl_release_manifest_digests() {
lib/core/release_manifest.sh:36:wl_release_validate_manifest_light() {
lib/core/release_manifest.sh:58:wl_release_validate_manifest_digests() {
lib/core/release_manifest.sh:81:wl_release_validate_manifest() {
lib/core/release_paths.sh:14:wl_release_history_file() {
lib/core/release_paths.sh:3:wl_release_dir() {
lib/core/release_paths.sh:9:wl_release_manifest_path() {
lib/core/release.sh:3:wl_release_validate() {

## Bootstrap users
      10

## Active commands
     292

## Backup commands still in bin
       1
