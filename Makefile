
# install xml2rfc with "pip install xml2rfc"
# install mmark from https://github.com/mmarkdown/mmark 
# install pandoc from https://pandoc.org/installing.html
# install lib/rr.war from https://bottlecaps.de/rr/ui or https://github.com/GuntherRademacher/rr

.PHONE: all clean lint format

all: gen/draft-nandakumar-moq-scenarios.txt

html: gen/draft-nandakumar-moq-scenarios.html

clean:
	rm -rf gen/*

lint: gen/draft-nandakumar-moq-scenarios.xml
	rfclint gen/draft-nandakumar-moq-scenarios.xml

gen/draft-nandakumar-moq-scenarios.xml: draft-nandakumar-moq-scenarios.md
	mkdir -p gen
	mmark  draft-nandakumar-moq-scenarios.md > gen/draft-nandakumar-moq-scenarios.xml

gen/draft-nandakumar-moq-scenarios.txt: gen/draft-nandakumar-moq-scenarios.xml
	xml2rfc --text --v3 gen/draft-nandakumar-moq-scenarios.xml

gen/draft-nandakumar-moq-scenarios.pdf: gen/draft-nandakumar-moq-scenarios.xml
	xml2rfc --pdf --v3 gen/draft-nandakumar-moq-scenarios.xml

gen/draft-nandakumar-moq-scenarios.html: gen/draft-nandakumar-moq-scenarios.xml
	xml2rfc --html --v3 gen/draft-nandakumar-moq-scenarios.xml

gen/doc-jennings-quicr-proto.pdf: title.md abstract.md introduction.md naming.md protocol.md manifest.md relay.md contributors.md
	mkdir -p gen 
	pandoc -s title.md abstract.md introduction.md naming.md protocol.md manifest.md relay.md contributors.md -o gen/doc-jennings-quicr-proto.pdf

