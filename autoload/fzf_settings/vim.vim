function! s:show_right_preview() abort
    return &columns >= 120
endfunction

function! s:file_preview_options(bang) abort
    if s:show_right_preview()
        return fzf#vim#with_preview('up:60%:hidden', g:fzf_preview_key)
    endif
    return fzf#vim#with_preview('right:60%:hidden', g:fzf_preview_key)
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
