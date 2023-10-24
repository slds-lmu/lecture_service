# Find all the slide tex files in the lecture repos, assuming strict naming convention
# Any changes in those should then be enough for the next make target.
TSLIDES=$(shell find lecture_*/slides/* -maxdepth 1 -iname "*.tex")

# We search again rather than do path substitution because not all pdf files might exist
TPDFS=$(shell find lecture_*/slides/* -maxdepth 1 -iname "*.pdf")

# Keep track of preamble dependencies so we can recompile slides if any of them change
# This unfortunately means that e.g. lecture_i2ml/ slides will recompile if preamble changes in lecture_sl/
PREAMBLES=$(shell find lecture_*/style -maxdepth 1 -type f -name "common.tex" -o -name "preamble.tex" -o -name "lmu-lecture.sty")

# data.frame of all slides and compile/comparison status checks created by check_all_slides()
CACHETBL=slide_check_cache.rds

# Rmd file that reads CACHETBL and outputs a neato table in HTML and stuff
STATUSRMD=slide_status.Rmd

# The corresponding HTML file and the *_files directory with HTML assets
STATUSHTML=${STATUSRMD:%.Rmd=%.html}
STATUSASSETS=${STATUSRMD:%.Rmd=%_files}
SITEDIR=_site

# Similar idea with the smaller Rmd file to render to markdown for pull requests
STATUSRMD_PR=slide_status_pr.Rmd
STATUSMD=${STATUSRMD_PR:%.Rmd=%.md}

.PHONY: all
all: site

.PHONY: help
help:
	@echo "clone                : Clone selected lecture repositories."
	@echo "download             : Download selected lecture repositories rather than using git."
	@echo "install              : Installs everything below. Assumes an Ubuntu OS!"
	@echo "install-service      : Installs this package via R CMD INSTALL."
	@echo "install-r            : Install R package dependencies."
	@echo "install-tex          : Install LaTeX package dependencies using TinyTex."
	@echo "install-tools-ubuntu : Attempt to install diff-pdf and diff-pdf-visually on Ubuntu-based systems."
	@echo "site                 : Generate HTML overview, re-running slide checking if necessary."
	@echo "table                : Generate markdown table rather than site. Used to append to PRs."
	@echo "clean                : Remove ${CACHETBL}, ${STATUSHTML}, ${STATUSASSETS}, and ${SITEDIR}."
	@echo "clean-site           : Remove ${STATUSHTML}, ${STATUSASSETS}, and ${SITEDIR}."

# This runs latexmk internally, but it's fast if there's nothing new to do for most slides (unless you clean up)
${CACHETBL}: $(TSLIDES) $(PREAMBLES)
	@# Rscript --quiet -e 'source("helpers.R"); check_all_slides()'
	Rscript --quiet -e 'lese::check_all_slides()'

.PHONY: check_results
check_results: ${CACHETBL}

.PHONY: table
table: ${CACHETBL} ${STATUSRMD_PR}
	Rscript --quiet -e 'rmarkdown::render("${STATUSRMD_PR}", quiet = TRUE, output_format = "github_document", output_file = "${STATUSMD}")'
	@# Don't know why the HTML version is always created but it's not needed
	rm ${STATUSRMD_PR:%.Rmd=%.html}

.PHONY: site
site: ${CACHETBL} ${STATUSRMD}
	Rscript --quiet -e 'rmarkdown::render("${STATUSRMD}", quiet = TRUE)'
	@# Create a self-contained folder with the HTML and assets for easier / more efficient deployment on GitHub actions
	@# or anywhere else.
	@# Also ensure that comparison dir exists, which might not be the case if there are no slides in
	@# slides-pdf at all (for new lectures).
	mkdir -p ${SITEDIR} comparison
	cp -r comparison ${SITEDIR}/
	cp -r ${STATUSASSETS} ${SITEDIR}/
	cp ${STATUSHTML} ${SITEDIR}/index.html
	@# For GitHub Pages (prevents running jekyll)
	@touch ${SITEDIR}/.nojekyll
	@# Copy lecture slide PDFs to site dir, preserving folder structure (-R) for clean and predictable paths,
	@# but of course to avoid having top copy the complete directories in lecture_*/
	@# Also suppressing output with @ and > /dev/null 2>&1 for less verbose make output,
	@# but could be relevant for debugging
	@rsync -R $(TPDFS) ${SITEDIR} > /dev/null 2>&1

# Delete files and directories only if they exist to avoid spurious make errors
# Multi-line command needs ; to terminate bash commands and \ to recognize linebreaks
.PHONY: clean
clean: clean-site
	if [ -f "${CACHETBL}" ]     ; then rm ${CACHETBL}       ; fi ;\
	find comparison -name "*pdf" -delete

.PHONY: clean-site
clean-site:
	if [ -f "${STATUSHTML}" ]   ; then rm ${STATUSHTML}     ; fi ;\
	if [ -d "${STATUSASSETS}" ] ; then rm -r ${STATUSASSETS}; fi ;\
	if [ -d "${SITEDIR}" ]      ; then rm -r ${SITEDIR}     ; fi

.PHONY: install-r install-tex install-tools-ubuntu install-service install
install-r:
	scripts/install_r_deps.R

install-tex:
	scripts/install_tex_deps.R

install-tools-ubuntu:
	scripts/install_tools_ubuntu.sh

install-service:
	@# R CMD INSTALL --preclean --no-multiarch --with-keep.source .
	# Install local dev dependencies (DESCRIPTION Imports and Suggests)
	Rscript -e 'pak::local_install_dev_deps()'
	# Install the service package
	Rscript -e 'pak::local_install()'

install: install-r install-tex install-tools-ubuntu install-service

.PHONY: clone download
clone:
	scripts/clone_lectures.sh

download:
	scripts/download_lectures.sh
