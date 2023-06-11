if globpath(&rtp, 'plugin/fzf.vim') == '' && globpath(&rtp, 'plugin/skim.vim') == ''
    echohl WarningMsg | echomsg 'fzf.vim or skim.vim is not found.' | echohl none
    finish
endif

if get(g:, 'loaded_fzf_settings_vim', 0)
    finish
endif

" Check if Popup/Floating Win is available for FZF or not
if has('nvim')
    let s:has_popup = exists('*nvim_win_set_config') && has('nvim-0.4.2')
else
    let s:has_popup = exists('*popup_create') && has('patch-8.2.191')
endif

if s:has_popup
    let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.7 } }
    let g:skim_layout = g:fzf_layout
else
    if has('nvim') || has('gui_running')
        let $FZF_DEFAULT_OPTS .= ' --inline-info'
        let $SKIM_DEFAULT_OPTIONS .= ' --inline-info'
    endif

    if !has('nvim')
        " Make all FZF commands to use fullscreen layout in VIM
        let g:fzf_layout = {}
        let g:skim_layout = {}
    endif
endif

let s:fzf_preview_key    = get(g:, 'fzf_preview_key', 'ctrl-/')
let g:fzf_preview_window = ['right:50%:hidden', s:fzf_preview_key]

let g:fzf_action = {
            \ 'ctrl-m': 'edit',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit',
            \ 'ctrl-t': 'tabedit',
            \ 'ctrl-o': has('mac') ? '!open' : '!xdg-open',
            \ }

function! s:is_universal_ctags(ctags_path) abort
    try
        return system(printf('%s --version', a:ctags_path)) =~# 'Universal Ctags'
    catch
        return 0
    endtry
endfunction

let g:fzf_ctags        = get(g:, 'fzf_ctags', 'ctags')
let g:fzf_ctags_ignore = get(g:, 'fzf_ctags_ignore', expand('~/.ctagsignore'))

if get(g:, 'fzf_universal_ctags', s:is_universal_ctags(g:fzf_ctags)) && filereadable(g:fzf_ctags_ignore)
    let g:fzf_tags_command = printf('%s --exclude=@%s -R', g:fzf_ctags, g:fzf_ctags_ignore)
else
    let g:fzf_tags_command = printf('%s -R', g:fzf_ctags)
endif

command! -bang PFiles execute (<bang>0 ? 'Files!' : 'Files') fzf_settings#find_project_dir(expand('%:p:h'))

function! s:wrap(...) abort
    if exists('*skim#wrap')
        return call('skim#wrap', a:000)
    else
        return call('fzf#wrap', a:000)
    endif
endfunction

function! s:run(...) abort
    if exists('*skim#run')
        return call('skim#run', a:000)
    else
        return call('fzf#run', a:000)
    endif
endfunction

function! s:fzf_file_preview_options(bang) abort
    return fzf#vim#with_preview('right:60%:hidden', s:fzf_preview_key)
endfunction

function! s:fzf_grep_preview_options(bang) abort
    return a:bang ? fzf#vim#with_preview('up:60%', s:fzf_preview_key) : fzf#vim#with_preview('right:50%:hidden', s:fzf_preview_key)
endfunction

let s:fzf_available_commands = filter(['fd', 'rg'], 'executable(v:val)')

let g:fzf_follow_links = get(g:, 'fzf_follow_links', get(g:, 'fzf_follow_symlinks', 0))

