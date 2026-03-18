function! s:BuildFilesCommand() abort
    if executable('fd')
        let g:fzf_files_command = 'fd --type file --color never --hidden'
        let g:fzf_files_command ..= (g:fzf_follow_links ? ' --follow' : '')
    elseif executable('rg')
        let g:fzf_files_command = 'rg --files --color never --ignore-dot --ignore-parent --hidden'
        let g:fzf_files_command ..= (g:fzf_follow_links ? ' --follow' : '')
    endif
endfunction

function! s:BuildAFilesCommand() abort
    if executable('fd')
        let g:fzf_afiles_command = 'fd --type file --color never --no-ignore --exclude .git --hidden --follow'
    elseif executable('rg')
        let g:fzf_afiles_command = 'rg --files --color never --no-ignore --glob !.git --hidden --follow'
    endif
endfunction

" Rg command with preview window
function! s:BuildGrepCommand() abort
    let g:fzf_grep_command = 'rg --color always -H --no-heading --line-number --smart-case --hidden'
    let g:fzf_grep_command ..= g:fzf_follow_links ? ' --follow' : ''
endfunction

function! fzf_settings#command#init() abort
    call s:BuildFilesCommand()
    call s:BuildAFilesCommand()
    call s:BuildGrepCommand()
endfunction
