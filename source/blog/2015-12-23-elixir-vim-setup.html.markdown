---
title: Elixir Vim Setup
date: 2015-12-23 22:28 UTC
tags:
---

Elixir is pretty slick and easy to use with vim.

READMORE

Elixir maintains a [vim config](https://github.com/elixir-lang/vim-elixir)
that's great for syntax highlighting and more, but one of the things I love
about my Rails workflow is running tests from within vim using
[vim rspec](https://github.com/thoughtbot/vim-rspec).

There's the similar [vim-extest](https://github.com/BjRo/vim-extest), but
wouldn't it be great to use the same keybindings for both languages?

```
" .vimrc
" vim-rspec mappings
noremap <Leader>t :call RunCurrentSpecFile()<CR>
noremap <Leader>s :call RunNearestSpec()<CR>
noremap <Leader>l :call RunLastSpec()<CR>
noremap <Leader>a :call RunAllSpecs()<CR>
```

```
" .vim/ftplugin/elixir.vim
map <leader>t :ExTestRunFile<CR>
map <leader>s :ExTestRunTest<CR>
map <leader>l :ExTestRunLast<CR>
map <leader>a :ExTestRunAll<CR>
```

I added the `all` command [here](https://github.com/evan-007/vim-extest).
