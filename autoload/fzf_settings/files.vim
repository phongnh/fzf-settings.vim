function! fzf_settings#files#run(dir, ...) abort
    let bang = get(a:, 1, 0)
    let opts = extend(fzf_settings#PreviewOptions(bang), { 'source': g:fzf_files_command })
    return fzf#vim#files(a:dir, opts, bang)
endfunction

function! fzf_settings#files#all(dir, ...) abort
    let bang = get(a:, 1, 0)
    let opts = extend(fzf_settings#PreviewOptions(bang), { 'source': g:fzf_afiles_command })
    return fzf#vim#files(a:dir, opts, bang)
endfunction
