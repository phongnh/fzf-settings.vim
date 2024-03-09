function! s:action_for(key, ...) abort
    let default = a:0 ? a:1 : ''
    let cmd = get(g:fzf_action, a:key, default)
    return type(cmd) == type('') ? cmd : default
endfunction

function! s:show_right_preview() abort
    return &columns >= 120
endfunction

function! s:file_preview_options(bang) abort
    if s:show_right_preview()
        return fzf#vim#with_preview('up:60%:hidden', g:fzf_preview_key)
    endif
    return fzf#vim#with_preview('right:60%:hidden', g:fzf_preview_key)
endfunction

function! s:grep_preview_options(bang) abort
    if a:bang || !s:show_right_preview()
        return fzf#vim#with_preview('up:60%', g:fzf_preview_key)
    endif
    return fzf#vim#with_preview('right:50%:hidden', g:fzf_preview_key)
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
    return call('fzf#vim#grep', [g:fzf_grep_command . ' ' . a:query, s:grep_preview_options(a:bang), a:bang])
endfunction

function! fzf_settings#vim#frg(query, bang) abort
    return call('fzf#vim#grep', [g:fzf_grep_command . ' -F ' . a:query, s:grep_preview_options(a:bang), a:bang])
endfunction

function! fzf_settings#vim#rg2(query, bang) abort
    return call('fzf#vim#grep2', [g:fzf_grep_command, a:query, s:grep_preview_options(a:bang), a:bang])
endfunction

function! fzf_settings#vim#frg2(query, bang) abort
    return call('fzf#vim#grep2', [g:fzf_grep_command . ' -F ', a:query, s:grep_preview_options(a:bang), a:bang])
endfunction

" ------------------------------------------------------------------
" BOutline
" ------------------------------------------------------------------
function! s:boutline_format(lists) abort
    for list in a:lists
        let linenr = list[2][:len(list[2])-3]
        let line = fzf_settings#trim(getline(linenr))
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
    let filename = fzf#shellescape(expand('%'))
    let tag_cmds = [
                \ printf('%s -f - --sort=no --excmd=number --language-force=%s %s 2>/dev/null', g:fzf_ctags_bin, filetype, filename),
                \ printf('%s -f - --sort=no --excmd=number %s 2>/dev/null', g:fzf_ctags_bin, filename),
                \ ]
    try
        let opts = fzf#wrap(
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
        call fzf#run(opts)
    catch
        call fzf_settings#warn(v:exception)
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
        call fzf_settings#warn('No quickfix items!')
        return
    endif
    let opts = fzf#wrap(
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
    call fzf#run(opts)
endfunction

function! s:location_list_source() abort
    return map(getloclist(0), 's:quickfix_format(v:val)')
endfunction

function! fzf_settings#vim#location_list(bang) abort
    let items = s:location_list_source()
    if empty(items)
        call fzf_settings#warn('No location list items!')
        return
    endif
    let opts = fzf#wrap(
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
    call fzf#run(opts)
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
        call fzf_settings#warn('No register items!')
        return
    endif
    call fzf#run(fzf#wrap('registers', {
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
    call fzf#run(fzf#wrap('messages', {
                \ 'source':  s:messages_source(),
                \ 'sink':    function('s:messages_sink'),
                \ 'options': '+m --prompt "Messages> "',
                \ }, a:bang))
endfunction
