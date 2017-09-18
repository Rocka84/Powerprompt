#!/usr/bin/env bash

# export PS1='$(/home/dilli/powerprompt/prompt.sh "$?")'

last_command_status="$1"

initTheme() {
    command_color_bg="27"
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

    status_color_bg="18"
    status_color_fg="172"
    status_color_changed="178"
    status_color_staged="40"
    status_color_stashed="219"
    status_color_clean="46"
    status_color_untracked="172"
    status_color_conflicts="124"

    shell_color_bg="232"
}

initGit() {
    git_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    [ -z "$git_branch" ] && return
    local -a git_status
    local git_status=($("$(dirname $0)/gitstatus.sh" 2>/dev/null))
    git_staged="${git_status[4]}"
    git_conflicts="${git_status[5]}"
    git_changed="${git_status[6]}"
    git_untracked="${git_status[7]}"
    git_stashed="${git_status[7]}"
}

color() {
    echo -ne "\E[38;5;${1}m\E[48;5;${2}m"
}

nextSegment() { # 1=oldBG, 2=newFG, 3=newBG
    echo -n "$(color $1 $3)$(color $2 $3)"
}

add() {
    prompt="${prompt}${1}"
}


createGitSegment() {
    add " $(nextSegment $pwd_color_bg $branch_color_fg $branch_color_bg) "
    add " ${git_branch}"

    status=""
    [ "$git_staged" -gt 0 ] && status="${status} \E[38;5;${status_color_staged}m ${git_staged}"
    [ "$git_conflicts" -gt 0 ] && status="${status} \E[38;5;${status_color_conflicts}m ${git_conflicts}"
    [ "$git_changed" -gt 0 ] && status="${status} \E[38;5;${status_color_changed}m ${git_changed}"
    [ "$git_untracked" -gt 0 ] && status="${status} \E[38;5;${status_color_untracked}m ${git_untracked}"
    [ "$git_stashed" -gt 0 ] && status="${status} \E[38;5;${status_color_stashed}m ${git_stashed}"

    if [ -z "$status" ]; then
        add " $(nextSegment $branch_color_bg $shell_color_bg $shell_color_bg) "
        return
    fi

    add " $(nextSegment $branch_color_bg $status_color_fg $status_color_bg)"
    add "$status"
    add " $(nextSegment $status_color_bg $shell_color_bg $shell_color_bg) "
}


resetColor="\E[0m"

initTheme
initGit

if [ "$last_command_status" == "0" ]; then
    add "$(color $command_color_ok $command_color_bg) ✔"
else
    add "$(color $command_color_fail $command_color_bg) ✘ $last_command_status"
fi

add " $(nextSegment $command_color_bg $pwd_color_fg $pwd_color_bg) "

pwd="$(pwd)"
add "${pwd//$HOME/\~}"

if [ -z "$git_branch" ]; then
    add " $(nextSegment $pwd_color_bg $shell_color_bg $shell_color_bg) "
else
    createGitSegment
fi

add "${resetColor}\n⟫ "

echo -e "$prompt"
