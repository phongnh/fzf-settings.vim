function! s:preview_options(bang) abort
    return fzf#vim#with_preview(
                \ a:bang ? 'up:60%' : (fzf_settings#ShowRightPreview() ? 'right:50%:hidden' : 'up:60%:hidden'),
                \ g:fzf_preview_key)
endfunction

function! fzf_settings#grep#rg(query, ...) abort
    let bang = get(a:, 1, 0)
    return call('fzf#vim#grep', [g:fzf_grep_command . ' ' . a:query, s:preview_options(bang), bang])
endfunction

function! fzf_settings#grep#frg(query, ...) abort
    let bang = get(a:, 1, 0)
    return call('fzf#vim#grep', [g:fzf_grep_command . ' -F ' . a:query, s:preview_options(bang), bang])
endfunction

function! fzf_settings#grep#rg2(query, ...) abort
    let bang = get(a:, 1, 0)
    return call('fzf#vim#grep2', [g:fzf_grep_command, a:query, s:preview_options(bang), bang])
endfunction

function! fzf_settings#grep#frg2(query, ...) abort
    let bang = get(a:, 1, 0)
    return call('fzf#vim#grep2', [g:fzf_grep_command . ' -F ', a:query, s:preview_options(bang), bang])
endfunction
