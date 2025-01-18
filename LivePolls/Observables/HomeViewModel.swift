var isCreateNewPollButtonDisabled: Bool {
    newPollName.isEmpty || newPollOptions.count < 2 || newPollOptions.count > 6
}

func addOption() {
    guard !newOptionName.isEmpty && newPollOptions.count < 6 else { return }
    newPollOptions.append(newOptionName)
    newOptionName = ""
} 