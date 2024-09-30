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

" Toggle fzf follow links for Files and Rg
function! fzf_settings#files#toggle_follow_links() abort
    if g:fzf_follow_links == 0
        let g:fzf_follow_links = 1
        echo 'FZF follows symlinks!'
    else
        let g:fzf_follow_links = 0
        echo 'FZF does not follow symlinks!'
    endif
    call fzf_settings#command#init()
endfunction
