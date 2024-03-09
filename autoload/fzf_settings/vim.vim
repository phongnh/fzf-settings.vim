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

