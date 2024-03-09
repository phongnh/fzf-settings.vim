function! s:sink_with_delta(lines) abort
    if len(a:lines) < 2
        return
    endif
    let cmd = fzf_settings#action_for(a:lines[0])
    if !empty(cmd)
        execute 'silent' cmd
    endif
    let idx = index(s:jump_items, a:lines[1])
    if idx == -1
        return
    endif
    let current = match(s:jump_items, '\v^\s*\>')
    let delta = idx - current
    if delta < 0
        execute 'normal! ' . (-delta) . "\<C-O>"
    else
        execute 'normal! ' . delta . "\<C-I>"
    endif
endfunction

function! s:sink(lines) abort
    if len(a:lines) < 2
        return
    endif

    let cmd = fzf_settings#action_for(a:lines[0])
    if !empty(cmd)
        execute 'silent' cmd
    endif

    let l:line = a:lines[1]
    if empty(l:line) || l:line == '>'
        return
    endif

    let idx = index(s:jump_items, l:line)
    if idx == -1
        return
    endif

    let l:parts = split(l:line)

    if l:parts[0] == '>'
        let [linenr, column, filepath] = [l:parts[2], l:parts[3], join(l:parts[4:])]
    else
        let [linenr, column, filepath] = [l:parts[1], l:parts[2], join(l:parts[3:])]
    endif

    let filepath = fnamemodify(filepath, '%:p')

    let lines = getbufline(filepath, linenr)
    if empty(lines)
        if stridx(join(split(getline(linenr))), filepath) == 0
            let filepath = bufname('%')
        elseif filereadable(filepath)
            " Okay
        else
            " Skip
            return
        endif
    endif

    " if empty(filepath) || !filereadable(filepath)
    "     let filepath = bufname('%')
    " endif

    execute 'edit ' . filepath
    call cursor(linenr, column + 1)
endfunction

function! s:jumps_source() abort
    return split(call('execute', ['jumps']), '\n')
endfunction

function! fzf_settings#jumps#run(...) abort
    let s:jump_items = s:jumps_source()
    if len(s:jump_items) < 2
        call fzf_settings#warn('No jump items!')
        return
    endif

    let opts = fzf#wrap(
                \ 'jumps',
                \ {
                \   'source': extend(s:jump_items[0:0], map(s:jump_items[1:], 'v:val')),
                \   'options': '--no-multi -x --cycle --sync --tac --header-lines 1 --prompt "Jumps> "',
                \ },
                \ get(a:, 1, 0))
    let opts['sink*'] = function('s:sink')
    call fzf#run(opts)
endfunction
