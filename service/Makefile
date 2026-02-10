.PHONY: help update-service update-latex-math clean slides audit install-service

help:
	@echo "Available targets:"
	@echo "  install-lese   : Install the lese R package from GitHub"
	@echo "                      Optional: ref=<name> to install a specific branch/tag (default: main)"
	@echo "  update-service    : Update service components from lecture_service repository"
	@echo "                      Optional: branch=<name> to use a specific branch (default: main)"
	@echo "  update-latex-math : Update latex-math from slds-lmu/latex-math repository"
	@echo "                      Optional: branch=<name> to use a specific branch (default: master)"
	@echo "  slides            : Compile slides in all slides/ folders"
	@echo "  clean             : Clean LaTeX auxiliary files in all slide directories"
	@echo "  audit             : Render chapter audit report (requires lese R package)"
	@echo "                      Optional: run=true to execute scripts (default: false)"
	@echo "  help              : Show this help message"

install-service:
	@Rscript --quiet -e 'if (!requireNamespace("pak", quietly = TRUE)) install.packages("pak"); pak::pkg_install("slds-lmu/lecture_service@$(or $(ref),main)")'

update-service:
	@bash scripts/update-service.sh $(branch)

update-latex-math:
	@bash scripts/update-latex-math.sh $(branch)

slides:
	@echo "Compiling slides in all slide directories..."
	@for dir in slides/*/; do \
		if [ -f "$$dir/Makefile" ]; then \
			echo "Compiling $$dir"; \
			$(MAKE) -C "$$dir" slides; \
		fi \
	done
	@echo "Done"

audit:
	Rscript --quiet -e 'lese::render_chapter_audit(run = $(if $(filter true TRUE 1,$(run)),TRUE,FALSE), method = "$(or $(method),auto)")'

clean:
	@echo "Cleaning LaTeX auxiliary files and PDFs in all slide directories..."
	@for dir in slides/*/; do \
		if [ -f "$$dir/Makefile" ]; then \
			echo "Cleaning $$dir"; \
			$(MAKE) -C "$$dir" clean; \
		fi \
	done
	@echo "Cleanup complete"
