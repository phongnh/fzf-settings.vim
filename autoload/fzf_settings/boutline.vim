function! s:tag_commands() abort
    let language = get({ 'cpp': 'c++' }, &filetype, &filetype)
    let filename = fzf#shellescape(expand('%'))
    let null = has('win32') || has('win64') ? 'nul' : '/dev/null'
    let ctags_options = '-f - --sort=no --excmd=number' . get({ 'ruby': ' --kinds-ruby=-r' }, language, '')
    return [
                \ printf('%s %s --language-force=%s %s 2> %s', g:fzf_ctags_bin, ctags_options, language, filename, null),
                \ printf('%s %s %s 2> %s', g:fzf_ctags_bin, ctags_options, filename, null),
                \ ]
endfunction

function! fzf_settings#boutline#run(query, bang) abort
    try
        call fzf#vim#buffer_tags(
                    \ a:query,
                    \ s:tag_commands(),
                    \ fzf#vim#with_preview(
                    \   { 'placeholder': '{2}:{3..}', 'options': ['--prompt', 'Outline> '] },
                    \   'up:60%',
                    \   g:fzf_preview_key
                    \ ),
                    \ a:bang
                    \ )
    catch
        call fzf_settings#Warn(v:exception)
    endtry
endfunction
