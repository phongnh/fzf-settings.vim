if globpath(&rtp, 'plugin/fzf.vim') == '' && globpath(&rtp, 'plugin/skim.vim') == ''
    echohl WarningMsg | echomsg 'fzf.vim or skim.vim is not found.' | echohl none
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
let g:skim_action = g:fzf_action

" Check if Popup/Floating Win is available for FZF or not
if (has('nvim') && exists('*nvim_open_win') && has('nvim-0.4.2')) ||
            \ (exists('*popup_create') && has('patch-8.2.191'))
    let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.7 } }
else
    let g:fzf_layout = {}
endif
let g:skim_layout = get(g:, 'skim_layout', g:fzf_layout)

let g:fzf_inline_info = get(g:, 'fzf_inline_info', has('nvim') || has('gui_running'))
if g:fzf_inline_info
    let $FZF_DEFAULT_OPTS .= ' --inline-info'
    let $SKIM_DEFAULT_OPTIONS .= ' --inline-info'
endif

let g:fzf_preview_key    = get(g:, 'fzf_preview_key', 'ctrl-/')
let g:fzf_preview_window = ['right:50%:hidden', g:fzf_preview_key]
if exists('*skim#run')
    let g:fzf_preview_window = 'right:50%:hidden'
    let $SKIM_DEFAULT_OPTIONS .= printf(' --bind %s:toggle-preview', g:fzf_preview_key)
endif

let g:fzf_find_tool    = get(g:, 'fzf_find_tool', 'fd')
let g:fzf_follow_links = get(g:, 'fzf_follow_links', 0)

let g:fzf_ctags        = get(g:, 'fzf_ctags', 'ctags')
let g:fzf_ctags_ignore = get(g:, 'fzf_ctags_ignore', expand('~/.ctagsignore'))

function! s:is_universal_ctags(ctags_path) abort
    try
        return system(printf('%s --version', a:ctags_path)) =~# 'Universal Ctags'
    catch
        return 0
    endtry
endfunction

if get(g:, 'fzf_universal_ctags', s:is_universal_ctags(g:fzf_ctags)) && filereadable(g:fzf_ctags_ignore)
    let g:fzf_tags_command = printf('%s --exclude=@%s -R', g:fzf_ctags, g:fzf_ctags_ignore)
else
    let g:fzf_tags_command = printf('%s -R', g:fzf_ctags)
endif

" Build commands for Files and AFiles
function! s:build_files_command() abort
    let files_commands = {
                \ 'fd': 'fd --type file --color never --no-ignore-vcs --hidden --strip-cwd-prefix',
                \ 'rg': 'rg --files --color never --no-ignore-vcs --ignore-dot --ignore-parent --hidden',
                \ }

    if g:fzf_follow_links
        call map(files_commands, 'v:val . " --follow"')
    endif

    if g:fzf_find_tool ==# 'rg'
        let g:fzf_files_command = files_commands['rg'] . ' || ' . files_commands['fd']
    else
        let g:fzf_files_command = files_commands['fd'] . ' || ' . files_commands['rg']
    endif

    return g:fzf_files_command
endfunction

function! s:build_afiles_command() abort
    let afiles_commands = {
                \ 'fd': 'fd --type file --color never --no-ignore --hidden --follow --strip-cwd-prefix',
                \ 'rg': 'rg --files --color never --no-ignore --hidden --follow',
                \ }

    if g:fzf_find_tool ==# 'rg'
        let g:fzf_afiles_command = afiles_commands['rg'] . ' || ' . afiles_commands['fd']
    else
        let g:fzf_afiles_command = afiles_commands['fd'] . ' || ' . afiles_commands['rg']
    endif

    return g:fzf_afiles_command
endfunction

" Files command with preview window
command! -bang -nargs=? -complete=dir Files  call fzf_settings#vim#files(<q-args>, <bang>0)
command! -bang -nargs=? -complete=dir AFiles call fzf_settings#vim#afiles(<q-args>, <bang>0)

" Rg command with preview window
function! s:build_grep_command() abort
    let g:fzf_grep_has_column = exists('*skim#run')
    let g:fzf_grep_command = 'rg --color=always -H --no-heading --line-number --smart-case --hidden'
    let g:fzf_grep_command .= g:fzf_grep_has_column ? ' --column' : ''
    let g:fzf_grep_command .= g:fzf_follow_links ? ' --follow' : ''
    let g:fzf_grep_command .= get(g:, 'fzf_grep_ignore_vcs', 0) ? ' --no-ignore-vcs' : ''
endfunction

command! -bang -nargs=* Rg  call fzf_settings#vim#rg(shellescape(<q-args>), <bang>0)
command! -bang -nargs=* FRg call fzf_settings#vim#frg(shellescape(<q-args>), <bang>0)
command! -bang -nargs=* RRg call fzf_settings#vim#rg(<q-args>, <bang>0)
command! -bang -nargs=* RG  call fzf_settings#vim#rg2(<q-args>, <bang>0)
command! -bang -nargs=* FRG call fzf_settings#vim#frg2(<q-args>, <bang>0)
command! -bang -nargs=* RRG call fzf_settings#vim#rg2(<q-args>, <bang>0)

" Toggle fzf follow links for Files and Rg
function! s:toggle_fzf_follow_links() abort
    if g:fzf_follow_links == 0
        let g:fzf_follow_links = 1
        echo 'FZF follows symlinks!'
    else
        let g:fzf_follow_links = 0
        echo 'FZF does not follow symlinks!'
    endif
    call s:build_files_command()
    call s:build_grep_command()
endfunction

command! ToggleFzfFollowLinks call <SID>toggle_fzf_follow_links()

" Extra commands
command! -bang Mru          call fzf_settings#vim#mru(<bang>0)
command! -bang MruCwd       call fzf_settings#vim#mru_in_cwd(<bang>0)
command! -bang MruInCwd     call fzf_settings#vim#mru_in_cwd(<bang>0)
command! -bang BOutline     call fzf_settings#vim#buffer_outline(<bang>0)
command! -bang Quickfix     call fzf_settings#vim#quickfix(<bang>0)
command! -bang LocationList call fzf_settings#vim#location_list(<bang>0)
command! -bang Registers    call fzf_settings#vim#registers(<bang>0)
command! -bang Messages     call fzf_settings#vim#messages(<bang>0)

if !exists(':Jumps')
    command! -bang Jumps call fzf_settings#vim#jumps(<bang>0)
endif

function! s:setup_fzf_settings() abort
    call s:build_files_command()
    call s:build_afiles_command()
    call s:build_grep_command()
endfunction

augroup FzfSettings
    autocmd!
    autocmd VimEnter * call <SID>setup_fzf_settings()
augroup END

let g:loaded_fzf_settings_vim = 1
