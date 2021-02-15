#!/usr/bin/env bash

# Todo:
# - refine default colors

# export PS1='$('"$HOME"'/powerprompt/prompt.sh "$?")'

last_command_status="$1"

source "$(dirname "$0")/gitstatus.sh"
resetColor="\E[0m"

initTheme() {
    separator_char=""


    command_icon_ok=""
    command_icon_fail=""

    command_color_bg="18"
    command_color_ok="46"
    command_color_fail="160"


    pwd_color_bg="25"
    pwd_color_fg="250"

    branch_icon=""
    branch_color_bg="19"
    branch_color_fg="248"

    branch_icon_ahead=" "
    branch_color_ahead="252"

    branch_icon_behind=" "
    branch_color_behind="202"


    status_color_bg="26"
    status_color_fg="172"

    status_icon_changed=" "
    status_color_changed="178"

    status_icon_staged=" "
    status_color_staged="40"

    status_icon_stashed=" "
    status_color_stashed="219"

    status_icon_untracked=" "
    status_color_untracked="172"

    status_icon_conflicts=" "
    status_color_conflicts="124"


    shell_color_bg="0"
}

color() {
    echo -ne "\E[38;5;${1}m"
    [ -n "$2" ] && echo -ne "\E[48;5;${2}m"
}

setColors() { # 1=newFG, 2=newBG
    last_bg="$current_bg"
    current_fg="$1"
    current_bg="$2"
}

nextSegment() {
    setColors "$1" "$2"
    if [ -n "$last_bg" ]; then
        add " $(color $last_bg $current_bg)${separator_char}"
    fi
    add "$(color $current_fg $current_bg) "
}

add() {
    prompt="${prompt}${1}"
}

createSegmentGitBranch() {
    [ -z "$git_branch" ] && return

    nextSegment "$branch_color_fg" "$branch_color_bg"
    add "$branch_icon ${git_branch}"
    [ "$git_behind" -gt 0 ] && add " $(color $branch_color_behind)${branch_icon_behind}${git_behind}"
    [ "$git_ahead" -gt 0 ] && add " $(color $branch_color_ahead)${branch_icon_ahead}${git_ahead}"
}

createSegmentGitStatus() {
    [ -z "$git_branch" ] && return

    status=""
    [ "$git_staged" -gt 0 ] &&    status="${status}$(color $status_color_staged)${status_icon_staged}${git_staged} "
    [ "$git_conflicts" -gt 0 ] && status="${status}$(color $status_color_conflicts)${status_icon_conflicts}${git_conflicts} "
    [ "$git_changed" -gt 0 ] &&   status="${status}$(color $status_color_changed)${status_icon_changed}${git_changed} "
    [ "$git_untracked" -gt 0 ] && status="${status}$(color $status_color_untracked)${status_icon_untracked}${git_untracked} "
    [ "$git_stashed" -gt 0 ] &&   status="${status}$(color $status_color_stashed)${status_icon_stashed}${git_stashed} "

    [ -z "$status" ] && return

    nextSegment  "$status_color_fg" "$status_color_bg" 
    add "${status}\b"
}

createSegmentLastCommand() {
    nextSegment "$command_color_ok" "$command_color_bg"
    if [ "$last_command_status" == "0" ]; then
        add "$command_icon_ok"
    else
        add "$(color $command_color_fail)$command_icon_fail $last_command_status"
    fi
}

createSegmentPwd() {
    nextSegment "$pwd_color_fg" "$pwd_color_bg"

    pwd="$(pwd)"
    add "${pwd//$HOME/\~}"
}

createSegmentPrompt() {
    nextSegment "$shell_color_bg" "$shell_color_bg"

    add "${resetColor}\n"
    [ "$UID" == "0" ] && add "!:" || add ":"
}

createSegments() {
    createSegmentLastCommand
    createSegmentPwd
    createSegmentGitBranch
    createSegmentGitStatus
    createSegmentPrompt
}

initTheme
[ -f "$HOME/.powerprompt.sh" ] && source "$HOME/.powerprompt.sh" 

loadGitStatus "all"
createSegments
echo -e "$prompt"

exit "$last_command_status"
