function! s:action_for(key, ...) abort
    let default = a:0 ? a:1 : ''
    let cmd = get(g:fzf_action, a:key, default)
    return type(cmd) == type('') ? cmd : default
endfunction

function! s:run(...) abort
    if exists('*skim#run')
        return call('skim#run', a:000)
    else
        return call('fzf#run', a:000)
    endif
endfunction

function! s:wrap(...) abort
    if exists('*skim#wrap')
        return call('skim#wrap', a:000)
    else
        return call('fzf#wrap', a:000)
    endif
endfunction

function! s:shellescape(arg, ...) abort
    if exists('*skim#shellescape')
        return call('skim#shellescape', [a:arg] + a:000)
    else
        return call('fzf#shellescape', [a:arg] + a:000)
    endif
endfunction

if exists('*trim')
    function! s:trim(str) abort
        return trim(a:str)
    endfunction
else
    function! s:trim(str) abort
        return substitute(a:str, '^\s*\(.\{-}\)\s*$', '\1', '')
    endfunction
endif

function! s:warn(message) abort
    echohl WarningMsg
    echomsg a:message
    echohl None
    return 0
endfunction

function! s:file_preview_options(bang) abort
    return fzf#vim#with_preview('right:60%:hidden', g:fzf_preview_key)
endfunction

function! s:grep_preview_options(bang) abort
    return a:bang ? fzf#vim#with_preview('up:60%', g:fzf_preview_key) : fzf#vim#with_preview('right:50%:hidden', g:fzf_preview_key)
endfunction

" ------------------------------------------------------------------
" Files
" AFiles
" ------------------------------------------------------------------
function! fzf_settings#vim#files(dir, bang) abort
    let opts = extend(s:file_preview_options(a:bang), { 'source': g:fzf_files_command })
    return call('fzf#vim#files', [a:dir, opts, a:bang])
endfunction

function! fzf_settings#vim#afiles(dir, bang) abort
    let opts = extend(s:file_preview_options(a:bang), { 'source': g:fzf_afiles_command })
    return call('fzf#vim#files', [a:dir, opts, a:bang])
endfunction

" ------------------------------------------------------------------
" Rg
" FRg
" RRg
" RG
" FRG
" RRG
" ------------------------------------------------------------------
function! fzf_settings#vim#rg(query, bang) abort
    return call('fzf_settings#vim#grep', [g:fzf_grep_command . ' ' . a:query, s:grep_preview_options(a:bang), a:bang])
endfunction

function! fzf_settings#vim#frg(query, bang) abort
    return call('fzf_settings#vim#grep', [g:fzf_grep_command . ' -F ' . a:query, s:grep_preview_options(a:bang), a:bang])
endfunction

function! fzf_settings#vim#rg2(query, bang) abort
    return call('fzf#vim#grep2', [g:fzf_grep_command, a:query, s:grep_preview_options(a:bang), a:bang])
endfunction

function! fzf_settings#vim#frg2(query, bang) abort
    return call('fzf#vim#grep2', [g:fzf_grep_command . ' -F ', a:query, s:grep_preview_options(a:bang), a:bang])
endfunction

function! fzf_settings#vim#grep(cmd, ...) abort
    if exists('*skim#run')
        try
            let skim_default_command = $SKIM_DEFAULT_COMMAND
            let $SKIM_DEFAULT_COMMAND = a:cmd
            return call('fzf#vim#grep', extend([a:cmd, 0], a:000))
        finally
            let $SKIM_DEFAULT_COMMAND = skim_default_command
        endtry
    else
        return call('fzf#vim#grep', extend([a:cmd], a:000))
    endif
endfunction

" ------------------------------------------------------------------
" Mru
" MruInCwd
" ------------------------------------------------------------------
let s:fzf_mru_exclude = [
            \ '^/usr/',
            \ '^/opt/',
            \ '^/etc/',
            \ '^/var/',
            \ '^/tmp/',
            \ '^/private/',
            \ '\.git/',
            \ '/\?\.gems/',
            \ '\.vim/plugged/',
            \ '\.fugitiveblame$',
            \ 'COMMIT_EDITMSG$',
            \ 'git-rebase-todo$',
            \ ]

function! s:vim_recent_files() abort
    if exists('*fzf#vim#_recent_files')
        let recent_files = fzf#vim#_recent_files()
    else
        let recent_files = fzf#vim#_uniq(
                    \ map(
                    \   filter([expand('%')], 'len(v:val)')
                    \   + filter(map(fzf#vim#_buflisted_sorted(), 'bufname(v:val)'), 'len(v:val)')
                    \   + filter(copy(v:oldfiles), "filereadable(fnamemodify(v:val, ':p'))"),
                    \   'fnamemodify(v:val, ":~:.")'
                    \ )
                    \ )
    endif

    for l:pattern in s:fzf_mru_exclude
        call filter(recent_files, 'v:val !~ l:pattern')
    endfor

    return recent_files
endfunction

function! s:vim_recent_files_in_cwd() abort
    let l:pattern = '^' . getcwd()
    return filter(s:vim_recent_files(), 'fnamemodify(v:val, ":p") =~ l:pattern')
endfunction

function! s:mru_preview_options() abort
    return fzf#vim#with_preview(
                \ {
                \   'options': ['-m', '--header-lines', !empty(expand('%')), '--prompt', 'MRU> '],
                \ },
                \ 'right:60%',
                \ g:fzf_preview_key
                \ )
