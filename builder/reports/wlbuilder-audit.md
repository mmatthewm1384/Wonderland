# wlbuilder Architecture Audit

Module count: **47**

## Modules

### `wlbuilder.__init__`

- Path: `builder/python/wlbuilder/__init__.py`
- Classes: `none`
- Functions: `none`
- I/O markers: `none`
- Internal imports: `none`
- Imported by: `none`

### `wlbuilder.__main__`

- Path: `builder/python/wlbuilder/__main__.py`
- Classes: `none`
- Functions: `none`
- I/O markers: `none`
- Internal imports: `wlbuilder.runtime`
- Imported by: `none`

### `wlbuilder.api.__init__`

- Path: `builder/python/wlbuilder/api/__init__.py`
- Classes: `none`
- Functions: `none`
- I/O markers: `none`
- Internal imports: `wlbuilder.api.contracts`
- Imported by: `none`

### `wlbuilder.api.contracts`

- Path: `builder/python/wlbuilder/api/contracts.py`
- Classes: `ArtifactAuthority, StageResultContract, StageContract`
- Functions: `none`
- I/O markers: `mount`
- Internal imports: `none`
- Imported by: `wlbuilder.api.__init__`

### `wlbuilder.artifacts`

- Path: `builder/python/wlbuilder/artifacts.py`
- Classes: `none`
- Functions: `_profile, artifact_stem, raw_image_name, qcow2_image_name, manifest_name`
- I/O markers: `none`
- Internal imports: `wlbuilder.models.artifacts`
- Imported by: `wlbuilder.context, wlbuilder.stages.disk`

### `wlbuilder.cli`

- Path: `builder/python/wlbuilder/cli.py`
- Classes: `none`
- Functions: `build_parser, parse`
- I/O markers: `none`
- Internal imports: `none`
- Imported by: `wlbuilder.runtime`

### `wlbuilder.commands.__init__`

- Path: `builder/python/wlbuilder/commands/__init__.py`
- Classes: `none`
- Functions: `none`
- I/O markers: `none`
- Internal imports: `none`
- Imported by: `none`

### `wlbuilder.commands.artifacts`

- Path: `builder/python/wlbuilder/commands/artifacts.py`
- Classes: `none`
- Functions: `_is_excluded, run`
- I/O markers: `none`
- Internal imports: `wlbuilder.context`
- Imported by: `wlbuilder.runtime`

### `wlbuilder.commands.build`

- Path: `builder/python/wlbuilder/commands/build.py`
- Classes: `none`
- Functions: `run`
- I/O markers: `none`
- Internal imports: `wlbuilder.context, wlbuilder.pipeline`
- Imported by: `wlbuilder.runtime`

### `wlbuilder.commands.cleanup`

- Path: `builder/python/wlbuilder/commands/cleanup.py`
- Classes: `none`
- Functions: `run`
- I/O markers: `sudo, mount, losetup`
- Internal imports: `wlbuilder.commands_util, wlbuilder.context, wlbuilder.native_state`
- Imported by: `none`

### `wlbuilder.commands.config`

- Path: `builder/python/wlbuilder/commands/config.py`
- Classes: `none`
- Functions: `run`
- I/O markers: `json`
- Internal imports: `wlbuilder.config, wlbuilder.config_schema`
- Imported by: `wlbuilder.runtime`

### `wlbuilder.commands.contract`

- Path: `builder/python/wlbuilder/commands/contract.py`
- Classes: `none`
- Functions: `run`
- I/O markers: `none`
- Internal imports: `wlbuilder.context`
- Imported by: `wlbuilder.runtime`

### `wlbuilder.commands.docs`

- Path: `builder/python/wlbuilder/commands/docs.py`
- Classes: `none`
- Functions: `_write_stage_migration, _write_config_reference, _write_artifact_authority, _write_migration_plan, run`
- I/O markers: `filesystem_open, mkdir`
- Internal imports: `wlbuilder.config, wlbuilder.config_schema, wlbuilder.context, wlbuilder.migration, wlbuilder.stages`
- Imported by: `wlbuilder.runtime`

