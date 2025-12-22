GRAFFLE_FILES := $(shell find . -name '*.graffle')

PNG_FILES := $(GRAFFLE_FILES:.graffle=.png)

default : $(PNG_FILES)

%.png : %.graffle
	omnigraffle-export.sh PNG $< $@