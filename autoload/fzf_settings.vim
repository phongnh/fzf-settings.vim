function! fzf_settings#Trim(str) abort
    return substitute(a:str, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

if exists('*trim')
    function! fzf_settings#Trim(str) abort
        return trim(a:str)
    endfunction
endif

function! fzf_settings#Warn(message) abort
    echohl WarningMsg
    echomsg a:message
    echohl None
    return 0
endfunction

function! fzf_settings#IsUniversalCtags(ctags_bin) abort
    return system(a:ctags_bin . ' --version') =~# 'Universal Ctags'
endfunction

function! fzf_settings#PreviewOptions(...) abort
    return fzf#vim#with_preview(
                \ get(a:, 1, 0) ? 'up:60%' : (&columns >= 120 ? 'right:60%:hidden' : 'up:60%:hidden'),
                \ g:fzf_preview_key)
endfunction
