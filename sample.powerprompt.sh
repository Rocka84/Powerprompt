# Copy this file to ~/.powerprompt.sh and you may
# override all vars and functions of powerprompt

# separator_char="❱"
branch_color_bg="119"

# and create new segments
userAndHostname() {
	# first start a new segment with a
	# foreground and a background color
	nextSegment "0" "112"

	# then add elements to the prompt
	add "${USER}@${HOSTNAME}"
}

myCustomTimeAddon() {
	# skip the call to nextSegment to
	# create an addon to the segment before
	add " $(color "15")$(date +%H:%M:%S)"
}

# You can override `createSegments` to add
# and/or rearrange segments. This example
# shows the available segments and their
# default order, plus the two custom
# segments defined here.
createSegments() {
	createSegmentLastCommand
	#custom
	myCustomTimeAddon
	#custom
	userAndHostname
	createSegmentPwd
	createSegmentGitBranch
	createSegmentGitStatus
	createSegmentPrompt
}

