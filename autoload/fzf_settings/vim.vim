function! s:run(...) abort
    if exists('*skim#run')
        return call('skim#run', a:000)
    else
        return call('fzf#run', a:000)
    endif
endfunction

function! s:wrap(...) abort
    if exists('*skim#wrap')
        return call('skim#wrap', a:000)
    else
        return call('fzf#wrap', a:000)
    endif
endfunction

function! s:warn(message) abort
    echohl WarningMsg
    echomsg a:message
    echohl None
    return 0
endfunction

function! s:file_preview_options(bang) abort
    return fzf#vim#with_preview('right:60%:hidden', g:fzf_preview_key)
endfunction

function! s:grep_preview_options(bang) abort
    return a:bang ? fzf#vim#with_preview('up:60%', g:fzf_preview_key) : fzf#vim#with_preview('right:50%:hidden', g:fzf_preview_key)
endfunction

function! fzf_settings#vim#files(dir, bang) abort
    return call('fzf#vim#files', [a:dir, s:file_preview_options(a:bang), a:bang])
endfunction

" ------------------------------------------------------------------
" Mru
" MruInCwd
" ------------------------------------------------------------------
let s:fzf_mru_exclude = [
            \ '^/usr/',
            \ '^/opt/',
            \ '^/etc/',
            \ '^/var/',
            \ '^/tmp/',
            \ '^/private/',
            \ '\.git/',
            \ '/\?\.gems/',
            \ '\.vim/plugged/',
            \ '\.fugitiveblame$',
            \ 'COMMIT_EDITMSG$',
            \ 'git-rebase-todo$',
            \ ]

function! s:vim_recent_files() abort
    if exists('*fzf#vim#_recent_files')
        let recent_files = fzf#vim#_recent_files()
    else
        let recent_files = fzf#vim#_uniq(
                    \ map(
                    \   filter([expand('%')], 'len(v:val)')
                    \   + filter(map(fzf#vim#_buflisted_sorted(), 'bufname(v:val)'), 'len(v:val)')
                    \   + filter(copy(v:oldfiles), "filereadable(fnamemodify(v:val, ':p'))"),
                    \   'fnamemodify(v:val, ":~:.")'
                    \ )
                    \ )
    endif

    for l:pattern in s:fzf_mru_exclude
        call filter(recent_files, 'v:val !~ l:pattern')
    endfor

    return recent_files
endfunction

function! s:vim_recent_files_in_cwd() abort
    let l:pattern = '^' . getcwd()
    return filter(s:vim_recent_files(), 'fnamemodify(v:val, ":p") =~ l:pattern')
endfunction

function! fzf_settings#vim#mru(bang) abort
    let l:preview_options = fzf#vim#with_preview(
                \ {
                \   'source': s:vim_recent_files(),
                \   'options': ['-m', '--header-lines', !empty(expand('%')), '--prompt', 'MRU> '],
                \ },
                \ 'right:60%',
                \ g:fzf_preview_key
                \ )
    call s:run(s:wrap('mru', l:preview_options, a:bang))
endfunction

function! fzf_settings#vim#mru_in_cwd(bang) abort
    let l:preview_options = fzf#vim#with_preview(
                \ {
                \   'source': s:vim_recent_files_in_cwd(),
                \   'options': ['-m', '--header-lines', !empty(expand('%')), '--prompt', 'MRU> '],
                \ },
                \ 'right:60%',
                \ g:fzf_preview_key
                \ )
    call s:run(s:wrap('mru-in-cwd', l:preview_options, a:bang))
endfunction