### `wlbuilder.commands.doctor`

- Path: `builder/python/wlbuilder/commands/doctor.py`
- Classes: `none`
- Functions: `run`
- I/O markers: `none`
- Internal imports: `wlbuilder.doctor`
- Imported by: `wlbuilder.runtime`

### `wlbuilder.commands.migration`

- Path: `builder/python/wlbuilder/commands/migration.py`
- Classes: `none`
- Functions: `run`
- I/O markers: `json`
- Internal imports: `wlbuilder.context, wlbuilder.migration, wlbuilder.stages`
- Imported by: `wlbuilder.runtime`

### `wlbuilder.commands.native_state`

- Path: `builder/python/wlbuilder/commands/native_state.py`
- Classes: `none`
- Functions: `run`
- I/O markers: `json`
- Internal imports: `wlbuilder.context, wlbuilder.native_state`
- Imported by: `wlbuilder.runtime`

### `wlbuilder.commands.stages`

- Path: `builder/python/wlbuilder/commands/stages.py`
- Classes: `none`
- Functions: `run`
- I/O markers: `json`
- Internal imports: `wlbuilder.context, wlbuilder.migration, wlbuilder.stages`
- Imported by: `wlbuilder.runtime`

### `wlbuilder.commands.status`

- Path: `builder/python/wlbuilder/commands/status.py`
- Classes: `none`
- Functions: `run`
- I/O markers: `none`
- Internal imports: `wlbuilder.context, wlbuilder.native_state, wlbuilder.stages`
- Imported by: `wlbuilder.runtime`

### `wlbuilder.commands.verify`

- Path: `builder/python/wlbuilder/commands/verify.py`
- Classes: `none`
- Functions: `run`
- I/O markers: `none`
- Internal imports: `wlbuilder.verify`
- Imported by: `wlbuilder.runtime`

### `wlbuilder.commands_util`

- Path: `builder/python/wlbuilder/commands_util.py`
- Classes: `CommandError`
- Functions: `run_command`
- I/O markers: `subprocess`
- Internal imports: `none`
- Imported by: `wlbuilder.commands.cleanup, wlbuilder.stages.bootloader, wlbuilder.stages.bootstrap, wlbuilder.stages.disk, wlbuilder.stages.identity, wlbuilder.stages.locale, wlbuilder.stages.mount, wlbuilder.stages.networking, wlbuilder.stages.packages, wlbuilder.stages.users`

### `wlbuilder.config`

- Path: `builder/python/wlbuilder/config.py`
- Classes: `BuilderConfig`
- Functions: `resolve_output_root, load_config`
- I/O markers: `filesystem_open, yaml`
- Internal imports: `none`
- Imported by: `wlbuilder.commands.config, wlbuilder.commands.docs, wlbuilder.config_schema, wlbuilder.context`

### `wlbuilder.config_schema`

- Path: `builder/python/wlbuilder/config_schema.py`
- Classes: `ConfigIssue`
- Functions: `_get, validate_config`
- I/O markers: `mount`
- Internal imports: `wlbuilder.config`
- Imported by: `wlbuilder.commands.config, wlbuilder.commands.docs, wlbuilder.doctor, wlbuilder.migration, wlbuilder.verify`

### `wlbuilder.context`

- Path: `builder/python/wlbuilder/context.py`
- Classes: `BuilderContext`
- Functions: `_resolve_repo_path, _resolve_path, create_context, ensure_output_dirs`
- I/O markers: `mkdir`
- Internal imports: `wlbuilder.artifacts, wlbuilder.config`
- Imported by: `wlbuilder.commands.artifacts, wlbuilder.commands.build, wlbuilder.commands.cleanup, wlbuilder.commands.contract, wlbuilder.commands.docs, wlbuilder.commands.migration, wlbuilder.commands.native_state, wlbuilder.commands.stages, wlbuilder.commands.status, wlbuilder.doctor, wlbuilder.migration, wlbuilder.native_state, wlbuilder.pipeline, wlbuilder.stages.base, wlbuilder.stages.bootloader, wlbuilder.stages.bootstrap, wlbuilder.stages.cleanup, wlbuilder.stages.convert, wlbuilder.stages.disk, wlbuilder.stages.identity, wlbuilder.stages.locale, wlbuilder.stages.manifest, wlbuilder.stages.mount, wlbuilder.stages.networking, wlbuilder.stages.packages, wlbuilder.stages.users, wlbuilder.stages.verify_image, wlbuilder.verify`

