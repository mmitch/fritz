PODDIR     := lib/
HTMLDIR    := /tmp/pod
INDEXTITLE := Net::Fritz documentation index
BASEURL    := https://mmitch.github.io/fritz/
CSS        := pod.css

CSSFILE    := $(HTMLDIR)/$(CSS)
CSSURL     := $(BASEURL)/$(CSS)

.PHONY: all prepare export install-modules generate-directories generate-pod generate-css

all: prepare export

prepare: install-modules generate-directories

install-modules:
	cpanm --notest --skip-satisfied Pod::Tree

generate-directories:
	mkdir -p "$(HTMLDIR)"

export: generate-pod generate-css

generate-pod:
	pods2html --index "$(INDEXTITLE)" --css "$(CSSURL)" "$(PODDIR)" "$(HTMLDIR)"

generate-css:
	echo 'body { font: "Scource Sans Pro, Arial, Helvetica"; }' >> "$(CSSFILE)"
