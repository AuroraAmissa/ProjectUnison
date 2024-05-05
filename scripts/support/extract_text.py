#!/usr/bin/env python3

from bs4 import BeautifulSoup
from bs4.element import Comment
from glob import glob

def tag_visible(element):
    if element.parent.name in ['style', 'script', 'head', 'title', 'meta', '[document]']:
        return False
    if isinstance(element, Comment):
        return False
    return True


def filter_body_text(element):
    if element.parent.name in ['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'code']:
        return False
    if "class" in element.parent.attrs:
        if "symbol" in element.parent.attrs["class"]:
            return False
        if "nav-header" in element.parent.attrs["class"]:
            return False
        if "section" in element.parent.attrs["class"]:
            return False
        if "h0" in element.parent.attrs["class"]:
            return False
        if "ability-head" in element.parent.attrs["class"]:
            return True
    if element.parent.name != "body" and element.parent.name != "html":
        return filter_body_text(element.parent)
    return True


def filter_title_text(element):
    if element.parent.name in ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']:
        return True
    if element.parent.name in ['code']:
        return False
    if "class" in element.parent.attrs:
        if "symbol" in element.parent.attrs["class"]:
            return False
        if "a-left" in element.parent.attrs["class"]:
            return False
        if "a-right" in element.parent.attrs["class"]:
            return False
        if "section" in element.parent.attrs["class"]:
            return False
        if "ability-head" in element.parent.attrs["class"]:
            return False
        if "nav-header" in element.parent.attrs["class"]:
            return True
        if "h0" in element.parent.attrs["class"]:
            return True
    if element.parent.name != "body" and element.parent.name != "html":
        return filter_title_text(element.parent)
    return False


def filter_code_text(element):
    if element.parent.name in ['code']:
        return True
    if element.parent.name != "body" and element.parent.name != "html":
        return filter_code_text(element.parent)
    return False


def text_from_html(body, filter_fn):
    soup = BeautifulSoup(body, 'html.parser')
    texts = soup.findAll(string=True)
    visible_texts = filter(tag_visible, texts)
    visible_texts = filter(filter_fn, visible_texts)
    return u" ".join(t.strip() for t in visible_texts)


text = ""
text_title = ""
text_code = ""
for page in glob("build/web/**/*.html", recursive=True):
    html = open(page).read()
    text += text_from_html(html, filter_body_text) + "\n\n"
    text_title += text_from_html(html, filter_title_text) + "\n\n"
    text_code += text_from_html(html, filter_code_text) + "\n\n"

def glyphs(t):
    return repr(sorted(list(set(t))))

open("build/text_body.txt", "w").write(text)
open("build/text_title.txt", "w").write(text_title)
open("build/text_code.txt", "w").write(text_code)
open("build/text_symbols.txt", "w").write("《》☆§●○")

print("Text glyphs: "+glyphs(text))
print("Title glyphs: "+glyphs(text_title))
print("Code glyphs: "+glyphs(text_code))
