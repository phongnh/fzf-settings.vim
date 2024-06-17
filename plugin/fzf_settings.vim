if empty(globpath(&rtp, 'plugin/fzf.vim'))
    echohl WarningMsg | echomsg 'fzf.vim is not found.' | echohl none
    finish
endif

if get(g:, 'loaded_fzf_settings_vim', 0)
    finish
endif

" Key bindings for opening selected files
let g:fzf_action = {
            \ 'ctrl-m': 'edit',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit',
            \ 'ctrl-t': 'tabedit',
            \ 'ctrl-o': has('mac') ? '!open' : '!xdg-open',
            \ }

" Check if Popup/Floating Win is available for FZF or not
if (has('nvim') && exists('*nvim_open_win') && has('nvim-0.4.2')) ||
            \ (exists('*popup_create') && has('patch-8.2.191'))
    let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.7 } }
else
    let g:fzf_layout = {}
endif

if get(g:, 'fzf_inline_info', has('nvim') || has('gui_running'))
    let $FZF_DEFAULT_OPTS .= ' --inline-info'
endif

let g:fzf_preview_key = get(g:, 'fzf_preview_key', ';')

let g:fzf_vim = {}
let g:fzf_vim.preview_window = ['hidden,right,50%,<70(up:50%)', g:fzf_preview_key]

let g:fzf_ctags_bin    = get(g:, 'fzf_ctags_bin', 'ctags')
let g:fzf_ctags_ignore = get(g:, 'fzf_ctags_ignore', expand('~/.config/ctags/ignore'))

if get(g:, 'fzf_universal_ctags', fzf_settings#IsUniversalCtags(g:fzf_ctags_bin)) && filereadable(g:fzf_ctags_ignore)
    let g:fzf_vim.tags_command = printf('%s --exclude=@%s -R', g:fzf_ctags_bin, g:fzf_ctags_ignore)
else
    let g:fzf_vim.tags_command = printf('%s -R', g:fzf_ctags_bin)
endif

let g:fzf_find_tool          = get(g:, 'fzf_find_tool', 'fd')
let g:fzf_find_tool          = g:fzf_find_tool ==# 'rg' && executable('rg') ? 'rg' : 'fd'
let g:fzf_find_no_ignore_vcs = get(g:, 'fzf_find_no_ignore_vcs', 0)
let g:fzf_follow_links       = get(g:, 'fzf_follow_links', 1)
let g:fzf_grep_no_ignore_vcs = get(g:, 'fzf_grep_no_ignore_vcs', 0)

let g:fzf_colors = {
            \ 'fg':         ['fg', 'Normal'],
            \ 'bg':         ['bg', 'Normal'],
            \ 'preview-bg': ['bg', 'NormalFloat'],
            \ 'hl':         ['fg', 'Search'],
            \ 'fg+':        ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
            \ 'bg+':        ['bg', 'CursorLine', 'CursorColumn'],
            \ 'hl+':        ['fg', 'Statement'],
            \ 'info':       ['fg', 'PreProc'],
            \ 'border':     ['fg', 'Ignore'],
            \ 'prompt':     ['fg', 'Conditional'],
            \ 'pointer':    ['fg', 'Exception'],
            \ 'marker':     ['fg', 'Keyword'],
            \ 'spinner':    ['fg', 'Label'],
            \ 'header':     ['fg', 'Comment'],
            \ }

function! s:BuildFilesCommand() abort
    let files_commands = {
                \ 'fd': 'fd --type file --color never --hidden',
                \ 'rg': 'rg --files --color never --ignore-dot --ignore-parent --hidden',
                \ }

    if g:fzf_find_tool ==# 'rg'
        let g:fzf_files_command = files_commands['rg']
    else
        let g:fzf_files_command = files_commands['fd']
    endif

    let g:fzf_files_command .= (g:fzf_follow_links ? ' --follow' : '')
    let g:fzf_files_command .= (g:fzf_find_no_ignore_vcs ? ' --no-ignore-vcs' : '')

    return g:fzf_files_command
endfunction

function! s:BuildAFilesCommand() abort
    let afiles_commands = {
                \ 'fd': 'fd --type file --color never --no-ignore --exclude .git --hidden --follow',
                \ 'rg': 'rg --files --color never --no-ignore --exclude .git --hidden --follow',
                \ }

    if g:fzf_find_tool ==# 'rg'
        let g:fzf_afiles_command = afiles_commands['rg']
    else
        let g:fzf_afiles_command = afiles_commands['fd']
    endif

    return g:fzf_afiles_command
endfunction

" Rg command with preview window
function! s:BuildGrepCommand() abort
    let g:fzf_grep_command = 'rg --color always -H --no-heading --line-number --smart-case --hidden'
    let g:fzf_grep_command .= g:fzf_follow_links ? ' --follow' : ''
    let g:fzf_grep_command .= g:fzf_grep_no_ignore_vcs ? ' --no-ignore-vcs' : ''
endfunction

function! s:SetupFzfSettings() abort
    call s:BuildFilesCommand()
    call s:BuildAFilesCommand()
    call s:BuildGrepCommand()
endfunction

augroup FzfSettings
    autocmd!
    autocmd VimEnter * call <SID>SetupFzfSettings()
augroup END

" Toggle fzf follow links for Files and Rg
function! s:ToggleFzfFollowLinks() abort
    if g:fzf_follow_links == 0
        let g:fzf_follow_links = 1
        echo 'FZF follows symlinks!'
    else
        let g:fzf_follow_links = 0
        echo 'FZF does not follow symlinks!'
    endif
    call s:BuildFilesCommand()
    call s:BuildGrepCommand()
endfunction

command! ToggleFzfFollowLinks call <SID>ToggleFzfFollowLinks()

" Files command with preview window
command! -bang -nargs=? -complete=dir Files  call fzf_settings#files#run(<q-args>, <bang>0)
command! -bang -nargs=? -complete=dir AFiles call fzf_settings#files#all(<q-args>, <bang>0)

command! -bang -nargs=* Rg  call fzf_settings#grep#rg(shellescape(<q-args>), <bang>0)
command! -bang -nargs=* FRg call fzf_settings#grep#frg(shellescape(<q-args>), <bang>0)
command! -bang -nargs=* RRg call fzf_settings#grep#rg(<q-args>, <bang>0)
command! -bang -nargs=* RG  call fzf_settings#grep#rg2(<q-args>, <bang>0)
command! -bang -nargs=* FRG call fzf_settings#grep#frg2(<q-args>, <bang>0)
command! -bang -nargs=* RRG call fzf_settings#grep#rg2(<q-args>, <bang>0)

" Extra commands
command! -bang          Mru          call fzf_settings#mru#run(<bang>0)
command! -bang          MruCwd       call fzf_settings#mru#run_in_cwd(<bang>0)
command! -bang          MruInCwd     call fzf_settings#mru#run_in_cwd(<bang>0)
command! -bang -nargs=? BOutline     call fzf_settings#boutline#run(<q-args>, <bang>0)
command! -bang          Quickfix     call fzf_settings#quickfix#run(<bang>0)
command! -bang          LocationList call fzf_settings#quickfix#loclist(<bang>0)
command! -bang          Registers    call fzf_settings#registers#run(<bang>0)

let g:loaded_fzf_settings_vim = 1
