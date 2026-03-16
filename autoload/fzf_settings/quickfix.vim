function! s:action_for(key, ...) abort
    let l:default = a:0 ? a:1 : ''
    let l:cmd = get(g:fzf_action, a:key, l:default)
    return type(l:cmd) == v:t_string ? l:cmd : l:default
endfunction

function! s:execute_silent(cmd)
    silent keepjumps keepalt execute a:cmd
endfunction

function! s:quickfix_sink(lines) abort
    " ['ctrl-m', 'zero/vim/core/helpers.vim:17:0:function! Source(vimrc) abort']
    if len(a:lines) < 2
        return
    endif
    let l:cmd = s:action_for(a:lines[0])
    let l:cmd = empty(l:cmd) ? 'edit' : l:cmd
    let [l:filename, l:linenr, l:column] = split(a:lines[1], ':')[0:2]
    if stridx('edit', l:cmd) != 0 || fnamemodify(l:filename, ':p') !=# expand('%:p')
        normal! m'
        silent! call s:execute_silent(l:cmd .. ' ' .. fnameescape(l:filename))
    endif
    call cursor(l:linenr, l:column)
    normal! zvzz
endfunction

" Convert Quickfix/LocationList item to Grep format
function! s:quickfix_format(item) abort
    return bufname(a:item.bufnr) .. ':' .. a:item.lnum .. ':' .. a:item.col .. ':' .. a:item.text
endfunction

function! s:quickfix_source() abort
    return map(getqflist(), 's:quickfix_format(v:val)')
endfunction

function! s:run_fzf_list(name, source_items, close_cmd, bang) abort
    if empty(a:source_items)
        call fzf_settings#Warn(printf('No %s items!', a:name ==# 'Quickfix' ? 'quickfix' : 'location list'))
        return
    endif
    let l:opts = fzf#wrap(
                \ a:name,
                \ fzf#vim#with_preview(
                \   {
                \     'placeholder': '{1}:{2}',
                \     'options': ['--layout=reverse-list', '-m', '-d', ':', '--with-nth=1..', '-n', '1,2,4..', '--prompt', a:name .. '> ', '--preview-window', '+{2}-/2'],
                \   },
                \   'hidden,up,60%,border-line',
                \   g:fzf_preview_key
                \ ),
                \ a:bang)
    call extend(l:opts, {
                \ 'source': a:source_items,
                \ 'sink*': function('s:quickfix_sink'),
                \ })
    execute a:close_cmd
    call fzf#run(l:opts)
endfunction

function! fzf_settings#quickfix#quickfix(...) abort
    call s:run_fzf_list('Quickfix', s:quickfix_source(), 'cclose', get(a:, 1, 0))
endfunction

function! s:location_list_source() abort
    return map(getloclist(0), 's:quickfix_format(v:val)')
endfunction

function! fzf_settings#quickfix#loclist(...) abort
    call s:run_fzf_list('LocationList', s:location_list_source(), 'lclose', get(a:, 1, 0))
endfunction