" Setup FZF commands with better experiences
if len(s:fzf_available_commands) > 0
    let g:fzf_find_tool    = get(g:, 'fzf_find_tool', 'fd')
    let s:fzf_follow_links = g:fzf_follow_links

    let s:find_commands = {
                \ 'fd': 'fd --type file --color never --no-ignore-vcs --hidden --strip-cwd-prefix',
                \ 'rg': 'rg --files --color never --no-ignore-vcs --ignore-dot --ignore-parent --hidden',
                \ }

    let s:find_all_commands = {
                \ 'fd': 'fd --type file --color never --no-ignore --hidden --follow --strip-cwd-prefix',
                \ 'rg': 'rg --files --color never --no-ignore --hidden --follow',
                \ }

    function! s:build_fzf_find_command() abort
        let l:cmd = s:find_commands[s:fzf_current_command]
        if s:fzf_follow_links
            let l:cmd .= ' --follow'
        endif
        return l:cmd
    endfunction

    function! s:build_fzf_find_all_command() abort
        let l:cmd = s:find_all_commands[s:fzf_current_command]
        return l:cmd
    endfunction

    function! s:detect_fzf_current_command() abort
        let idx = index(s:fzf_available_commands, g:fzf_find_tool)
        let s:fzf_current_command = get(s:fzf_available_commands, idx > -1 ? idx : 0)
    endfunction

    function! s:build_fzf_commands() abort
        let s:fzf_files_command = s:build_fzf_find_command()
        let s:fzf_all_files_command = s:build_fzf_find_all_command()
    endfunction

    function! s:print_fzf_current_command_info() abort
        echo 'FZF is using command `' . s:fzf_files_command . '`!'
    endfunction

    command! PrintFzfCurrentCommandInfo call <SID>print_fzf_current_command_info()

    function! s:change_fzf_files_commands(bang, command) abort
        " Reset to default command
        if a:bang
            call s:detect_fzf_current_command()
        elseif strlen(a:command)
            if index(s:fzf_available_commands, a:command) == -1
                return
            endif
            let s:fzf_current_command = a:command
        else
            let idx = index(s:fzf_available_commands, s:fzf_current_command)
            let s:fzf_current_command = get(s:fzf_available_commands, idx + 1, s:fzf_available_commands[0])
        endif
        call s:build_fzf_commands()
        call s:print_fzf_current_command_info()
    endfunction

    function! s:list_fzf_available_commands(...) abort
        return s:fzf_available_commands
    endfunction

    command! -nargs=? -bang -complete=customlist,<SID>list_fzf_available_commands ChangeFzfFilesCommands call <SID>change_fzf_files_commands(<bang>0, <q-args>)

    function! s:build_fzf_options(command, bang) abort
        return extend(s:fzf_file_preview_options(a:bang), { 'source': a:command })
    endfunction

    " Files command with preview window
    command! -bang -nargs=? -complete=dir Files
                \ call fzf#vim#files(<q-args>, s:build_fzf_options(s:fzf_files_command, <bang>0), <bang>0)

    " All files command with preview window
    command! -bang -nargs=? -complete=dir AFiles
                \ call fzf#vim#files(<q-args>, s:build_fzf_options(s:fzf_all_files_command, <bang>0), <bang>0)

    function! s:toggle_fzf_follow_links() abort
        if s:fzf_follow_links == 0
            let s:fzf_follow_links = 1
            echo 'FZF follows symlinks!'
        else
            let s:fzf_follow_links = 0
            echo 'FZF does not follow symlinks!'
        endif
        call s:build_fzf_commands()
    endfunction

    command! ToggleFzfFollowSymlinks call <SID>toggle_fzf_follow_links()
    command! ToggleFzfFollowLinks call <SID>toggle_fzf_follow_links()

    call s:detect_fzf_current_command()
    call s:build_fzf_commands()
else
    " Files command with preview window
    command! -bang -nargs=? -complete=dir Files
                \ call fzf#vim#files(<q-args>, s:fzf_file_preview_options(<bang>0), <bang>0)

    " All files command with preview window
    command! -bang -nargs=? -complete=dir AFiles
                \ call fzf#vim#files(<q-args>, s:fzf_file_preview_options(<bang>0), <bang>0)
endif

