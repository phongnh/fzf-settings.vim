function! fzf_settings#grep#rg(query, ...) abort
    let bang = get(a:, 1, 0)
    return fzf#vim#grep(g:fzf_grep_command . ' -- ' . a:query, fzf_settings#PreviewOptions(bang), bang)
endfunction

function! fzf_settings#grep#frg(query, ...) abort
    let bang = get(a:, 1, 0)
    return fzf#vim#grep(g:fzf_grep_command . ' -F -- ' . a:query, fzf_settings#PreviewOptions(bang), bang)
endfunction

function! fzf_settings#grep#rg_raw(query, ...) abort
    let bang = get(a:, 1, 0)
    return fzf#vim#grep(g:fzf_grep_command . ' ' . a:query, fzf_settings#PreviewOptions(bang), bang)
endfunction

function! fzf_settings#grep#rg2(query, ...) abort
    let bang = get(a:, 1, 0)
    return fzf#vim#grep2(g:fzf_grep_command . ' -- ', a:query, fzf_settings#PreviewOptions(bang), bang)
endfunction

function! fzf_settings#grep#frg2(query, ...) abort
    let bang = get(a:, 1, 0)
    return fzf#vim#grep2(g:fzf_grep_command . ' -F -- ', a:query, fzf_settings#PreviewOptions(bang), bang)
endfunction
