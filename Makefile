# Example usage:
# ➜  make help                                                                                                                                                                                             9:18:34
# help                            Display help
# test                            example target to echo 'test'
# has_brew                        check if homebrew is installed
#
# -e says exit immediately when a command fails
# -o sets pipefail, meaning if it exits with a failing command, the exit code should be of the failing command
# -u fails a bash script immediately if a variable is unset
SHELL = /bin/bash -eu -o pipefail

define is_installed
if ! command -v $(1) &> /dev/null; \
then \
	echo "$(1) not installed, please install it. 'brew install $(1)'"; \
	exit; \
fi;
endef

.PHONY : help
help : ## Display help
	@awk -F ':|##' \
		'/^[^\t].+?:.*?##/ {\
			printf "\033[36m%-30s\033[0m %s\n", $$1, $$NF \
		}' $(MAKEFILE_LIST)

.PHONY : test
test : ## example target to echo 'test'
	@echo 'test'

.PHONY : has_brew
has_brew : ## check if homebrew is installed
	@$(call is_installed,brew)
