SHELL := $(shell which bash)
MINICONDA := $(CURDIR)/.miniconda3
CONDA := $(MINICONDA)/bin/conda
CONDA_VERSION := 4.7.10
VENV := $(PWD)/.venv
DEPS := $(VENV)/.deps
PYTHON := $(VENV)/bin/python
PYTHON_CMD := PYTHONPATH=$(CURDIR) $(PYTHON)

.PHONY: help

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	MINICONDA_URL := https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
endif
ifeq ($(UNAME_S),Darwin)
	MINICONDA_URL := https://github.com/conda-forge/miniforge/releases/download/4.12.0-0/Miniforge3-MacOSX-arm64.sh
endif

ifndef VERBOSE
.SILENT:
endif

help:
	grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

FORCE:

$(CONDA):
	# conda activate /Users/tfaucett/Downloads/cforge-test/.venv
	chmod +x $(CURDIR)/miniconda.sh
	sh $(CURDIR)/miniconda.sh -u -b -p "$(CURDIR)/.miniconda3"

$(PYTHON): | $(CONDA)
	$(CONDA) env create -p $(VENV) -f environment.yml

$(DEPS): environment.yml $(PYTHON)
	$(CONDA) env update --prune --quiet -p $(VENV) -f environment.yml
	cp environment.yml $(DEPS)

clean:
	rm -rf $(VENV)
	rm -rf $(MINICONDA)
	find . -name __pycache__ | xargs rm -rf

update: $(DEPS)

repl: ## Run an iPython REPL
	$(VENV)/bin/ipython
	
jupyter: $(DEPS)
	$(VENV)/bin/jupyter-lab

run: $(DEPS) ## Run the program on the provided dataset
	./main
