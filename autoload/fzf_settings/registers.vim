function! s:registers_sink(line) abort
    call setreg('"', getreg(a:line[7]))
    echohl ModeMsg
    echo 'Yanked!'
    echohl None
endfunction

function! s:registers_source() abort
    return split(call('execute', ['registers']), '\n')[1:]
endfunction

function! fzf_settings#registers#run(...) abort
    let items = s:registers_source()
    if empty(items)
        call fzf_settings#warn('No register items!')
        return
    endif
    call fzf#run(fzf#wrap('registers', {
                \ 'source':  items,
                \ 'sink':    function('s:registers_sink'),
                \ 'options': '--layout=reverse-list +m --prompt "Registers> "',
                \ }, get(a:, 1, 0)))
endfunction
