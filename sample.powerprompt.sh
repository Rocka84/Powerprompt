# initCustomTheme() {
# 	seperator_char="❱"
# }

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

createSegments() {
	createSegmentLastCommand
	myCustomTimeAddon
	userAndHostname
	createSegmentPwd
	createSegmentGitBranch
	createSegmentGitStatus
}
