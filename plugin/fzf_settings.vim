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


function! s:fzf_file_preview_options(bang) abort
    return fzf#vim#with_preview('right:60%:hidden', '?')
endfunction

function! s:fzf_grep_preview_options(bang) abort
    return a:bang ? fzf#vim#with_preview('up:60%', '?') : fzf#vim#with_preview('right:50%:hidden', '?')
endfunction

" Files command with preview window
command! -bang -nargs=? -complete=dir Files
            \ call fzf#vim#files(<q-args>, s:fzf_file_preview_options(<bang>0), <bang>0)

" All files command with preview window
command! -bang -nargs=? -complete=dir AFiles
            \ call fzf#vim#files(<q-args>, s:fzf_file_preview_options(<bang>0), <bang>0)

let g:fzf_follow_symlinks = get(g:, 'fzf_follow_symlinks', 0)

let s:has_rg = executable('rg')
let s:has_ag = executable('ag')
let s:has_fd = executable('fd')

if s:has_rg || s:has_ag || s:has_fd
    if s:has_rg
        let s:fzf_files_command     = 'rg --color=never --no-ignore-vcs --hidden --files'
        let s:fzf_all_files_command = 'rg --color=never --no-ignore --hidden --files'
    elseif s:has_ag
        let s:fzf_files_command     = 'ag --nocolor --skip-vcs-ignores --hidden -l -g ""'
        let s:fzf_all_files_command = 'ag --nocolor --unrestricted --hidden -l -g ""'
    else
        let s:fzf_files_command     = 'fd --color=never --no-ignore-vcs --hidden --type file'
        let s:fzf_all_files_command = 'fd --color=never --no-ignore --hidden --type file'
    endif

    function! s:build_fzf_options(command, bang) abort
        let cmd = g:fzf_follow_symlinks ? a:command . ' --follow' : a:command
        return extend(s:fzf_file_preview_options(a:bang), { 'source': cmd })
    endfunction

    command! -bang -nargs=? -complete=dir Files
                \ call fzf#vim#files(<q-args>, s:build_fzf_options(s:fzf_files_command, <bang>0), <bang>0)

    command! -bang -nargs=? -complete=dir AFiles
                \ call fzf#vim#files(<q-args>, s:build_fzf_options(s:fzf_all_files_command, <bang>0), <bang>0)
endif

function! s:find_project_dir(starting_path) abort
    if empty(a:starting_path)
        return ''
    endif

    for root_marker in ['.git', '.hg', '.svn']
        let root_dir = finddir(root_marker, a:starting_path . ';')
        if empty(root_dir)
            continue
        endif

        let root_dir = substitute(root_dir, root_marker, '', '')
        if !empty(root_dir)
            let root_dir = fnamemodify(root_dir, ':p:~:.')
        endif

        return root_dir
    endfor

    return ''
endfunction

command! -bang -nargs=0 PFiles execute (<bang>0 ? 'Files!' : 'Files') s:find_project_dir(expand('%:p:h'))

if s:has_rg || s:has_ag
    if s:has_rg
        let s:fzf_grep_command = 'rg --color=always --hidden --vimgrep --smart-case'
    else
        let s:fzf_grep_command = 'ag --color --hidden --vimgrep --smart-case'
    endif

    " Ag command with preview window
    command! -bang -nargs=* Ag
                \ call fzf#vim#grep(s:fzf_grep_command . ' ' . shellescape(<q-args>), 1, s:fzf_grep_preview_options(<bang>0), <bang>0)
endif

let g:loaded_fzf_settings_vim = 1
