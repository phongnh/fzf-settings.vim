function! fzf_settings#command#BuildFilesCommand() abort
    let files_commands = {
                \ 'fd': 'fd --type file --color=never --no-ignore-vcs --hidden',
                \ 'rg': 'rg --files --color=never --no-ignore-vcs --ignore-dot --ignore-parent --hidden',
                \ }

    if g:fzf_follow_links
        call map(files_commands, 'v:val . " --follow"')
    endif

    if g:fzf_find_tool ==# 'rg'
        let g:fzf_files_command = files_commands['rg'] . ' || ' . files_commands['fd']
    else
        let g:fzf_files_command = files_commands['fd'] . ' || ' . files_commands['rg']
    endif

    return g:fzf_files_command
endfunction

function! fzf_settings#command#BuildAFilesCommand() abort
    let afiles_commands = {
                \ 'fd': 'fd --type file --color=never --no-ignore --hidden --follow',
                \ 'rg': 'rg --files --color=never --no-ignore --hidden --follow',
                \ }

    if g:fzf_find_tool ==# 'rg'
        let g:fzf_afiles_command = afiles_commands['rg'] . ' || ' . afiles_commands['fd']
    else
        let g:fzf_afiles_command = afiles_commands['fd'] . ' || ' . afiles_commands['rg']
    endif

    return g:fzf_afiles_command
endfunction

" Rg command with preview window
function! fzf_settings#command#BuildGrepCommand() abort
    let g:fzf_grep_command = 'rg --color=always -H --no-heading --line-number --smart-case --hidden'
    let g:fzf_grep_command .= g:fzf_follow_links ? ' --follow' : ''
    let g:fzf_grep_command .= get(g:, 'fzf_grep_ignore_vcs', 0) ? ' --no-ignore-vcs' : ''
endfunction

function! fzf_settings#command#Init() abort
    call fzf_settings#command#BuildFilesCommand()
    call fzf_settings#command#BuildAFilesCommand()
    call fzf_settings#command#BuildGrepCommand()
endfunction