endfunction

function! fzf_settings#vim#mru(bang) abort
    let opts = s:wrap('mru', s:mru_preview_options(), a:bang)
    let opts['source'] = s:vim_recent_files()
    call s:run(opts)
endfunction

function! fzf_settings#vim#mru_in_cwd(bang) abort
    let opts = s:wrap('mru', s:mru_preview_options(), a:bang)
    let opts['source'] = s:vim_recent_files_in_cwd()
    call s:run(opts)
endfunction

" ------------------------------------------------------------------
" BOutline
" ------------------------------------------------------------------
function! s:boutline_format(lists) abort
    for list in a:lists
        let linenr = list[2][:len(list[2])-3]
        let line = s:trim(getline(linenr))
        let list[0] = substitute(line, list[0], printf("\x1b[34m%s\x1b[m", list[0]), '')
        call map(list, "printf('%s', v:val)")
    endfor
    return a:lists
endfunction

function! s:boutline_source(tag_cmds) abort
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
    return map(s:boutline_format(map(lines, 'split(v:val, "\t")')), 'join(v:val, "\t")')
endfunction

function! s:boutline_sink(lines) abort
    call s:warn(string(a:lines))
    if len(a:lines) < 2
       return
    endif
    normal! m'
    let cmd = s:action_for(a:lines[0])
    if !empty(cmd)
        execute 'silent' cmd '%'
    endif
    execute split(a:lines[1], "\t")[2]
    normal! zvzz
endfunction

function! fzf_settings#vim#buffer_outline(bang) abort
    let filetype = get({ 'cpp': 'c++' }, &filetype, &filetype)
    let filename = s:shellescape(expand('%'))
    let tag_cmds = [
                \ printf('%s -f - --sort=no --excmd=number --language-force=%s %s 2>/dev/null', g:fzf_ctags, filetype, filename),
                \ printf('%s -f - --sort=no --excmd=number %s 2>/dev/null', g:fzf_ctags, filename),
                \ ]
    try
        let opts = s:wrap(
                    \ 'boutline',
                    \ fzf#vim#with_preview(
                    \   {
                    \     'placeholder': '{2}:{3..}',
                    \     'options': ['--layout=reverse-list', '--ansi', '-m', '-d', '\t', '--with-nth=1', '-n', '1', '--prompt', 'Outline> ', '--preview-window', '+{3}-/2'],
                    \   },
                    \   'right:60%:hidden',
                    \   g:fzf_preview_key
                    \ ),
                    \ a:bang)
        call extend(opts, {
                    \ 'source': s:boutline_source(tag_cmds),
                    \ 'sink*': function('s:boutline_sink'),
                    \ })
        call s:run(opts)
    catch
        call s:warn(v:exception)
    endtry
endfunction

" ------------------------------------------------------------------
" Quickfix
" LocationList
" ------------------------------------------------------------------
function! s:quickfix_sink(lines) abort
    if len(a:lines) < 2
        return
    endif
    let cmd = s:action_for(a:lines[0])
    let cmd = empty(cmd) ? 'edit' : cmd
    let [filename, linenr, column] = split(a:lines[1], ':')[0:2]
    normal! m'
    execute 'silent' cmd filename
    call cursor(linenr, column)
    normal! zvzz
endfunction

" Convert Quickfix/LocationList item to Grep format
function! s:quickfix_format(item) abort
    return bufname(a:item.bufnr) . ':' . a:item.lnum . ':' . a:item.col . ':' . a:item.text
endfunction

function! s:quickfix_source() abort
    return map(getqflist(), 's:quickfix_format(v:val)')
endfunction

function! fzf_settings#vim#quickfix(bang) abort
    let items = s:quickfix_source()
    if empty(items)
        call s:warn('No quickfix items!')
        return
    endif
    let opts = s:wrap(
                \ 'quickfix',
                \ fzf#vim#with_preview(
                \   {
                \     'placeholder': '{1}:{2}',
                \     'options': ['--layout=reverse-list', '-m', '-d', ':', '--with-nth=1..', '-n', '1,2,4..', '--prompt', 'Quickfix> ', '--preview-window', '+{2}-/2'],
                \   },
                \   'up:60%:hidden',
                \   g:fzf_preview_key
                \ ),
                \ a:bang)
    call extend(opts, {
                \ 'source': items,
                \ 'sink*': function('s:quickfix_sink'),
                \ })
    call s:run(opts)
endfunction

function! s:location_list_source() abort
    return map(getloclist(0), 's:quickfix_format(v:val)')
