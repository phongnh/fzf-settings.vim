function! s:boutline_format(lists) abort
    for list in a:lists
        let linenr = list[2][:len(list[2])-3]
        let line = fzf_settings#Trim(getline(linenr))
        let list[0] = substitute(line, list[0], printf("\x1b[34m%s\x1b[m", list[0]), '')
        call map(list, "printf('%s', v:val)")
    endfor
    return a:lists
endfunction

function! s:boutline_source(tag_cmds) abort
    if !filereadable(expand('%'))
        throw 'Save the file first'
    endif

    let lines = []
    for cmd in a:tag_cmds
        let lines = split(system(cmd), "\n")
        if !v:shell_error && len(lines)
            break
        endif
    endfor
    if v:shell_error
        throw get(lines, 0, 'Failed to extract tags')
    elseif empty(lines)
        throw 'No tags found'
    endif
    return map(s:boutline_format(map(lines, 'split(v:val, "\t")')), 'join(v:val, "\t")')
endfunction

function! s:boutline_sink(lines) abort
    " ['ctrl-m', 'function! Source(vimrc) abort^I/Users/phong.nguyen/projects/phongnh/dotfiles/zero/vim/core/helpers.vim^I17;"^If']
    if len(a:lines) < 2
        return
    endif
    let cmd = fzf_settings#action_for(a:lines[0])
    if stridx('edit', cmd) != 0
        normal! m'
        silent! call fzf_settings#execute_silent(cmd)
    endif
    " 17;"
    call fzf_settings#execute_silent(split(a:lines[1], "\t")[2])
    normal! zvzz
    " call fzf_settings#execute_silent('normal! zvzz')
endfunction

function! fzf_settings#boutline#run(...) abort
    let filetype = get({ 'cpp': 'c++' }, &filetype, &filetype)
    let filename = fzf#shellescape(expand('%'))
    let tag_cmds = [
                \ printf('%s -f - --sort=no --excmd=number --language-force=%s %s 2>/dev/null', g:fzf_ctags_bin, filetype, filename),
                \ printf('%s -f - --sort=no --excmd=number %s 2>/dev/null', g:fzf_ctags_bin, filename),
                \ ]
    try
        let opts = fzf#wrap(
                    \ 'boutline',
                    \ fzf#vim#with_preview(
                    \   {
                    \     'placeholder': '{2}:{3..}',
                    \     'options': ['--layout=reverse-list', '--ansi', '-m', '-d', '\t', '--with-nth=1', '-n', '1', '--prompt', 'Outline> ', '--preview-window', '+{3}-/2'],
                    \   },
                    \   'right:60%:hidden',
                    \   g:fzf_preview_key
                    \ ),
                    \ get(a:, 1, 0))
        call extend(opts, {
                    \ 'source': s:boutline_source(tag_cmds),
                    \ 'sink*': function('s:boutline_sink'),
                    \ })
        call fzf#run(opts)
    catch
        call fzf_settings#Warn(v:exception)
    endtry
endfunction
