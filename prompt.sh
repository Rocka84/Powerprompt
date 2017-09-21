#!/usr/bin/env bash

# Todo:
# - rename vars
# - all icons as vars
# - refine default colors
# - README.md

# export PS1='$('"$HOME"'/powerprompt/prompt.sh "$?")'

last_command_status="$1"

source "$(dirname "$0")/gitstatus.sh"
resetColor="\E[0m"

initTheme() {
	seperator_char=""

    command_color_bg="18"
    command_color_ok="46"
    command_color_fail="160"

    pwd_color_bg="25"
    pwd_color_fg="250"

    branch_color_bg="19"
    branch_color_fg="248"
    branch_color_ahead="252"
    branch_color_behind="202"
    branch_icon_ahead="▲"
    branch_icon_behind=" "

    status_color_bg="26"
    status_color_fg="172"
    status_color_changed="178"
    status_color_staged="40"
    status_color_stashed="219"
    status_color_clean="46"
    status_color_untracked="172"
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
		add " $(color $last_bg $current_bg)${seperator_char}"
	fi
    add "$(color $current_fg $current_bg) "
}

add() {
    prompt="${prompt}${1}"
}

createSegmentGitBranch() {
    [ -z "$git_branch" ] && return

    nextSegment "$branch_color_fg" "$branch_color_bg"
    add " ${git_branch}"
    [ "$git_behind" -gt 0 ] && add " $(color $branch_color_behind) $git_behind"
    [ "$git_ahead" -gt 0 ] && add " $(color $branch_color_ahead)▲$git_ahead"
}

createSegmentGitStatus() {
    [ -z "$git_branch" ] && return

    status=""
    [ "$git_staged" -gt 0 ] &&    status="${status}$(color $status_color_staged) ${git_staged} "
    [ "$git_conflicts" -gt 0 ] && status="${status}$(color $status_color_conflicts) ${git_conflicts} "
    [ "$git_changed" -gt 0 ] &&   status="${status}$(color $status_color_changed) ${git_changed} "
    [ "$git_untracked" -gt 0 ] && status="${status}$(color $status_color_untracked) ${git_untracked} "
    [ "$git_stashed" -gt 0 ] &&   status="${status}$(color $status_color_stashed) ${git_stashed} "

    [ -z "$status" ] && return

    nextSegment  "$status_color_fg" "$status_color_bg" 
    add "${status}\b"
}

createSegmentLastCommand() {
    nextSegment "$command_color_ok" "$command_color_bg"
    if [ "$last_command_status" == "0" ]; then
        add "$(color $current_fg)✔"
    else
        add "$(color $command_color_fail)✘ $last_command_status"
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
	[ "$UID" == "0" ] && add "# " || add "⟫ "
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
