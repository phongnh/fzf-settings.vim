function! s:messages_sink(e) abort
    let @" = a:e
    echohl ModeMsg
    echo 'Yanked!'
    echohl None
endfunction

function! s:messages_source() abort
    return split(call('execute', ['messages']), '\n')
endfunction

function! fzf_settings#messages#run(...) abort
    call fzf#run(fzf#wrap('messages', {
                \ 'source':  s:messages_source(),
                \ 'sink':    function('s:messages_sink'),
                \ 'options': '+m --prompt "Messages> "',
                \ }, get(a:, 1, 0)))
endfunction
