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

function! fzf_settings#ShowRightPreview() abort
    return &columns >= 120
endfunction

function! fzf_settings#execute_silent(cmd)
  silent keepjumps keepalt execute a:cmd
endfunction

function! fzf_settings#action_for(key, ...) abort
    let default = a:0 ? a:1 : ''
    let cmd = get(g:fzf_action, a:key, default)
    return type(cmd) == v:t_string ? cmd : default
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
    call fzf_settings#command#Init()
endfunction

function! fzf_settings#IsUniversalCtags(ctags_bin) abort
    return system(a:ctags_bin . ' --version') =~# 'Universal Ctags'
endfunction

function! fzf_settings#BufferTagCommands() abort
    let language = get({ 'cpp': 'c++' }, &filetype, &filetype)
    let filename = fzf#shellescape(expand('%'))
    let null = has('win32') || has('win64') ? 'nul' : '/dev/null'
    let ctags_options = '-f - --sort=no --excmd=number' . get({ 'ruby': ' --kinds-ruby=-r' }, language, '')
    return [
                \ printf('%s %s --language-force=%s %s 2> %s', g:fzf_ctags_bin, ctags_options, language, filename, null),
                \ printf('%s %s %s 2> %s', g:fzf_ctags_bin, ctags_options, filename, null),
                \ ]
endfunction
