# pdfs2transactions
Extract transactions from bank statements (PDFs)

Download: __[here][distribution link]__

### Instructions (example bank name = mybank)
> NOTE: change parameters as needed in "config/config.yml"
---
1. In "config/env.parameters", set java and ruby parameters according to your system
2. Copy your bank statements (PDF files) to "data/mybank/pdf" folder
3. Run "pdf2text.bat"
4. Run "parse.bat"
5. See results in "data/mybank/transactions.tsv"
---
> IMPORTANT: your file names and folder names must contain no spaces.
---

If you'd like to help, send your donations to the bitcoin address shown below.

* BTC: [1LEDgnVzcwckzVPrCyYqV7nV4PtDdWFab7][bitcoin address]

[bitcoin address]: bitcoin:1LEDgnVzcwckzVPrCyYqV7nV4PtDdWFab7
[distribution link]: https://github.com/ares-koen/pdfs2transactions/raw/master/dist/pdfs2transactions.7z