### `wlbuilder.doctor`

- Path: `builder/python/wlbuilder/doctor.py`
- Classes: `DoctorCheck`
- Functions: `_check_tool, run_doctor`
- I/O markers: `none`
- Internal imports: `wlbuilder.config_schema, wlbuilder.context`
- Imported by: `wlbuilder.commands.doctor`

### `wlbuilder.migration`

- Path: `builder/python/wlbuilder/migration.py`
- Classes: `none`
- Functions: `stage_mode, is_native_enabled`
- I/O markers: `none`
- Internal imports: `wlbuilder.config_schema, wlbuilder.context`
- Imported by: `wlbuilder.commands.docs, wlbuilder.commands.migration, wlbuilder.commands.stages`

### `wlbuilder.models.__init__`

- Path: `builder/python/wlbuilder/models/__init__.py`
- Classes: `none`
- Functions: `none`
- I/O markers: `none`
- Internal imports: `wlbuilder.models.artifacts, wlbuilder.models.stage`
- Imported by: `none`

### `wlbuilder.models.artifacts`

- Path: `builder/python/wlbuilder/models/artifacts.py`
- Classes: `BuildArtifacts`
- Functions: `none`
- I/O markers: `mount`
- Internal imports: `none`
- Imported by: `wlbuilder.artifacts, wlbuilder.models.__init__`

### `wlbuilder.models.stage`

- Path: `builder/python/wlbuilder/models/stage.py`
- Classes: `StageResultModel, StageModel`
- Functions: `none`
- I/O markers: `none`
- Internal imports: `none`
- Imported by: `wlbuilder.models.__init__`

### `wlbuilder.native_state`

- Path: `builder/python/wlbuilder/native_state.py`
- Classes: `none`
- Functions: `state_path, read_state, write_stage_state`
- I/O markers: `filesystem_write, mkdir, json`
- Internal imports: `wlbuilder.context`
- Imported by: `wlbuilder.commands.cleanup, wlbuilder.commands.native_state, wlbuilder.commands.status, wlbuilder.stages.bootloader, wlbuilder.stages.bootstrap, wlbuilder.stages.cleanup, wlbuilder.stages.convert, wlbuilder.stages.disk, wlbuilder.stages.identity, wlbuilder.stages.locale, wlbuilder.stages.manifest, wlbuilder.stages.mount, wlbuilder.stages.networking, wlbuilder.stages.packages, wlbuilder.stages.users`

### `wlbuilder.pipeline`

- Path: `builder/python/wlbuilder/pipeline.py`
- Classes: `none`
- Functions: `execute`
- I/O markers: `mount`
- Internal imports: `wlbuilder.context, wlbuilder.stages.base, wlbuilder.stages.bootloader, wlbuilder.stages.bootstrap, wlbuilder.stages.cleanup, wlbuilder.stages.convert, wlbuilder.stages.disk, wlbuilder.stages.identity, wlbuilder.stages.locale, wlbuilder.stages.manifest, wlbuilder.stages.mount, wlbuilder.stages.networking, wlbuilder.stages.packages, wlbuilder.stages.users, wlbuilder.stages.verify_image`
- Imported by: `wlbuilder.commands.build`

### `wlbuilder.runtime`

