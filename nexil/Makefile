.PHONY: build app run clean

build:
	swift build -c release

app:
	sh scripts/build-app.sh

run:
	swift run -c debug

clean:
	swift package clean
	rm -rf .build/Nexil.app
