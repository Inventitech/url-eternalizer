# URL Eternalizer

[![Build Status](https://travis-ci.org/Inventitech/latex-url-eternalizer.svg?branch=master)](https://travis-ci.org/Inventitech/latex-url-eternalizer)

This gem automatically extracts and archives URLs from a text file on Archive.org and replaces the original URL with 
the archived URL. While it can work on any text file, it is optimized for TeX files. The URL Eternalizer can work 
continuously on the same file, i.e., existing archived URLs will not be archived again.

## Motivation
This problem is especially annyoing in scientific articles, which increasingly contain URLs, but tend to have a longer 
lifetime than the average blog post. Archiving URLs manually is a tedious process. This gem automates that.

## What it does

URL Eternalizer can work on any ASCII text, but has a special mode for LaTeX. Once a link has been archived, it will be left untouched. Thus, you can run URL Eternalizer continuously on your files. In the following we will give two examples of what it does.

### Plain Text

```
Go to www.google.com.
```

will be translated to

```
Go to http://web.archive.org/web/20180225115649/http://www.google.com/.
```

### LaTeX documents

For LaTeX documents, URL Eternalizer inserts a special marker with a separate link target and text.

```
Go to \url{www.google.com}.
```

will be translated to

```
Go to \ahref{http://web.archive.org/web/20180225115649/http://www.google.com/}{www.google.com}.
```

`\ahref` is a newly defined command that has the second part argument as the link text, and the first part as the link target. The link in the example above will appear as
[www.google.com](http://web.archive.org/web/20180225115649/http://www.google.com/) in PDF.

`\ahref` is defined as:

```
\newcommand{\ahref}[2]{\href{#1}{\nolinkurl{#2}}}
```


## How to call

```
ruby eternalize_urls.rb file
```