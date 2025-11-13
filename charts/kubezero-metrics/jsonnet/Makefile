JSONNET_ARGS := -n 2 --max-blank-lines 2 --string-style s --comment-style s
ifneq (,$(shell which jsonnetfmt))
	JSONNET_FMT_CMD := jsonnetfmt
else
	JSONNET_FMT_CMD := jsonnet
	JSONNET_FMT_ARGS := fmt $(JSONNET_ARGS)
endif
JSONNET_FMT := $(JSONNET_FMT_CMD) $(JSONNET_FMT_ARGS)

dashboardsDirPath=dashboards
rulessDirPath=rules

all: fmt generate lint

fmt:
	find . -name 'vendor' -prune -o -name '*.libsonnet' -print -o -name '*.jsonnet' -print | \
		xargs -n 1 -- $(JSONNET_FMT) -i

generate: clean
	# jb update
	jsonnet -J vendor -m dashboards -e '(import "dashboards.libsonnet").grafanaDashboards'
	jsonnet -J vendor -m rules rules.libsonnet

lint:
	find . -name 'vendor' -prune -o -name '*.libsonnet' -print -o -name '*.jsonnet' -print | \
		while read f; do \
			$(JSONNET_FMT) "$$f" | diff -u "$$f" -; \
		done

clean:
	rm -rf $(dashboardsDirPath) $(rulessDirPath)
	mkdir -p $(dashboardsDirPath) $(rulessDirPath)
