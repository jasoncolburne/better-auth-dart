.PHONY: setup test type-check lint format format-check clean test-integration

setup:
	dart pub get

test:
	dart test

type-check:
	dart analyze

lint:
	dart analyze --fatal-infos

format:
	dart format .

format-check:
	dart format --set-exit-if-changed --output=none .

test-integration:
	dart test test/integration_test.dart

clean:
	dart pub cache clean
	rm -rf .dart_tool build
