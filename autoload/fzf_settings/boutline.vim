function! fzf_settings#boutline#run(query, bang) abort
    try
        call fzf#vim#buffer_tags(
                    \ a:query,
                    \ fzf_settings#BufferTagCommands(),
                    \ fzf#vim#with_preview(
                    \   { 'placeholder': '{2}:{3..}', 'options': ['--prompt', 'Outline> '] },
                    \   fzf_settings#ShowRightPreview() ? 'right:60%' : 'up:60%',
                    \   g:fzf_preview_key
                    \ ),
                    \ a:bang
                    \ )
    catch
        call fzf_settings#Warn(v:exception)
    endtry
endfunction
