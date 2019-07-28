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

let g:fzf_find_tool       = get(g:, 'fzf_find_tool', 'rg')
let g:fzf_follow_symlinks = get(g:, 'fzf_follow_symlinks', 0)
let s:fzf_follow_symlinks = g:fzf_follow_symlinks

let s:has_rg = executable('rg')
let s:has_ag = executable('ag')
let s:has_fd = executable('fd')

if s:has_rg || s:has_ag || s:has_fd
    if s:has_fd && g:fzf_find_tool == 'fd'
        let s:fzf_files_command     = 'fd --color=never --no-ignore-vcs --hidden --type file'
        let s:fzf_all_files_command = 'fd --color=never --no-ignore --hidden --type file'
    elseif s:has_ag && g:fzf_find_tool == 'ag'
        let s:fzf_files_command     = 'ag --nocolor --skip-vcs-ignores --hidden -l -g ""'
        let s:fzf_all_files_command = 'ag --nocolor --unrestricted --hidden -l -g ""'
    else
        let s:fzf_files_command     = 'rg --color=never --no-ignore-vcs --ignore-dot --ignore-parent --hidden --files'
        let s:fzf_all_files_command = 'rg --color=never --no-ignore --hidden --files'
    endif

    function! s:build_fzf_options(command, bang) abort
        let cmd = s:fzf_follow_symlinks ? a:command . ' --follow' : a:command
        return extend(s:fzf_file_preview_options(a:bang), { 'source': cmd })
    endfunction

    function! s:setup_fzf_commands() abort
        command! -bang -nargs=? -complete=dir Files
                    \ call fzf#vim#files(<q-args>, s:build_fzf_options(s:fzf_files_command, <bang>0), <bang>0)

        command! -bang -nargs=? -complete=dir AFiles
                    \ call fzf#vim#files(<q-args>, s:build_fzf_options(s:fzf_all_files_command, <bang>0), <bang>0)
    endfunction

    call s:setup_fzf_commands()

    function! s:toggle_fzf_follow_symlinks() abort
        if s:fzf_follow_symlinks == 0
            let s:fzf_follow_symlinks = 1
            echo 'FZF follows symlinks!'
        else
            let s:fzf_follow_symlinks = 0
            echo 'FZF does not follow symlinks!'
        endif
        call s:setup_fzf_commands()
    endfunction

    command! -nargs=0 ToggleFzfFollowSymlinks call <SID>toggle_fzf_follow_symlinks()
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

" Extra commands

function! s:warn(message) abort
    echohl WarningMsg
    echomsg a:message
    echohl None
    return 0
endfunction

function! s:fzf_bufopen(e) abort
    let list = split(a:e)
    if len(list) < 4
        return
    endif

    let [linenr, col, file_text] = [list[1], list[2]+1, join(list[3:])]
    let lines = getbufline(file_text, linenr)
    let path = file_text
    if empty(lines)
        if stridx(join(split(getline(linenr))), file_text) == 0
            let lines = [file_text]
            let path = bufname('%')
        elseif filereadable(path)
            let lines = ['buffer unloaded']
        else
            " Skip.
            return
        endif
    endif

    execute 'e '  . path
    call cursor(linenr, col)
endfunction

function! s:fzf_jumplist() abort
    return split(call('execute', ['jumps']), '\n')[1:]
endfunction

function! s:fzf_jumps(bang) abort
    let s:source = 'jumps'
    call fzf#run(fzf#wrap('jumps', {
                \ 'source':  <sid>fzf_jumplist(),
                \ 'sink':    function('s:fzf_bufopen'),
                \ 'options': '+m --prompt "Jumps> "',
                \ }, a:bang))
endfunction

command! -bang -nargs=0 Jumps call <SID>fzf_jumps(<bang>0)

function! s:fzf_yank_sink(e) abort
    let @" = a:e
    echohl ModeMsg
    echo 'Yanked!'
    echohl None
endfunction

function! s:fzf_messages_source() abort
    return split(call('execute', ['messages']), '\n')
endfunction

function! s:fzf_messages(bang) abort
    let s:source = 'messages'
    call fzf#run(fzf#wrap('messages', {
                \ 'source':  <sid>fzf_messages_source(),
                \ 'sink':    function('s:fzf_yank_sink'),
                \ 'options': '+m --prompt "Messages> "',
                \ }, a:bang))
endfunction
command! -bang -nargs=0 Messages call <SID>fzf_messages(<bang>0)

function! s:fzf_open_quickfix_item(e) abort
    let line = a:e
    let filename = fnameescape(split(line, ':\d\+:')[0])
    let linenr = matchstr(line, ':\d\+:')[1:-2]
    let colum = matchstr(line, '\(:\d\+\)\@<=:\d\+:')[1:-2]
    execute 'e ' . filename
    call cursor(linenr, colum)
