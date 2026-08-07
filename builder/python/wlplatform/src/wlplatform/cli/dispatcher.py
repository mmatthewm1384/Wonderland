#!/usr/bin/env python3

import os
import sys
from pathlib import Path

WL_ROOT = Path(
    os.environ.get(
        "WL_ROOT",
        Path(__file__).resolve().parents[4]
    )
).resolve()

PYTHON_ROOT = WL_ROOT / "builder/python/wlplatform/src"

if str(PYTHON_ROOT) not in sys.path:
    sys.path.insert(
        0,
        str(PYTHON_ROOT)
    )

from wlplatform.service_router import ServiceRouter

from wlplatform.runtime.context import get_context
from wlplatform.registry.registry_command import execute as registry_execute
from wlplatform.privacy.privacy_command import execute as privacy_execute
from wlplatform.identity.identity_command import execute as identity_execute
from wlplatform.services.lima_service import LimaService
from wlplatform.services.certification_service import CertificationService
from wlplatform.runtime.serialization import normalize

def dispatch(args):

    context = get_context()

    router = ServiceRouter(
        context.root
    )


    if len(args) < 1:
        raise SystemExit(
            "usage: wl <service> <command> [args]"
        )


    service = args[0]



    # CERTIFICATION COMMANDS
    if service == "certification":

        if len(args) < 2:
            raise SystemExit(
                "usage: wl certification <component>"
            )

        if args[1] == "lima":

            certification = CertificationService(
                context.root
            )

            return certification.certify_lima()

        raise SystemExit(
            f"unsupported certification target: {args[1]}"
        )


    # DOCTOR COMMANDS
    if service == "doctor":

        if len(args) < 2:
            raise SystemExit(
                "usage: wl doctor <command>"
            )

        if args[1] == "lima":

            lima = LimaService(
                context.root
            )

            if "--start" in args:
                lima.ensure_running()

            if "--evidence" in args:
                return lima.generate_evidence()

            result = lima.report()

            print()
            print("WONDERLAND LIMA BASELINE")
            print("========================")
            print()

            for name, ok in result["checks"].items():
                print(
                    f"{'PASS' if ok else 'FAIL'}: {name}"
                )

            print()
            print(
                "CERTIFIED"
                if result["certified"]
                else "FAILED"
            )

            return result

        raise SystemExit(
            f"unsupported doctor command: {args[1]}"
        )




    # CERTIFICATION COMMANDS
    if service == "certify":

        if len(args) < 2:
            raise SystemExit(
                "usage: wl certify <component>"
            )

        if args[1] == "lima":

            lima = LimaService(
                context.root
            )

            result = lima.run_checks()

            print()
            print("LIMA CERTIFICATION")
            print("==================")
            print()

            for name, ok in result["checks"].items():
                print(
                    f'{"PASS" if ok else "FAIL"}: {name}'
                )

            print()

            if result["certified"]:
                artifact = lima.generate_evidence()

                print("Evidence:")
                print(artifact)
                print()

                print("CERTIFIED")
            else:
                print("FAILED")

            return result

        raise SystemExit(
            f"unsupported certification target: {args[1]}"
        )


    # RUNTIME COMMANDS
    if service == "runtime":

        # Normalize nested runtime commands
        # wl runtime policy check <target>
        if (
            len(args) >= 3
            and args[1] == "policy"
            and args[2] == "check"
        ):
            args = [
                "runtime",
                "policy_check",
                *args[3:]
            ]


        if len(args) < 2:
            raise SystemExit(
                "usage: wl runtime <action>"
            )

        return router.execute(
            "runtime",
            args[1],
            *args[2:]
        )




    # PLATFORM LIFECYCLE COMMANDS
    if service in (
        "start",
        "stop",
        "restart",
        "sleep",
        "wake",
        "status",
    ):

        from wlplatform.services.platform_service import PlatformService

        platform = PlatformService(
            context.root
        )

        handler = getattr(
            platform,
            service
        )

        return handler()


    # ROUTED SERVICES
    if service in (
        "platform",
        "governance",
        "telemetry",
    ):

        router = ServiceRouter(
            context.root
        )

        if len(args) < 2:
            raise SystemExit(
                f"usage: wl {service} <command>"
            )

        return router.execute(
            service,
            args[1],
        )

    if service == "registry":

        if len(args) < 2:
            raise SystemExit(
                "usage: wl registry <command> [package]"
            )

        package = (
            args[2]
            if len(args) > 2
            else None
        )

        return registry_execute(
            context.root,
            args[1],
            args[2] if len(args) > 2 else None,
            args[3:],
        )


    if service == "privacy":

        if len(args) < 2:
            raise SystemExit(
                "usage: wl privacy <command>"
            )

        return privacy_execute(
            context.root,
            args[1],
        )


    if service == "identity":

        if len(args) < 2:
            raise SystemExit(
                "usage: wl identity <command>"
            )

        return identity_execute(
            context.root,
            args[1],
        )


    raise SystemExit(
        f"unsupported service: {service}"
    )


def main():

    result = dispatch(
        sys.argv[1:]
    )

    result = normalize(
        result
    )

    if result is None:
        return

    if isinstance(result, bool):
        print(
            "CERTIFIED"
            if result
            else "FAILED"
        )
        return

    if isinstance(result, dict):
        import json
        print(
            json.dumps(
                result,
                indent=4,
            )
        )
        return

    print(result)


if __name__ == "__main__":
    main()