endfunction

function! fzf_settings#vim#location_list(bang) abort
    let items = s:location_list_source()
    if empty(items)
        call s:warn('No location list items!')
        return
    endif
    let opts = s:wrap(
                \ 'location-list',
                \ fzf#vim#with_preview(
                \   {
                \     'placeholder': '{1}:{2}',
                \     'options': ['--layout=reverse-list', '-m', '-d', ':', '--with-nth=1..', '-n', '1,2,4..', '--prompt', 'LocationList> ', '--preview-window', '+{2}-/2'],
                \   },
                \   'up:60%:hidden',
                \   g:fzf_preview_key
                \ ),
                \ a:bang)
    call extend(opts, {
                \ 'source': items,
                \ 'sink*': function('s:quickfix_sink'),
                \ })
    call s:run(opts)
endfunction

" ------------------------------------------------------------------
" Registers
" ------------------------------------------------------------------
function! s:registers_sink(line) abort
    call setreg('"', getreg(a:line[7]))
    echohl ModeMsg
    echo 'Yanked!'
    echohl None
endfunction

function! s:registers_source() abort
    return split(call('execute', ['registers']), '\n')[1:]
endfunction

function! fzf_settings#vim#registers(bang) abort
    let items = s:registers_source()
    if empty(items)
        call s:warn('No register items!')
        return
    endif
    call s:run(s:wrap('registers', {
                \ 'source':  items,
                \ 'sink':    function('s:registers_sink'),
                \ 'options': '--layout=reverse-list +m --prompt "Registers> "',
                \ }, a:bang))
endfunction

" ------------------------------------------------------------------
" Messages
" ------------------------------------------------------------------
function! s:messages_sink(e) abort
    let @" = a:e
    echohl ModeMsg
    echo 'Yanked!'
    echohl None
endfunction

function! s:messages_source() abort
    return split(call('execute', ['messages']), '\n')
endfunction

function! fzf_settings#vim#messages(bang) abort
    call s:run(s:wrap('messages', {
                \ 'source':  s:messages_source(),
                \ 'sink':    function('s:messages_sink'),
                \ 'options': '+m --prompt "Messages> "',
                \ }, a:bang))
endfunction

" ------------------------------------------------------------------
" Jumps
" ------------------------------------------------------------------
function! s:jumps_delta_sink(lines) abort
    call s:warn(a:lines)
    if len(a:lines) < 2
        return
    endif
    let cmd = s:action_for(a:lines[0])
    if !empty(cmd)
        execute 'silent' cmd
    endif
    let idx = index(s:jump_items, a:lines[1])
    if idx == -1
        return
    endif
    let current = match(s:jump_items, '\v^\s*\>')
    let delta = idx - current
    echomsg string(s:jump_items)
    echomsg printf('idx: %d, current: %d, delta: %d', idx, current, delta)
    if delta < 0
        execute 'normal! ' . (-delta) . "\<C-O>"
    else
        execute 'normal! ' . delta . "\<C-I>"
    endif
endfunction

function! s:jumps_sink(lines) abort
    if len(a:lines) < 2
        return
    endif

    let cmd = s:action_for(a:lines[0])
    if !empty(cmd)
        execute 'silent' cmd
    endif

    let l:line = a:lines[1]
    if empty(l:line) || l:line == '>'
        return
    endif

    let idx = index(s:jump_items, l:line)
    if idx == -1
        return
    endif

    let l:parts = split(l:line)

    if l:parts[0] == '>'
        let [linenr, column, filepath] = [l:parts[2], l:parts[3], join(l:parts[4:])]
    else
        let [linenr, column, filepath] = [l:parts[1], l:parts[2], join(l:parts[3:])]
    endif

    let lines = getbufline(filepath, linenr)
    if empty(lines)
        if stridx(join(split(getline(linenr))), filepath) == 0
            let filepath = bufname('%')
        elseif filereadable(filepath)
            " Okay
        else
            " Skip
            return
        endif
    endif

    " if empty(filepath) || !filereadable(filepath)
    "     let filepath = bufname('%')
    " endif

    execute 'edit ' . filepath
    call cursor(linenr, column + 1)
endfunction

function! s:jumps_source() abort
    return split(call('execute', ['jumps']), '\n')
endfunction

function! fzf_settings#vim#jumps(bang) abort
    let s:jump_items = s:jumps_source()
    if len(s:jump_items) < 2
        call s:warn('No jump items!')
        return
    endif

    let current = -match(s:jump_items, '\v^\s*\>')
    let opts = s:wrap(
                \ 'jumps',
                \ {
                \   'source': extend(s:jump_items[0:0], map(s:jump_items[1:], 'v:val')),
                \   'options': '--no-multi -x --cycle --sync --tac --header-lines 1 --prompt "Jumps> "',
                \ },
                \ a:bang)
    let opts['sink*'] = function('s:jumps_sink')
    call s:run(opts)
endfunction
