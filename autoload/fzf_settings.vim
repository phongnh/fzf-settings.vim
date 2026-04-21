function! fzf_settings#Warn(message) abort
    echohl WarningMsg
    echomsg a:message
    echohl None
    return 0
endfunction

function! fzf_settings#PreviewOptions(...) abort
    return fzf#vim#with_preview(
                \ get(a:, 1, 0) ? 'up,60%,border-line' : (&columns >= 120 ? 'right,60%,hidden,border-line' : g:fzf_vim.preview_window[0]),
                \ g:fzf_preview_key)
endfunction

function! fzf_settings#TagCommands(excmd) abort
    let l:language = get({ 'cpp': 'c++' }, &filetype, &filetype)
    let l:filename = fzf#shellescape(expand('%'))
    let l:null = has('win32') || has('win64') ? 'nul' : '/dev/null'
    let l:ctags_options = printf('-f - --sort=no --excmd=%s', a:excmd) .. get({ 'ruby': ' --kinds-ruby=-r' }, l:language, '')
    return [
                \ printf('%s %s --language-force=%s %s 2> %s', g:fzf_ctags_bin, l:ctags_options, l:language, l:filename, l:null),
                \ printf('%s %s %s 2> %s', g:fzf_ctags_bin, l:ctags_options, l:filename, l:null),
                \ ]
endfunction
