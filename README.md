# URL Eternalizer

[![Build Status](https://travis-ci.org/Inventitech/latex-url-eternalizer.svg?branch=master)](https://travis-ci.org/Inventitech/latex-url-eternalizer)

This gem automatically extracts and archives URLs from a text file on Archive.org and replaces the original URL with 
the archived URL. While it can work on any text file, it is optimized for TeX files. The URL Eternalizer can work 
continuously on the same file, i.e., existing archived URLs will not be archived again.

## Motivation
This problem is especially annyoing in scientific articles, which increasingly contain URLs, but tend to have a longer 
lifetime than the average blog post. Archiving URLs manually is a tedious process. This gem automates that.

## What it does

For example,

```
Go to www.google.com.
```

will be translated to

```
Go to http://web.archive.org/web/20180225115649/http://www.google.com/.
```

For LaTeX documents, it inserts a special marker with a separate link target and text.

## How to call

```
ruby eternalize_urls.rb file
```