- Path: `builder/python/wlbuilder/runtime.py`
- Classes: `none`
- Functions: `_repo_root, _reject_direct_macos_execution, _commands, run`
- I/O markers: `none`
- Internal imports: `wlbuilder.cli, wlbuilder.commands.artifacts, wlbuilder.commands.build, wlbuilder.commands.config, wlbuilder.commands.contract, wlbuilder.commands.docs, wlbuilder.commands.doctor, wlbuilder.commands.migration, wlbuilder.commands.native_state, wlbuilder.commands.stages, wlbuilder.commands.status, wlbuilder.commands.verify`
- Imported by: `wlbuilder.__main__`

### `wlbuilder.stages.__init__`

- Path: `builder/python/wlbuilder/stages/__init__.py`
- Classes: `none`
- Functions: `default_pipeline`
- I/O markers: `mount`
- Internal imports: `wlbuilder.stages.base, wlbuilder.stages.bootloader, wlbuilder.stages.bootstrap, wlbuilder.stages.cleanup, wlbuilder.stages.convert, wlbuilder.stages.disk, wlbuilder.stages.identity, wlbuilder.stages.locale, wlbuilder.stages.manifest, wlbuilder.stages.mount, wlbuilder.stages.networking, wlbuilder.stages.packages, wlbuilder.stages.users, wlbuilder.stages.verify_image`
- Imported by: `none`

### `wlbuilder.stages.base`

- Path: `builder/python/wlbuilder/stages/base.py`
- Classes: `StageResult, BuilderStage`
- Functions: `none`
- I/O markers: `none`
- Internal imports: `wlbuilder.context`
- Imported by: `wlbuilder.pipeline, wlbuilder.stages.__init__, wlbuilder.stages.bootloader, wlbuilder.stages.bootstrap, wlbuilder.stages.cleanup, wlbuilder.stages.convert, wlbuilder.stages.disk, wlbuilder.stages.identity, wlbuilder.stages.locale, wlbuilder.stages.manifest, wlbuilder.stages.mount, wlbuilder.stages.networking, wlbuilder.stages.packages, wlbuilder.stages.users, wlbuilder.stages.verify_image`

### `wlbuilder.stages.bootloader`

- Path: `builder/python/wlbuilder/stages/bootloader.py`
- Classes: `BootloaderStage`
- Functions: `none`
- I/O markers: `sudo, mount, chroot`
- Internal imports: `wlbuilder.commands_util, wlbuilder.context, wlbuilder.native_state, wlbuilder.stages.base`
- Imported by: `wlbuilder.pipeline, wlbuilder.stages.__init__`

### `wlbuilder.stages.bootstrap`

- Path: `builder/python/wlbuilder/stages/bootstrap.py`
- Classes: `BootstrapStage`
- Functions: `none`
- I/O markers: `sudo, mount`
- Internal imports: `wlbuilder.commands_util, wlbuilder.context, wlbuilder.native_state, wlbuilder.stages.base`
- Imported by: `wlbuilder.pipeline, wlbuilder.stages.__init__`

### `wlbuilder.stages.cleanup`

- Path: `builder/python/wlbuilder/stages/cleanup.py`
- Classes: `CleanupStage`
- Functions: `none`
- I/O markers: `subprocess, mkdir, sudo, mount, losetup`
- Internal imports: `wlbuilder.context, wlbuilder.native_state, wlbuilder.stages.base`
- Imported by: `wlbuilder.pipeline, wlbuilder.stages.__init__`

### `wlbuilder.stages.convert`

- Path: `builder/python/wlbuilder/stages/convert.py`
- Classes: `ConvertStage`
- Functions: `sha256_file`
- I/O markers: `subprocess, filesystem_write, filesystem_open, mkdir`
- Internal imports: `wlbuilder.context, wlbuilder.native_state, wlbuilder.stages.base`
- Imported by: `wlbuilder.pipeline, wlbuilder.stages.__init__`

### `wlbuilder.stages.disk`

