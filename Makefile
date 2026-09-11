export DBT_PROFILES_DIR := $(CURDIR)

VENV := .venv
PYTHON := $(VENV)/bin/python
DBT := $(VENV)/bin/dbt

.PHONY: setup deps build test seed run docs clean

setup:
	python3 -m venv $(VENV)
	$(PYTHON) -m pip install --upgrade pip
	$(PYTHON) -m pip install -r requirements.txt
	$(DBT) deps

deps:
	$(DBT) deps

seed:
	$(DBT) seed

build:
	$(DBT) build

run:
	$(DBT) run

test:
	$(DBT) test

docs:
	$(DBT) docs generate && $(DBT) docs serve

clean:
	rm -rf target dbt_packages
