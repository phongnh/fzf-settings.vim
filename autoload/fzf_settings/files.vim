function! s:preview_options(bang) abort
    return fzf#vim#with_preview(
                \ a:bang ? 'up:60%:hidden' : (fzf_settings#ShowRightPreview() ? 'right:60%:hidden' : 'up:60%:hidden'),
                \ g:fzf_preview_key)
endfunction

function! fzf_settings#files#run(dir, ...) abort
    let bang = get(a:, 1, 0)
    let opts = extend(s:preview_options(bang), { 'source': g:fzf_files_command })
    return call('fzf#vim#files', [a:dir, opts, bang])
endfunction

function! fzf_settings#files#all(dir, ...) abort
    let bang = get(a:, 1, 0)
    let opts = extend(s:preview_options(bang), { 'source': g:fzf_afiles_command })
    return call('fzf#vim#files', [a:dir, opts, bang])
endfunction
