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

function! s:detect_fzf_available_commands() abort
    let s:fzf_available_commands = []
    for cmd in ['rg', 'ag', 'pt', 'fd']
        if executable(cmd)
            call add(s:fzf_available_commands, cmd)
        endif
    endfor
endfunction

call s:detect_fzf_available_commands()

function! s:fzf_file_preview_options(bang) abort
    return fzf#vim#with_preview('right:60%:hidden', '?')
endfunction

" Files command with preview window
command! -bang -nargs=? -complete=dir Files
            \ call fzf#vim#files(<q-args>, s:fzf_file_preview_options(<bang>0), <bang>0)

command! -bang -nargs=? -complete=dir FastFiles Files<bang> <args>

if len(s:fzf_available_commands) == 0
    finish
endif

let s:fzf_follow_symlinks = 0
let s:fzf_current_command = s:fzf_available_commands[0]

function! s:fzf_rg_command() abort
    let cmd = 'rg --color=never --no-ignore-vcs --hidden %s --files'
    let cmd = printf(cmd, s:fzf_follow_symlinks ? '--follow' : '')
    return substitute(cmd, '  ', ' ', 'g')
endfunction

function! s:fzf_ag_command() abort
    let cmd = 'ag --nocolor --skip-vcs-ignores --hidden %s -l -g ""'
    let cmd = printf(cmd, s:fzf_follow_symlinks ? '--follow' : '')
    return substitute(cmd, '  ', ' ', 'g')
endfunction

function! s:fzf_pt_command() abort
    let cmd = 'pt --nocolor --home-ptignore --skip-vcs-ignores --hidden %s -l -g='
    let cmd = printf(cmd, s:fzf_follow_symlinks ? '--follow' : '')
    return substitute(cmd, '  ', ' ', 'g')
endfunction

function! s:fzf_fd_command() abort
    let cmd = 'fd --color=never --no-ignore-vcs --hidden %s --type file .'
    let cmd = printf(cmd, s:fzf_follow_symlinks ? '--follow' : '')
    return substitute(cmd, '  ', ' ', 'g')
endfunction

function! s:build_file_command(command) abort
    if a:command ==# 'rg'
        return s:fzf_rg_command()
    elseif a:command ==# 'ag'
        return s:fzf_ag_command()
    elseif a:command ==# 'pt'
        return s:fzf_pt_command()
    elseif a:command ==# 'fd'
        return s:fzf_fd_command()
    endif
endfunction

function! s:toggle_fzf_follow_symlinks() abort
    if s:fzf_follow_symlinks == 0
        let s:fzf_follow_symlinks = 1
        echo 'FZF follows symlinks!'
    else
        let s:fzf_follow_symlinks = 0
        echo 'FZF does not follow symlinks!'
    endif
endfunction

command! -nargs=0 ToggleFzfFollowSymlinks call <SID>toggle_fzf_follow_symlinks()
nnoremap <silent> =oF :ToggleFzfFollowSymlinks<CR>

function! s:change_fzf_file_command(bang, command) abort
    if a:bang
        let s:fzf_current_command = s:fzf_available_commands[0]
    elseif strlen(a:command)
        if index(s:fzf_available_commands, a:command) == -1
            return
        endif
        let s:fzf_current_command = a:command
    else
        let idx = index(s:fzf_available_commands, s:fzf_current_command)
        let s:fzf_current_command = get(s:fzf_available_commands, idx + 1, s:fzf_available_commands[0])
    endif
    let s:fzf_file_command = s:build_file_command(s:fzf_current_command)
    echo 'FZF is using command `' . s:fzf_file_command . '`!'
endfunction

function! s:list_fzf_available_commands(A, L, P) abort
    return join(s:fzf_available_commands, "\n")
endfunction

command! -nargs=? -bang -complete=custom,<SID>list_fzf_available_commands ChangeFzfFileCommand call <SID>change_fzf_file_command(<bang>0, <q-args>)

nnoremap <silent> =of :ChangeFzfFileCommand<CR>

function! s:build_fzf_options(bang) abort
    return extend(s:fzf_file_preview_options(a:bang), { 'source': s:build_file_command(s:fzf_current_command) })
endfunction

command! -bang -nargs=? -complete=dir FastFiles
            \ call fzf#vim#files(<q-args>, s:build_fzf_options(<bang>0), <bang>0)

let s:fzf_available_grep_commands = filter(s:fzf_available_commands[:], 'v:val !~ "fd"')

if len(s:fzf_available_grep_commands) == 0
    finish
endif

call add(s:fzf_available_grep_commands, 'git')

function! s:build_grep_command(command, fixed_strings) abort
    if a:command ==# 'rg'
        let cmd = 'rg --color=always --hidden --vimgrep --smart-case '
        return a:fixed_strings ? cmd . ' -F ' : cmd
    elseif a:command ==# 'ag'
        let cmd = 'ag --color --hidden --vimgrep --smart-case '
        return a:fixed_strings ? cmd . ' -F ' : cmd
    elseif a:command ==# 'pt'
        return 'pt --color --nogroup --column --home-ptignore --hidden --smart-case '
    else
        let cmd = 'git grep --line-number ' 
        return a:fixed_strings ? cmd . ' -F ' : cmd
    endif
endfunction

function! s:build_current_grep_command(fixed_strings) abort
    let cmd = s:fzf_current_grep_command
    if cmd ==# 'git' && empty(finddir('.git', getcwd() . ';'))
        let cmd = s:fzf_available_grep_commands[0]
    endif
    return s:build_grep_command(cmd, a:fixed_strings)
endfunction

function! s:fzf_grep_preview_options(bang) abort
    return a:bang ? fzf#vim#with_preview('up:60%') : fzf#vim#with_preview('right:50%:hidden', '?')
endfunction

command! -bang -nargs=* Ag
            \ call fzf#vim#grep(s:build_current_grep_command(0) . shellescape(<q-args>), 1, s:fzf_grep_preview_options(<bang>0), <bang>0)

command! -bang -nargs=* FastAg
            \ call fzf#vim#grep(s:build_current_grep_command(1) . shellescape(<q-args>), 1, s:fzf_grep_preview_options(<bang>0), <bang>0)

let s:fzf_current_grep_command = s:fzf_available_grep_commands[0]

function! s:change_fzf_grep_command(bang, command) abort
    if a:bang
        let s:fzf_current_grep_command = s:fzf_available_grep_commands[0]
    elseif strlen(a:command)
        if index(s:fzf_available_grep_commands, a:command) == -1
            return
        endif
        let s:fzf_current_grep_command = a:command
    else
        let idx = index(s:fzf_available_grep_commands, s:fzf_current_grep_command)
        let s:fzf_current_grep_command = get(s:fzf_available_grep_commands, idx + 1, s:fzf_available_grep_commands[0])
    endif
    echo 'FZF Grep is using command `' . s:fzf_current_grep_command . '`!'
endfunction

function! s:list_fzf_available_grep_commands(A, L, P) abort
    return join(s:fzf_available_grep_commands, "\n")
endfunction

command! -nargs=? -bang -complete=custom,<SID>list_fzf_available_grep_commands ChangeFzfGrepCommand call <SID>change_fzf_grep_command(<bang>0, <q-args>)

nnoremap <silent> =oa :ChangeFzfGrepCommand<CR>

let g:loaded_fzf_settings_vim = 1
