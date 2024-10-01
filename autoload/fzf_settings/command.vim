function! s:BuildFilesCommand() abort
    let l:files_commands = {
                \ 'fd': 'fd --type file --color never --hidden',
                \ 'rg': 'rg --files --color never --ignore-dot --ignore-parent --hidden',
                \ }
    let g:fzf_files_command = l:files_commands[g:fzf_find_tool ==# 'rg' ? 'rg' : 'fd']
    let g:fzf_files_command .= (g:fzf_follow_links ? ' --follow' : '')
    let g:fzf_files_command .= (g:fzf_find_no_ignore_vcs ? ' --no-ignore-vcs' : '')
    return g:fzf_files_command
endfunction

function! s:BuildAFilesCommand() abort
    let l:afiles_commands = {
                \ 'fd': 'fd --type file --color never --no-ignore --exclude .git --hidden --follow',
                \ 'rg': 'rg --files --color never --no-ignore --exclude .git --hidden --follow',
                \ }
    let g:fzf_afiles_command = l:afiles_commands[g:fzf_find_tool ==# 'rg' ? 'rg' : 'fd']
    return g:fzf_afiles_command
endfunction

" Rg command with preview window
function! s:BuildGrepCommand() abort
    let g:fzf_grep_command = 'rg --color always -H --no-heading --line-number --smart-case --hidden'
    let g:fzf_grep_command .= g:fzf_follow_links ? ' --follow' : ''
    let g:fzf_grep_command .= g:fzf_grep_no_ignore_vcs ? ' --no-ignore-vcs' : ''
endfunction

function! fzf_settings#command#init() abort
    call s:BuildFilesCommand()
    call s:BuildAFilesCommand()
    call s:BuildGrepCommand()
endfunction
