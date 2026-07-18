function! fzf_settings#grep#rg(query, ...) abort
    let l:bang = get(a:, 1, 0)

    if empty(a:query)
        let l:cmd = g:fzf_grep_command .. ' --colors="match:none" ' .. fzf#shellescape('\S')
    else
        let l:cmd = g:fzf_grep_command .. ' -- ' .. fzf#shellescape(a:query)
    endif

    let l:fzf_opts = fzf#vim#with_preview(l:bang)
    call extend(l:fzf_opts.options, ['--prompt', 'Rg(fzf)> '])

    call fzf#vim#grep(l:cmd, l:fzf_opts, l:bang)
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

    let l:fzf_opts = fzf_settings#PreviewOptions(l:opts.bang)
    call extend(l:fzf_opts.options, ['--prompt', 'Rg(fzf)> '])

    call fzf#vim#grep(l:cmd, l:fzf_opts, a:opts.bang)
endfunction

function! fzf_settings#grep#RG(query, ...) abort
    let l:bang = get(a:, 1, 0)

    let l:fzf_opts = fzf#vim#with_preview(l:bang)
    call extend(l:fzf_opts.options, ['--prompt', 'RG(regex)> '])

    call fzf#vim#grep2(g:fzf_grep_command .. ' -- ', a:query, l:fzf_opts, l:bang)
endfunction

function! fzf_settings#grep#live(opts) abort
    let l:opts = extend({ 'args': '', 'bang': 0, 'string': 0 }, a:opts)

    let l:cmd = g:fzf_grep_command
    if l:opts.string
        let l:cmd = l:cmd .. ' --fixed-strings'
    endif

    let l:fzf_opts = fzf_settings#PreviewOptions(l:opts.bang)
    call extend(l:fzf_opts.options, ['--prompt', printf('RG(%s)> ', l:opts.string ? 'string' : 'regex')])

    call fzf#vim#grep2(l:cmd .. ' -e ', l:opts.args, l:fzf_opts, l:opts.bang)
endfunction
