.PHONY: default test

default:
	@echo "Nothing to do"

clean:
	@rm -rf mac.db target

test:
	@bash mac.sh test target