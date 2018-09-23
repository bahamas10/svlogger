.PHONY: all
all:
	@echo 'nothing to do'

.PHONY: check
check:
	awk 'length($$0) > 80 { exit(1); }' README.md
	awk 'length($$0) > 80 { exit(1); }' svlogger
	shellcheck svlogger
