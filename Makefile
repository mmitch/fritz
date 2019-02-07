PODDIR     := lib/
HTMLDIR    := /tmp/pod
INDEXTITLE := Net::Fritz documentation index
BASEURL    := https://mmitch.github.io/fritz/
CSS        := pod.css
CSSINPUT   := pod-export.css

CSSOUTPUT  := $(HTMLDIR)/$(CSS)
CSSURL     := $(BASEURL)/$(CSS)

.PHONY: all prepare export install-modules generate-directories generate-pod export-css

all: prepare export

prepare: install-modules generate-directories

install-modules:
	cpanm --notest --skip-satisfied Pod::Tree

generate-directories:
	mkdir -p "$(HTMLDIR)"

export: generate-pod export-css

generate-pod:
	pods2html --index "$(INDEXTITLE)" --css "$(CSSURL)" "$(PODDIR)" "$(HTMLDIR)"

export-css:
	cp "$(CSSINPUT)" "$(CSSOUTPUT)"
