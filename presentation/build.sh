#!/usr/bin/env bash
npx @marp-team/marp-cli@latest slides.md -o slides.pdf --theme-set=style/ --allow-local-files
npx @marp-team/marp-cli@latest slides.md -o slides.html --theme-set=style/ --allow-local-files

