function! fzf_settings#grep#filter(opts) abort
    let l:opts = extend({ 'args': [] }, a:opts)

    if type(l:opts.args) == v:t_string
        let l:opts.args = [l:opts.args]
    elseif type(l:opts.args) != v:t_list
        let l:opts.args = []
    endif

    call filter(l:opts.args, '!empty(v:val)')

    if empty(l:opts.args)
        " Skips lines that are empty or contain only spaces/tabs.
        call extend(l:opts.args, ['--colors="match:none"', "'\\S'"])
    endif

    let l:cmd = extend([g:fzf_grep_command], l:opts.args)
    let l:cmd = join(l:cmd, ' ')

    let l:fzf_opts = fzf#vim#with_preview(a:opts.bang)
    let l:fzf_opts = fzf_settings#PreviewOptions(l:opts.bang)
    call extend(l:fzf_opts.options, ['--prompt', 'Rg (FZF)> '])

    call fzf#vim#grep(l:cmd, l:fzf_opts, a:opts.bang)
endfunction
