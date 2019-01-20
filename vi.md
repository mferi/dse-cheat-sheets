
# Command Summary

STARTING vi

     vi filename    edit a file named "filename"
     vi newfile     create a new file named "newfile"

ENTERING TEXT

     i            insert text left of cursor
     a            append text right of cursor

MOVING THE CURSOR

     h            left one space
     j            down one line
     k            up one line
     l            right one space

BASIC EDITING

     x         delete character
     nx        delete n characters
     X         delete character before cursor
     dw        delete word
     ndw       delete n words
     dd        delete line
     ndd       delete n lines
     dG        delete from cursor to end of file
     D         delete characters from cursor to end of line
     r         replace character under cursor
     cw        replace a word
     ncw       replace n words
     C         change text from cursor to end of line
     o         insert blank line below cursor
                  (ready for insertion)
     O         insert blank line above cursor
                  (ready for insertion)
     J         join succeeding line to current cursor line
     nJ        join n succeeding lines to current cursor line
     u         undo last change
     U         restore current line

MOVING AROUND IN A FILE

     w            forward word by word
     b            backward word by word
     $            to end of line
     0 (zero)     to beginning of line
     H            to top line of screen
     M            to middle line of screen
     L            to last line of screen
     G            to last line of file
     1G           to first line of file
     <Control>f   scroll forward one screen
     <Control>b   scroll backward one screen
     <Control>d   scroll down one-half screen
     <Control>u   scroll up one-half screen
     n            repeat last search in same direction
     N            repeat last search in opposite direction

CLOSING AND SAVING A FILE

     ZZ            save file and then quit
     :w            save file
     :q!            discard changes and quit file
