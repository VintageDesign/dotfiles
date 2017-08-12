execute pathogen#infect()

colorscheme wargrey

set tabstop=4 " Number of visual spaces per TAB
set softtabstop=0 "Number of spaces in tab when editing
set expandtab
set shiftwidth=4
set smarttab

set number
set showcmd
" Keep the cursor 6 lines from bottom of screen.
set scrolloff=6
" Toggle paste mode with f3
set pastetoggle=<F3>

set wildmenu
set lazyredraw
"Matching brackets highlighted
set showmatch
" Highlight as characters are entered
set incsearch
"Must be turned off manually
set hlsearch
" Turn off search highlighting with enter
nnoremap <CR> :nohl<CR><CR>

" Use ctrl+[jk] to move lines up and down in normal, insert, and visual mode.
nnoremap <C-j> :m .+1<CR>==
nnoremap <C-k> :m .-2<CR>==
inoremap <C-j> <Esc>:m .+1<CR>==gi
inoremap <C-k> <Esc>:m .-2<CR>==gi
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

set foldenable "enable folding
set foldlevelstart=15
set foldnestmax=10 "max fold level

nnoremap <space> za "Space za folds, unfolds
set foldmethod=indent

" Visual movement
nnoremap j gj
nnoremap k gk

" Move to beginning and end of line
nnoremap B ^
nnoremap E $
" Unset $ and ^ to deter vim professionals from using my device.
nnoremap $ <nop>
nnoremap ^ <nop>

" Move the cursor to the left after inserting two matching containers
inoremap '' ''<Left>
inoremap "" ""<Left>
inoremap () ()<Left>
inoremap <> <><Left>
inoremap {} {}<Left>
inoremap [] []<Left>

let s:comment_map = {
    \   "c": '\/\/',
    \   "cpp": '\/\/',
    \   "go": '\/\/',
    \   "java": '\/\/',
    \   "javascript": '\/\/',
    \   "lua": '--',
    \   "scala": '\/\/',
    \   "php": '\/\/',
    \   "python": '#',
    \   "ruby": '#',
    \   "rust": '\/\/',
    \   "sh": '#',
    \   "desktop": '#',
    \   "fstab": '#',
    \   "conf": '#',
    \   "profile": '#',
    \   "bashrc": '#',
    \   "bash_profile": '#',
    \   "mail": '>',
    \   "eml": '>',
    \   "bat": 'REM',
    \   "ahk": ';',
    \   "vim": '"',
    \   "tex": '%',
    \ }

function! ToggleComment()
    if has_key(s:comment_map, &filetype)
        let comment_leader = s:comment_map[&filetype]
        if getline('.') =~ "^\\s*" . comment_leader . " "
            " Uncomment the line
            execute "silent s/^\\(\\s*\\)" . comment_leader . " /\\1/"
        else
            if getline('.') =~ "^\\s*" . comment_leader
                " Uncomment the line
                execute "silent s/^\\(\\s*\\)" . comment_leader . "/\\1/"
            else
                " Comment the line
                execute "silent s/^\\(\\s*\\)/\\1" . comment_leader . " /"
            end
        end
    else
        echo "No comment leader found for filetype"
    end
endfunction

" Comments a single line, use visual mode and gc to comment blocks
nnoremap <C-_> :call ToggleComment()<CR>
vnoremap <C-_> :call ToggleComment()<CR>

set complete=.

" Cursor
set cursorline
set cursorcolumn
"hi Cursor guifg=Green guibg=Black
"hi CursorLine guibg=#333333
"hi CursorColumn guibg=#333333

autocmd vimenter * NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
map <C-n> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
