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
    let l:recent_files = fzf#vim#_recent_files()

    for l:pattern in s:fzf_mru_exclude
        call filter(l:recent_files, 'v:val !~# l:pattern')
    endfor

    return l:recent_files
endfunction

function! s:vim_recent_files_in_cwd() abort
    return filter(s:vim_recent_files(), 'v:val !~# "^[~/]"')
endfunction

function! s:preview_options() abort
    return fzf#vim#with_preview(
                \ {
                \   'options': ['-m', '--header-lines', !empty(expand('%')), '--prompt', 'MRU> '],
                \ },
                \ 'up,60%,border-line',
                \ g:fzf_preview_key
                \ )
endfunction

function! fzf_settings#mru#run(...) abort
    let l:opts = fzf#wrap('mru', s:preview_options(), get(a:, 1, 0))
    let l:opts['source'] = s:vim_recent_files()
    call fzf#run(l:opts)
endfunction

function! fzf_settings#mru#run_in_cwd(...) abort
    let l:opts = fzf#wrap('mru', s:preview_options(), get(a:, 1, 0))
    let l:opts['source'] = s:vim_recent_files_in_cwd()
    call fzf#run(l:opts)
endfunction
