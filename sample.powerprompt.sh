# you may override all vars and functions
# seperator_char="❱"

# and/or create new segments
userAndHostname() {
	# first start a new segment with a
	# foreground and a background color
	nextSegment "0" "112"

	# then add elements to it
	add "${USER}@${HOSTNAME}"
}

myCustomTimeAddon() {
	# skip the call to nextSegment to
	# create an addon to the last segment
	add " $(color "15")$(date +%H:%M:%S)"
}

# You can override this function to add
# or rearrange segments. This example
# shows the available segments and their
# default order.
createSegments() {
	createSegmentLastCommand
	# createSegmentExample
	createSegmentPwd
	createSegmentGitBranch
	createSegmentGitStatus
	createSegmentPrompt
}

