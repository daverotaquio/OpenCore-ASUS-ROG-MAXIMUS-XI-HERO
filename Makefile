## Make defaults
.DEFAULT_GOAL = help
# Unify target echoing
PRINT_TARGET = @echo "--> $@"

## Targets
clean:  ## Remove autogenerated files
	$(PRINT_TARGET)
	@-rm -fr EFI

help:  ## Display this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | sort \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[0;32m%-30s\033[0m %s\n", $$1, $$2}'

lint:  ## Run linter checks
	$(PRINT_TARGET)
	@echo "Linting property list files..."
	@find "${CURDIR}" -name '*.plist' -print0 | xargs -0 -n1 plutil -lint
	@echo "Linting bash scripts..."
	@shellcheck --version
	@find "${CURDIR}" -name '*.sh' -print0 | xargs -0 -t -n1 shellcheck --color=always --severity=style
	@echo "Linting YAML files..."
	@yamllint --version
	@yamllint -s "${CURDIR}"

run: clean  ## Generate EFI folder with 'config.plist' template
	$(PRINT_TARGET)
	@LOCAL_RUN=1 "${CURDIR}/create-efi.sh"

toc:  ## Generate README.md table of contents
	$(PRINT_TARGET)
	@bash -c "$$(curl -fsSL raw.githubusercontent.com/ekalinin/github-markdown-toc/master/gh-md-toc) README.md"

vault-pre:  ## Vault prerequisite check
	$(PRINT_TARGET)
	@if [ -z "${ANSIBLE_VAULT_PASSWORD_FILE}" ]; then \
		echo "ANSIBLE_VAULT_PASSWORD_FILE variable is not set"; \
		exit 1; \
	fi
	@ansible-vault --version

vault: vault-pre run  ## Generate OpenCore 'config.plist' from template
	$(PRINT_TARGET)
	@"${CURDIR}/util/vault.sh"

.PHONY: \
	clean \
	help \
	lint \
	run \
	toc \
	vault-pre \
	vault
