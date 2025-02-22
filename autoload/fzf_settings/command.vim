function! s:BuildFilesCommand() abort
    if executable('fd')
        let g:fzf_files_command = 'fd --type file --color never --hidden'
        let g:fzf_files_command .= (g:fzf_follow_links ? ' --follow' : '')
        let g:fzf_files_command .= (g:fzf_find_no_ignore_vcs ? ' --no-ignore-vcs' : '')
    elseif executable('rg')
        let g:fzf_files_command = 'rg --files --color never --ignore-dot --ignore-parent --hidden'
        let g:fzf_files_command .= (g:fzf_follow_links ? ' --follow' : '')
        let g:fzf_files_command .= (g:fzf_find_no_ignore_vcs ? ' --no-ignore-vcs' : '')
    endif
endfunction

function! s:BuildAFilesCommand() abort
    if executable('fd')
        let g:fzf_afiles_command = 'fd --type file --color never --no-ignore --exclude .git --hidden --follow'
    elseif executable('rg')
        let g:fzf_afiles_command = 'rg --files --color never --no-ignore --exclude .git --hidden --follow'
    endif
endfunction

" Rg command with preview window
function! s:BuildGrepCommand() abort
    if executable('rg')
        let g:fzf_grep_command = 'rg --color always -H --no-heading --line-number --smart-case --hidden'
        let g:fzf_grep_command .= g:fzf_grep_no_ignore_vcs ? ' --no-ignore-vcs' : ''
        let g:fzf_grep_command .= g:fzf_follow_links ? ' --follow' : ''
    else
        let g:fzf_grep_command = 'grep -s -I --color=always -R -H --line-number'
        let g:fzf_grep_command .= g:fzf_follow_links ? ' -S' : ''
    endif
endfunction

function! fzf_settings#command#init() abort
    call s:BuildFilesCommand()
    call s:BuildAFilesCommand()
    call s:BuildGrepCommand()
endfunction
