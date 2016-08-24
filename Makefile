.PHONY: carthage
carthage:
	rm -r ./Carthage/Build
	carthage update --platform ios --no-use-binaries


