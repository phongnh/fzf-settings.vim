function! s:quickfix_sink(lines) abort
    if len(a:lines) < 2
        return
    endif
    let cmd = fzf_settings#action_for(a:lines[0])
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

function! fzf_settings#quickfix#run(...) abort
    let items = s:quickfix_source()
    if empty(items)
        call fzf_settings#Warn('No quickfix items!')
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
                \ get(a:, 1, 0))
    call extend(opts, {
                \ 'source': items,
                \ 'sink*': function('s:quickfix_sink'),
                \ })
    call fzf#run(opts)
endfunction

function! s:location_list_source() abort
    return map(getloclist(0), 's:quickfix_format(v:val)')
endfunction

function! fzf_settings#quickfix#loclist(...) abort
    let items = s:location_list_source()
    if empty(items)
        call fzf_settings#Warn('No location list items!')
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
                \ get(a:, 1, 0))
    call extend(opts, {
                \ 'source': items,
                \ 'sink*': function('s:quickfix_sink'),
                \ })
    call fzf#run(opts)
endfunction
