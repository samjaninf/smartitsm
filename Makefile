project = smartitsm
version = $(bin/smartitsm.sh --version 2>&1 | head -n1 | awk '{print $NF}')
package = $(project)-$(version)
tarball = $(package).tar.gz

PANDOC = pandoc
GIT = git


## Distribute

dist : readme changelog
	@echo "Building distribution package..."
	@echo "Version is $(version)."
	@rm -rf $(package) && mkdir -p $(package)
	@cp README CHANGELOG COPYING bin/ conf.d/ etc/ lib/ www/ $(package)
	@tar czf $(tarball) $(package)
	@rm -r $(package)
	@echo "Tarball $(tarball) is ready."

readme :
	@echo "Building README..."
	@$(PANDOC) --from markdown --to plain --standalone README.md > README

changelog :
	@echo "Building CHANGELOG..."
	@$(PANDOC) --from markdown --to plain --standalone CHANGELOG.md > CHANGELOG

tag : git
	@echo "Tagging version..."
	@$(GIT) tag -s $(version) -m "tagging version $(version)"
	@echo "Pushing tag to origin..."
	@$(GIT) push origin $(version)


## Clean up

clean : distclean
	@echo "Cleaning up..."
	@rm -f $(tarball)

distclean :
	@echo "Cleaning up distribution..."
	@rm -f README CHANGELOG


## Helper

git :
	@test -d ".git" || (echo "No git repository present." && exit 1)
