function! fzf_settings#grep#rg(query, ...) abort
    let l:bang = get(a:, 1, 0)
    return fzf#vim#grep(g:fzf_grep_command .. ' -- ' .. a:query, fzf_settings#PreviewOptions(l:bang), l:bang)
endfunction

function! fzf_settings#grep#frg(query, ...) abort
    let l:bang = get(a:, 1, 0)
    return fzf#vim#grep(g:fzf_grep_command .. ' -F -- ' .. a:query, fzf_settings#PreviewOptions(l:bang), l:bang)
endfunction

function! fzf_settings#grep#rg_raw(query, ...) abort
    let l:bang = get(a:, 1, 0)
    return fzf#vim#grep(g:fzf_grep_command .. ' ' .. a:query, fzf_settings#PreviewOptions(l:bang), l:bang)
endfunction

function! fzf_settings#grep#rg2(query, ...) abort
    let l:bang = get(a:, 1, 0)
    return fzf#vim#grep2(g:fzf_grep_command .. ' -- ', a:query, fzf_settings#PreviewOptions(l:bang), l:bang)
endfunction

function! fzf_settings#grep#frg2(query, ...) abort
    let l:bang = get(a:, 1, 0)
    return fzf#vim#grep2(g:fzf_grep_command .. ' -F -- ', a:query, fzf_settings#PreviewOptions(l:bang), l:bang)
endfunction

function! fzf_settings#grep#ug(query, ...) abort
    let bang = get(a:, 1, 0)
    return call('fzf#vim#grep', [g:fzf_ug_command . ' ' . a:query, s:preview_options(bang), bang])
endfunction

function! fzf_settings#grep#fug(query, ...) abort
    let bang = get(a:, 1, 0)
    return call('fzf#vim#grep', [g:fzf_ug_command . ' -F ' . a:query, s:preview_options(bang), bang])
endfunction

function! fzf_settings#grep#ug2(query, ...) abort
    let bang = get(a:, 1, 0)
    return call('fzf#vim#grep2', [g:fzf_ug_command, a:query, s:preview_options(bang), bang])
endfunction

function! fzf_settings#grep#fug2(query, ...) abort
    let bang = get(a:, 1, 0)
    return call('fzf#vim#grep2', [g:fzf_ug_command . ' -F ', a:query, s:preview_options(bang), bang])
endfunction
