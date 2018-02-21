if globpath(&rtp, 'plugin/fzf.vim') == ''
    echohl WarningMsg | echomsg 'fzf.vim is not found.' | echohl none
    finish
endif

if get(g:, 'loaded_fzf_settings_vim', 0)
    finish
endif

if has('nvim')
    let $FZF_DEFAULT_OPTS .= ' --inline-info'
endif

let g:fzf_action = {
            \ 'ctrl-m': 'edit',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit',
            \ 'ctrl-t': 'tabedit',
            \ 'ctrl-o': has('mac') ? '!open' : '!xdg-open',
            \ }

let g:fzf_colors = {
            \ 'fg':      ['fg', 'Normal'],
            \ 'bg':      ['bg', 'Normal'],
            \ 'hl':      ['fg', 'Comment'],
            \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
            \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
            \ 'hl+':     ['fg', 'Statement'],
            \ 'info':    ['fg', 'PreProc'],
            \ 'border':  ['fg', 'Ignore'],
            \ 'prompt':  ['fg', 'Conditional'],
            \ 'pointer': ['fg', 'Exception'],
            \ 'marker':  ['fg', 'Keyword'],
            \ 'spinner': ['fg', 'Label'],
            \ 'header':  ['fg', 'Comment'],
            \ }

function! s:fzf_grep_preview_options(bang) abort
    return a:bang ? fzf#vim#with_preview('up:60%') : fzf#vim#with_preview('right:50%:hidden', '?')
endfunction

function! s:fzf_file_preview_options(bang) abort
    return fzf#vim#with_preview('right:60%:hidden', '?')
endfunction

function! s:setup_extra_fzf_commands() abort
    command! -bang -nargs=? -complete=dir FastFiles
                \ call fzf#vim#files(<q-args>,
                \   extend(s:fzf_file_preview_options(<bang>0), { 'source' : s:fzf_fast_files_cmd }),
                \   <bang>0)

    command! -bang -nargs=* Ag
                \ call fzf#vim#grep(
                \   s:fzf_fast_grep_cmd . shellescape(<q-args>),
                \   1,
                \   s:fzf_grep_preview_options(<bang>0),
                \   <bang>0)

    command! -bang -nargs=* FastAg
                \ call fzf#vim#grep(
                \   s:fzf_fast_fgrep_cmd . shellescape(<q-args>),
                \   1,
                \   s:fzf_grep_preview_options(<bang>0),
                \   <bang>0)
endfunction

" Command for git grep
command! -bang -nargs=* GitGrep
            \ call fzf#vim#grep('git grep --line-number ' . shellescape(<q-args>),
            \   0,
            \   s:fzf_grep_preview_options(<bang>0),
            \   <bang>0)

" Likewise, Files command with preview window
command! -bang -nargs=? -complete=dir Files
            \ call fzf#vim#files(<q-args>, s:fzf_file_preview_options(<bang>0), <bang>0)

command! -bang -nargs=? -complete=dir FastFiles Files<bang> <args>

if executable('rg')
    let s:fzf_fast_files_cmd = 'rg --color=never --hidden --files'
    let s:fzf_fast_grep_cmd  = 'rg --color=always --hidden -H --no-heading --vimgrep --smart-case '
    let s:fzf_fast_fgrep_cmd = s:fzf_fast_grep_cmd . ' -F '
    call s:setup_extra_fzf_commands()
elseif executable('ag')
    let s:fzf_fast_files_cmd = 'ag --nocolor --hidden -l -g ""'
    let s:fzf_fast_grep_cmd  = 'ag --color --hidden --vimgrep --smart-case '
    let s:fzf_fast_fgrep_cmd = s:fzf_fast_grep_cmd . ' -F '
    call s:setup_extra_fzf_commands()
elseif executable('pt')
    let s:fzf_fast_files_cmd = 'pt --nocolor --hidden -l -g='
    let s:fzf_fast_grep_cmd  = 'pt --color --hidden --nogroup --column --smart-case '
    let s:fzf_fast_fgrep_cmd = s:fzf_fast_grep_cmd
    call s:setup_extra_fzf_commands()
endif

let g:loaded_fzf_settings_vim = 1
