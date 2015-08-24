REMOTEDIR ?= ~/.public_html/Sta523_Fa15
REMOTE ?= cr173@nighthawk.stat.duke.edu:$(REMOTEDIR)

POST_RMD_FILES := $(wildcard _knitr/*.Rmd)
POST_HTML_FILES  := $(patsubst _knitr/%.Rmd, _posts/%.html, $(POST_RMD_FILES))
SLIDE_HTML_FILES := $(patsubst _knitr/%.Rmd, slides/%.html, $(POST_RMD_FILES))

HW_RMD_FILES := $(wildcard _homework/*.Rmd)
HW_HTML_FILES  := $(patsubst _homework/%.Rmd, hw/%.html, $(HW_RMD_FILES))


build: $(POST_HTML_FILES) $(SLIDE_HTML_FILES) $(HW_HTML_FILES)
	jekyll build

.PHONY: clean
clean:
	rm -rf _site/*
	rm -f _posts/*.html
	rm -f slides/*.html
	rm -f hw/*.html

push: build
	@echo "Syncing to server!"
	@rsync -az _site/* $(REMOTE)

test: $(POST_HTML_FILES) $(SLIDE_HTML_FILES) $(HW_HTML_FILES)
	jekyll build --config _config.yml,_testing.yml
	@echo "Syncing to server!"
	@rsync -az _site/* $(REMOTE)/../testing

_posts/%.html: _knitr/%.Rmd
	@echo "Rendering post: $(@F)"
	@Rscript --vanilla util/render_post.R $< $@

slides/%.html: _knitr/%.Rmd
	@echo "Rendering slides: $(@F)"
	@touch $@
	@Rscript --vanilla util/render_post.R $< _posts/$(@F)

hw/%.html: _homework/%.Rmd
	@echo "Rendering hw: $(@F)"
	@Rscript --vanilla util/render_hw.R $< $@

serve: $(POST_HTML_FILES) $(SLIDE_HTML_FILES) $(HW_HTML_FILES)
	@open http://localhost:4000
	@jekyll serve --baseurl ''




