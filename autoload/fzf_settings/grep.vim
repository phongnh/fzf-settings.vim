function! fzf_settings#grep#rg(query, ...) abort
    let l:bang = get(a:, 1, 0)
    if empty(a:query)
        let l:cmd = g:fzf_grep_command .. ' --colors="match:none" ' .. fzf#shellescape('\S')
    else
        let l:cmd = g:fzf_grep_command .. ' -- ' .. fzf#shellescape(a:query)
    endif
    call fzf#vim#grep(l:cmd, fzf#vim#with_preview(l:bang), l:bang)
endfunction

function! fzf_settings#grep#filter(opts) abort
    let l:opts = extend({ 'args': '', 'bang': 0 }, a:opts)

    let l:cmd = [g:fzf_grep_command]

    if empty(l:opts.args)
        " Skips lines that are empty or contain only spaces/tabs.
        call extend(l:cmd, ['--colors="match:none"', fzf#shellescape('\S')])
    else
        call extend(l:cmd, [l:opts.args])
    endif

    let l:cmd = join(l:cmd, ' ')

    let l:fzf_opts = fzf#vim#with_preview(a:opts.bang)
    let l:fzf_opts = fzf_settings#PreviewOptions(l:opts.bang)
    call extend(l:fzf_opts.options, ['--prompt', 'Rg (FZF)> '])

    call fzf#vim#grep(l:cmd, l:fzf_opts, a:opts.bang)
endfunction
