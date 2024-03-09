function! fzf_settings#trim(str) abort
    return substitute(a:str, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

if exists('*trim')
    function! fzf_settings#trim(str) abort
        return trim(a:str)
    endfunction
endif

function! fzf_settings#warn(message) abort
    echohl WarningMsg
    echomsg a:message
    echohl None
    return 0
endfunction

function! fzf_settings#run(...) abort
    return call('fzf#run', a:000)
endfunction

function! fzf_settings#run(...) abort
    return call('fzf#run', a:000)
endfunction

function! fzf_settings#wrap(...) abort
    return call('fzf#wrap', a:000)
endfunction

function! fzf_settings#shellescape(arg, ...) abort
    return call('fzf#shellescape', [a:arg] + a:000)
endfunction

function! fzf_settings#Init() abort
    if exists('*skim#run')
        function! fzf_settings#run(...) abort
            return call('skim#run', a:000)
        endfunction

        function! fzf_settings#wrap(...) abort
            return call('skim#wrap', a:000)
        endfunction

        function! fzf_settings#shellescape(arg, ...) abort
            return call('skim#shellescape', [a:arg] + a:000)
        endfunction
    endif
endfunction

" Toggle fzf follow links for Files and Rg
function! fzf_settings#ToggleFollowLinks() abort
    if g:fzf_follow_links == 0
        let g:fzf_follow_links = 1
        echo 'FZF follows symlinks!'
    else
        let g:fzf_follow_links = 0
        echo 'FZF does not follow symlinks!'
    endif
    call fzf_settings#command#BuildFilesCommand()
    call fzf_settings#command#BuildGrepCommand()
endfunction

function! fzf_settings#IsUniversalCtags(ctags_bin) abort
    return system(a:ctags_bin . ' --version') =~# 'Universal Ctags'
endfunction