if executable('rg')
    let s:fzf_grep_command = 'rg --color=always -H --no-heading --line-number --smart-case --hidden'
    if g:fzf_follow_links
        let s:fzf_grep_command .= ' --follow'
    endif
    if get(g:, 'fzf_grep_ignore_vcs', 0)
        let s:fzf_grep_command .= ' --no-ignore-vcs'
    endif

    " Rg command with preview window
    command! -bang -nargs=* Rg
                \ call fzf#vim#grep(s:fzf_grep_command . ' ' . shellescape(<q-args>), 1, s:fzf_grep_preview_options(<bang>0), <bang>0)
    command! -bang -nargs=* FRg
                \ call fzf#vim#grep(s:fzf_grep_command . ' -F ' . shellescape(<q-args>), 1, s:fzf_grep_preview_options(<bang>0), <bang>0)
    command! -bang -nargs=* RRg
                \ call fzf#vim#grep(s:fzf_grep_command . ' ' . <q-args>, 1, s:fzf_grep_preview_options(<bang>0), <bang>0)
endif

" Extra commands

function! s:warn(message) abort
    echohl WarningMsg
    echomsg a:message
    echohl None
    return 0
endfunction

command! -bang Mru      call fzf_settings#vim#mru(<bang>0)
command! -bang MruCwd   call fzf_settings#vim#mru_in_cwd(<bang>0)
command! -bang MruInCwd call fzf_settings#vim#mru_in_cwd(<bang>0)

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
    call s:run(s:wrap('jumps', {
                \ 'source':  s:fzf_jumplist(),
                \ 'sink':    function('s:fzf_bufopen'),
                \ 'options': '+m --prompt "Jumps> "',
                \ }, a:bang))
endfunction

command! -bang Jumps call <SID>fzf_jumps(<bang>0)

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
    call s:run(s:wrap(s:source, {
                \ 'source':  s:fzf_messages_source(),
                \ 'sink':    function('s:fzf_yank_sink'),
                \ 'options': '+m --prompt "Messages> "',
                \ }, a:bang))
endfunction

command! -bang Messages call <SID>fzf_messages(<bang>0)

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
    let items = s:fzf_get_quickfix()
    if len(items) == 0
        call s:warn('No quickfix items!')
        return
    endif
    call s:run(s:wrap(s:source, {
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
    let items = s:fzf_get_location_list()
    if len(items) == 0
        call s:warn('No location list items!')
        return
    endif
    call s:run(s:wrap(s:source, {
                \ 'source': items,
                \ 'sink':   function('s:fzf_open_quickfix_item'),
                \ 'options': '--layout=reverse-list --prompt "LocationList> "'
                \ }, a:bang))
endfunction

command! -bang Quickfix call s:fzf_quickfix(<bang>0)
command! -bang LocationList call s:fzf_location_list(<bang>0)

function! s:fzf_yank_register(line) abort
    call setreg('"', getreg(a:line[7]))
    echohl ModeMsg
    echo 'Yanked!'
    echohl None
endfunction

function! s:fzf_get_registers() abort
    return split(call('execute', ['registers']), '\n')[1:]
endfunction

function! s:fzf_registers(bang) abort
    let s:source = 'registers'
    let items = s:fzf_get_registers()
    if len(items) == 0
        call s:warn('No register items!')
        return
    endif
    call s:run(s:wrap(s:source, {
                \ 'source':  items,
                \ 'sink':    function('s:fzf_yank_register'),
                \ 'options': '--layout=reverse-list +m --prompt "Registers> "',
                \ }, a:bang))
endfunction

command! -bang Registers call s:fzf_registers(<bang>0)

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
        let filetype = get({ 'cpp': 'c++' }, &filetype, &filetype)
        let tag_cmds = [
                    \ printf('%s -f - --sort=no --excmd=number --language-force=%s %s 2>/dev/null', g:fzf_ctags, filetype, expand('%:S')),
                    \ printf('%s -f - --sort=no --excmd=number %s 2>/dev/null', g:fzf_ctags, expand('%:S'))
                    \ ]
        call s:run(s:wrap(s:source, {
                    \ 'source':  s:fzf_outline_source(tag_cmds),
                    \ 'sink*':   function('s:fzf_outline_sink'),
                    \ 'options': '--layout=reverse-list -m -d "\t" --with-nth 1 -n 1 --ansi --prompt "Outline> "'
                    \ }, a:bang))
    catch
        call s:warn(v:exception)
    endtry
endfunction

command! -bang BOutline call s:fzf_outline(<bang>0)

let g:loaded_fzf_settings_vim = 1
