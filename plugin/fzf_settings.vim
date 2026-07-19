if empty(globpath(&rtp, 'plugin/fzf.vim'))
    echohl WarningMsg | echomsg 'fzf.vim is not found.' | echohl none
    finish
endif

if get(g:, 'loaded_fzf_settings_vim', 0)
    finish
endif

" Key bindings for opening selected files
let g:fzf_action = {
            \ 'ctrl-m': 'edit',
            \ 'ctrl-x': 'split',
            \ 'ctrl-v': 'vsplit',
            \ 'ctrl-t': 'tabedit',
            \ 'ctrl-o': has('mac') ? '!open' : '!xdg-open',
            \ }

" Check if Popup/Floating Win is available for FZF or not
if (exists('*popup_create') && has('patch-8.2.191')) ||
            \ (has('nvim') && exists('*nvim_open_win') && has('nvim-0.4.2'))
    let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.8 } }
else
    let g:fzf_layout = {}
endif

if $FZF_DEFAULT_OPTS !~# '--info=inline-right'
    let $FZF_DEFAULT_OPTS ..= ' --info=inline-right'
endif

" Toggle wrap in preview window
let $FZF_DEFAULT_OPTS ..= " --bind 'alt-;:toggle-preview-wrap,ctrl-r:change-preview-window(right,50%|right,95%,border-left|top,50%,border-down|top,95%,border-down|hidden),shift-left:preview-half-page-up,shift-right:preview-half-page-down'"

let g:fzf_preview_key = get(g:, 'fzf_preview_key', 'alt-p')

let g:fzf_ctags_bin    = get(g:, 'fzf_ctags_bin', 'ctags')
let g:fzf_ctags_ignore = expand(get(g:, 'fzf_ctags_ignore', ''))

let g:fzf_vim = {
            \ 'preview_window': ['right,60%,hidden,border-line,<80(up,hidden)', g:fzf_preview_key],
            \ 'tags_command':   g:fzf_ctags_bin .. (filereadable(g:fzf_ctags_ignore) ? ' --exclude=@' .. g:fzf_ctags_ignore : '') .. ' -R',
            \ }

" let g:fzf_vim.buffers_options = ['--style', 'full', '--border-label', ' Open Buffers ']

let g:fzf_follow_links = get(g:, 'fzf_follow_links', 1)

let g:fzf_colors = {
            \ 'fg':         ['fg', 'Normal'],
            \ 'bg':         ['bg', 'Normal'],
            \ 'hl':         ['fg', 'Search'],
            \ 'fg+':        ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
            \ 'bg+':        ['bg', 'CursorLine', 'CursorColumn'],
            \ 'hl+':        ['fg', 'Statement'],
            \ 'query':      ['fg', 'Normal'],
            \ 'disabled':   ['fg', 'Ignore'],
            \ 'preview-fg': ['fg', 'NormalFloat'],
            \ 'preview-bg': ['bg', 'NormalFloat'],
            \ 'info':       ['fg', 'PreProc'],
            \ 'border':     ['fg', 'Ignore'],
            \ 'prompt':     ['fg', 'Conditional', 'Comment'],
            \ 'pointer':    ['fg', 'Exception'],
            \ 'marker':     ['fg', 'Keyword'],
            \ 'spinner':    ['fg', 'Label'],
            \ 'header':     ['fg', 'Comment'],
            \ }

command! ToggleFzfFollowLinks call fzf_settings#files#toggle_follow_links()

" Files command with preview window
command! -bang -nargs=? -complete=dir Files  call fzf_settings#files#run(<q-args>, <bang>0)
command! -bang -nargs=? -complete=dir AFiles call fzf_settings#files#all(<q-args>, <bang>0)

command! -bang -nargs=* Rg call fzf_settings#grep#rg(<q-args>, <bang>0)
command! -bang -nargs=* RG call fzf_settings#grep#RG(<q-args>, <bang>0)

command! -bang -nargs=* LiveFilter     call fzf_settings#grep#filter({ 'args': <q-args>, 'bang': <bang>0 })
command! -bang -nargs=* LiveGrep       call fzf_settings#grep#live({ 'args': <q-args>, 'bang': <bang>0 })
command! -bang -nargs=* LiveGrepString call fzf_settings#grep#live({ 'args': <q-args>, 'string': 1, 'bang': <bang>0 })

" Extra commands
command! -bang          Mru          call fzf_settings#mru#run(<bang>0)
command! -bang          MruCwd       call fzf_settings#mru#run_in_cwd(<bang>0)
command! -bang          MruInCwd     call fzf_settings#mru#run_in_cwd(<bang>0)
command! -bang -nargs=? BOutline     call fzf_settings#boutline#run(<q-args>, <bang>0)
command! -bang          Quickfix     call fzf_settings#quickfix#quickfix(<bang>0)
command! -bang          LocationList call fzf_settings#quickfix#loclist(<bang>0)
command! -bang          Registers    call fzf_settings#registers#run(<bang>0)

augroup FZFSettingsAutocmds
  autocmd!
  autocmd VimEnter * ++once silent! delcommand Ag
augroup END

let g:loaded_fzf_settings_vim = 1