- Path: `builder/python/wlbuilder/stages/disk.py`
- Classes: `DiskStage`
- Functions: `none`
- I/O markers: `mkdir`
- Internal imports: `wlbuilder.artifacts, wlbuilder.commands_util, wlbuilder.context, wlbuilder.native_state, wlbuilder.stages.base`
- Imported by: `wlbuilder.pipeline, wlbuilder.stages.__init__`

### `wlbuilder.stages.identity`

- Path: `builder/python/wlbuilder/stages/identity.py`
- Classes: `IdentityStage`
- Functions: `none`
- I/O markers: `sudo, mount`
- Internal imports: `wlbuilder.commands_util, wlbuilder.context, wlbuilder.native_state, wlbuilder.stages.base`
- Imported by: `wlbuilder.pipeline, wlbuilder.stages.__init__`

### `wlbuilder.stages.locale`

- Path: `builder/python/wlbuilder/stages/locale.py`
- Classes: `LocaleStage`
- Functions: `none`
- I/O markers: `sudo, mount, chroot`
- Internal imports: `wlbuilder.commands_util, wlbuilder.context, wlbuilder.native_state, wlbuilder.stages.base`
- Imported by: `wlbuilder.pipeline, wlbuilder.stages.__init__`

### `wlbuilder.stages.manifest`

- Path: `builder/python/wlbuilder/stages/manifest.py`
- Classes: `ManifestStage`
- Functions: `git_commit`
- I/O markers: `subprocess, filesystem_write, mkdir, json`
- Internal imports: `wlbuilder.context, wlbuilder.native_state, wlbuilder.stages.base`
- Imported by: `wlbuilder.pipeline, wlbuilder.stages.__init__`

### `wlbuilder.stages.mount`

- Path: `builder/python/wlbuilder/stages/mount.py`
- Classes: `MountStage`
- Functions: `none`
- I/O markers: `sudo, mount, losetup`
- Internal imports: `wlbuilder.commands_util, wlbuilder.context, wlbuilder.native_state, wlbuilder.stages.base`
- Imported by: `wlbuilder.pipeline, wlbuilder.stages.__init__`

### `wlbuilder.stages.networking`

- Path: `builder/python/wlbuilder/stages/networking.py`
- Classes: `NetworkingStage`
- Functions: `none`
- I/O markers: `sudo, mount, chroot`
- Internal imports: `wlbuilder.commands_util, wlbuilder.context, wlbuilder.native_state, wlbuilder.stages.base`
- Imported by: `wlbuilder.pipeline, wlbuilder.stages.__init__`

### `wlbuilder.stages.packages`

- Path: `builder/python/wlbuilder/stages/packages.py`
- Classes: `PackagesStage`
- Functions: `none`
- I/O markers: `sudo, mount, chroot`
- Internal imports: `wlbuilder.commands_util, wlbuilder.context, wlbuilder.native_state, wlbuilder.stages.base`
- Imported by: `wlbuilder.pipeline, wlbuilder.stages.__init__`

### `wlbuilder.stages.users`

- Path: `builder/python/wlbuilder/stages/users.py`
- Classes: `UsersStage`
- Functions: `none`
- I/O markers: `sudo, mount, chroot`
- Internal imports: `wlbuilder.commands_util, wlbuilder.context, wlbuilder.native_state, wlbuilder.stages.base`
- Imported by: `wlbuilder.pipeline, wlbuilder.stages.__init__`

### `wlbuilder.stages.verify_image`

- Path: `builder/python/wlbuilder/stages/verify_image.py`
- Classes: `VerifyImageStage`
- Functions: `none`
- I/O markers: `none`
- Internal imports: `wlbuilder.context, wlbuilder.stages.base`
- Imported by: `wlbuilder.pipeline, wlbuilder.stages.__init__`

### `wlbuilder.verify`

- Path: `builder/python/wlbuilder/verify.py`
- Classes: `none`
- Functions: `run_verify`
- I/O markers: `mount`
- Internal imports: `wlbuilder.config_schema, wlbuilder.context, wlbuilder.stages`
- Imported by: `wlbuilder.commands.verify`