endfunction

function! s:fzf_quickfix_to_grep(v) abort
    return bufname(a:v.bufnr) . ':' . a:v.lnum . ':' . a:v.col . ':' . a:v.text
endfunction

function! s:fzf_get_quickfix() abort
    return map(getqflist(), 's:fzf_quickfix_to_grep(v:val)')
endfunction

function! s:fzf_quickfix(bang) abort
    let s:source = 'quickfix'
    let items = <sid>fzf_get_quickfix()
    if len(items) == 0
        call s:warn('No quickfix items!')
        return
    endif
    call fzf#run(fzf#wrap('quickfix', {
                \ 'source': items,
                \ 'sink':   function('s:fzf_open_quickfix_item'),
                \ 'options': '--layout=reverse-list --prompt "Quickfix> "'
                \ }, a:bang))
endfunction

function! s:fzf_get_location_list() abort
    return map(getloclist(0), 's:fzf_quickfix_to_grep(v:val)')
endfunction

function! s:fzf_location_list(bang) abort
    let s:source = 'location_list'
    let items = <sid>fzf_get_location_list()
    if len(items) == 0
        call s:warn('No location list items!')
        return
    endif
    call fzf#run(fzf#wrap('location_list', {
                \ 'source': items,
                \ 'sink':   function('s:fzf_open_quickfix_item'),
                \ 'options': '--layout=reverse-list --prompt "LocationList> "'
                \ }, a:bang))
endfunction

command! -bang -nargs=0 Quickfix call s:fzf_quickfix(<bang>0)
command! -bang -nargs=0 LocationList call s:fzf_location_list(<bang>0)

function! s:fzf_get_registers() abort
    return split(call('execute', ['registers']), '\n')[1:]
endfunction

function! s:fzf_registers(bang) abort
    let s:source = 'registers'
    let items = <sid>fzf_get_registers()
    if len(items) == 0
        call s:warn('No register items!')
        return
    endif
    call fzf#run(fzf#wrap('registers', {
                \ 'source':  items,
                \ 'sink':    function('s:fzf_yank_sink'),
                \ 'options': '--layout=reverse-list +m --prompt "Registers> "',
                \ }, a:bang))
endfunction
command! -bang -nargs=0 Registers call s:fzf_registers(<bang>0)

if exists('*trim')
    function! s:strip(str) abort
        return trim(a:str)
    endfunction
else
    function! s:strip(str) abort
        return substitute(a:str, '^\s*\(.\{-}\)\s*$', '\1', '')
    endfunction
endif

function! s:fzf_outline_format(lists) abort
    for list in a:lists
        let linenr = list[2][:len(list[2])-3]
        let line = s:strip(getline(linenr))
        let list[0] = substitute(line, list[0], printf("\x1b[34m%s\x1b[m", list[0]), '')
        call map(list, "printf('%s', v:val)")
    endfor
    return a:lists
endfunction

function! s:fzf_outline_source(tag_cmds) abort
    if !filereadable(expand('%'))
        throw 'Save the file first'
    endif
    let lines = []
    for cmd in a:tag_cmds
        let lines = split(system(cmd), "\n")
        if !v:shell_error && len(lines)
            break
        endif
    endfor
    if v:shell_error
        throw get(lines, 0, 'Failed to extract tags')
    elseif empty(lines)
        throw 'No tags found'
    endif
    return map(s:fzf_outline_format(map(lines, 'split(v:val, "\t")')), 'join(v:val, "\t")')
endfunction

function! s:fzf_outline_sink(lines) abort
    if !empty(a:lines)
        let line = a:lines[0]
        execute split(line, "\t")[2]
    endif
endfunction

function! s:fzf_outline(bang) abort
    try
        let s:source = 'outline'
        let tag_cmds = [
                    \ printf('ctags -f - --sort=no --excmd=number --language-force=%s %s 2>/dev/null', &filetype, expand('%:S')),
                    \ printf('ctags -f - --sort=no --excmd=number %s 2>/dev/null', expand('%:S'))
                    \ ]
        call fzf#run(fzf#wrap('outline', {
                    \ 'source':  s:fzf_outline_source(tag_cmds),
                    \ 'sink*':   function('s:fzf_outline_sink'),
                    \ 'options': '--layout=reverse-list -m -d "\t" --with-nth 1 -n 1 --ansi --prompt "Outline> "'
                    \ }, a:bang))
    catch
        call s:warn(v:exception)
    endtry
endfunction

command! -bang -nargs=0 BOutline call s:fzf_outline(<bang>0)

let g:loaded_fzf_settings_vim = 1
