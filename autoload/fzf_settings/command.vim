function! s:BuildFilesCommand() abort
    let files_commands = {
                \ 'fd': 'fd --type file --color never --hidden',
                \ 'rg': 'rg --files --color never --ignore-dot --ignore-parent --hidden',
                \ }

    if g:fzf_find_tool ==# 'rg' && executable('rg')
        let g:fzf_files_command = files_commands['rg']
    else
        let g:fzf_files_command = files_commands['fd']
    endif

    let g:fzf_files_command .= (g:fzf_follow_links ? ' --follow' : '')
    let g:fzf_files_command .= (g:fzf_find_no_ignore_vcs ? ' --no-ignore-vcs' : '')

    return g:fzf_files_command
endfunction

function! s:BuildAFilesCommand() abort
    let afiles_commands = {
                \ 'fd': 'fd --type file --color never --no-ignore --exclude .git --hidden --follow',
                \ 'rg': 'rg --files --color never --no-ignore --exclude .git --hidden --follow',
                \ }

    if g:fzf_find_tool ==# 'rg' && executable('rg')
        let g:fzf_afiles_command = afiles_commands['rg']
    else
        let g:fzf_afiles_command = afiles_commands['fd']
    endif

    return g:fzf_afiles_command
endfunction

" Rg command with preview window
function! s:BuildGrepCommand() abort
    let g:fzf_grep_command = 'rg --color always -H --no-heading --line-number --smart-case --hidden'
    let g:fzf_grep_command .= g:fzf_follow_links ? ' --follow' : ''
    let g:fzf_grep_command .= g:fzf_grep_no_ignore_vcs ? ' --no-ignore-vcs' : ''

    let g:fzf_ug_command = 'ug --color=always -H --no-heading --line-number --smart-case --hidden'
    let g:fzf_ug_command .= g:fzf_follow_links ? ' -R' : ''
    let g:fzf_ug_command .= g:fzf_grep_no_ignore_vcs ? ' --no-ignore-files' : ' --ignore-files --ignore-files=.ignore'
endfunction

function! fzf_settings#command#Init() abort
    call s:BuildFilesCommand()
    call s:BuildAFilesCommand()
    call s:BuildGrepCommand()
endfunction
