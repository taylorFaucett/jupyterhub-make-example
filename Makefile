SHELL := $(shell which bash)
MINICONDA := $(CURDIR)/.miniconda3
CONDA := $(MINICONDA)/bin/conda
CONDA_VERSION := 4.12.0-0
VENV := $(PWD)/.venv
DEPS := $(VENV)/.deps
PYTHON := $(VENV)/bin/python
PYTHON_CMD := PYTHONPATH=$(CURDIR) $(PYTHON)

.PHONY: help

MINICONDA_URL := https://github.com/conda-forge/miniforge/releases/download/4.12.0-0/Miniforge3-MacOSX-arm64.sh

ifndef VERBOSE
.SILENT:
endif

help:
	grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

FORCE:

$(CONDA):
	echo "Installing Miniconda3 to $(MINICONDA)"
	chmod +x $(CURDIR)/Miniforge3-MacOSX-arm64.sh
	bash $(CURDIR)/Miniforge3-MacOSX-arm64.sh -u -b -p "$(CURDIR)/.miniconda3"

$(PYTHON): | $(CONDA)
	$(CONDA) env create -p $(VENV) -f environment.yml

$(DEPS): environment.yml $(PYTHON)
	$(CONDA) env update --prune --quiet -p $(VENV) -f environment.yml
	cp environment.yml $(DEPS)

clean:
	rm -rf $(VENV)
	rm -rf $(MINICONDA)
	find . -name __pycache__ | xargs rm -rf

repl:
	$(VENV)/bin/ipython
	
jupyter: $(DEPS)
	$(VENV)/bin/jupyter-lab

run: $(DEPS)
	./main

setup: $(DEPS)