package chat

import data.utils
import future.keywords

LogEvents := utils.GetEvents("chat_logs")

##############
# GWS.CHAT.1 #
##############

#
# Baseline GWS.CHAT.1v1
#--
UserFriendlyValues1_1 := {
    "true": "History is OFF",
    "false": "History is ON"
}

GetFriendlyValue1_1(Value) := "History is OFF" if {
    Value == "true"
} else := "History is ON" if {
    Value == "false"
} else := Value

NonCompliantOUs1_1 contains {
    "Name": OU,
    "Value": concat(" ", [
        "Default conversation history is set to",
        GetFriendlyValue1_1(LastEvent.NewValue)
    ])
}
if {
    some OU in utils.OUsWithEvents
    Events := utils.FilterEvents(LogEvents, "ChatArchivingProto chatsDefaultToOffTheRecord", OU)
    count(Events) > 0
    LastEvent := utils.GetLastEvent(Events)
    LastEvent.NewValue == "true"
}

tests contains {
    "PolicyId": "GWS.CHAT.1.1v0.1",
    "Criticality": "Should",
    "ReportDetails": utils.NoSuchEventDetails(DefaultSafe, utils.TopLevelOU),
    "ActualValue": "No relevant event in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := utils.FilterEvents(LogEvents,  "ChatArchivingProto chatsDefaultToOffTheRecord", utils.TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.CHAT.1.1v0.1",
    "Criticality": "Should",
    # Empty list in next line for non compliant groups, as this setting can't be changed at the group level
    "ReportDetails": utils.ReportDetails(NonCompliantOUs1_1, []),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs1_1},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := utils.FilterEvents(LogEvents,  "ChatArchivingProto chatsDefaultToOffTheRecord", utils.TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs1_1) == 0
}
#--

#
# Baseline GWS.CHAT.1.2v0.1
#--
NonCompliantOUs1_2 contains {
    "Name": OU,
    "Value": concat(" ", [
        "Allow users to change their history setting is set to",
        LastEvent.NewValue
    ])
}
if {
    some OU in utils.OUsWithEvents
    Events := utils.FilterEvents(LogEvents,  "ChatArchivingProto allow_chat_archiving_setting_modification", OU)
    count(Events) > 0
    LastEvent := utils.GetLastEvent(Events)
    LastEvent.NewValue == "true"
}

tests contains {
    "PolicyId": "GWS.CHAT.1.2v0.1",
    "Criticality": "Shall",
    "ReportDetails": utils.NoSuchEventDetails(DefaultSafe, utils.TopLevelOU),
    "ActualValue": "No relevant event in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    SettingName := "ChatArchivingProto allow_chat_archiving_setting_modification"
    Events := utils.FilterEvents(LogEvents, SettingName, utils.TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.CHAT.1.2v0.1",
    "Criticality": "Shall",
    "ReportDetails": utils.ReportDetails(NonCompliantOUs1_2, []),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs1_2},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    SettingName := "ChatArchivingProto allow_chat_archiving_setting_modification"
    Events := utils.FilterEvents(LogEvents, SettingName, utils.TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs1_2) == 0
}
#--


##############
# GWS.CHAT.2 #
##############

#
# Baseline GWS.CHAT.2.1v0.1
#--
GetFriendlyValue2_1(Value) := "Allow all files" if {
    Value == "ALL_FILES"
} else := "Images only" if {
    Value == "IMAGES_ONLY"
} else := Value

NonCompliantOUs2_1 contains {
    "Name": OU,
    "Value": concat(" ", [
        "External filesharing is set to",
        GetFriendlyValue2_1(LastEvent.NewValue)
    ])
}
if {
    some OU in utils.OUsWithEvents
    Events := utils.FilterEvents(LogEvents,  "DynamiteFileSharingSettingsProto external_file_sharing_setting", OU)
    count(Events) > 0
    LastEvent := utils.GetLastEvent(Events)
    LastEvent.NewValue != "NO_FILES"
    LastEvent.NewValue != "DELETE_APPLICATION_SETTING"
}

tests contains {
    "PolicyId": "GWS.CHAT.2.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": utils.NoSuchEventDetails(DefaultSafe, utils.TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    SettingName := "DynamiteFileSharingSettingsProto external_file_sharing_setting"
    Events := utils.FilterEvents(LogEvents, SettingName, utils.TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.CHAT.2.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": utils.ReportDetails(NonCompliantOUs2_1, []),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs2_1},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    SettingName := "DynamiteFileSharingSettingsProto external_file_sharing_setting"
    Events := utils.FilterEvents(LogEvents, SettingName, utils.TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs2_1) == 0
}
#--

##############
# GWS.CHAT.3 #
##############

#
# Baseline GWS.CHAT.3.1v0.1
#--
GetFriendlyValue3_1(Value) := "History is OFF by default" if {
    Value == "DEFAULT_OFF_THE_RECORD"
} else := "History is ALWAYS OFF" if {
    Value == "ALWAYS_OFF_THE_RECORD"
} else := Value

NonCompliantOUs3_1 contains {
    "Name": OU,
    "Value": concat(" ", [
        "Conversation history settings for spaces is set to",
        GetFriendlyValue3_1(LastEvent.NewValue)
    ])
} if {
    some OU in utils.OUsWithEvents
    Events := utils.FilterEvents(LogEvents, "RoomOtrSettingsProto otr_state", OU)
    count(Events) > 0
    LastEvent := utils.GetLastEvent(Events)
    not contains("DEFAULT_ON_THE_RECORD ALWAYS_ON_THE_RECORD", LastEvent.NewValue)
}

tests contains {
    "PolicyId": "GWS.CHAT.3.1v0.1",
    "Criticality": "Should",
    "ReportDetails": utils.NoSuchEventDetails(DefaultSafe, utils.TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := utils.FilterEvents(LogEvents,  "RoomOtrSettingsProto otr_state", utils.TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.CHAT.3.1v0.1",
    "Criticality": "Should",
    "ReportDetails": utils.ReportDetails(NonCompliantOUs3_1, []),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs3_1},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := utils.FilterEvents(LogEvents,  "RoomOtrSettingsProto otr_state", utils.TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs3_1) == 0
}
#--

##############
# GWS.CHAT.4 #
##############

#
# Baseline GWS.CHAT.4.1v0.1
#--
default NoSuchEvent4_1(_) := true

NoSuchEvent4_1(TopLevelOU) := true if {
    Events := utils.FilterEvents(LogEvents, "RestrictChatProto restrictChatToOrganization", TopLevelOU)
    count(Events) == 0
}

NoSuchEvent4_1(TopLevelOU) := true if {
    # No such event...
    Events := utils.FilterEvents(LogEvents, "RestrictChatProto externalChatRestriction", TopLevelOU)
    count(Events) == 0
}

NonCompliantOUs4_1 contains {
    "Name": OU,
    "Value": "External chat is enabled for all domains"
}

 if {
    some OU in utils.OUsWithEvents
    Events_A := utils.FilterEvents(LogEvents, "RestrictChatProto restrictChatToOrganization", OU)
    count(Events_A) > 0
    LastEvent_A := utils.GetLastEvent(Events_A)
    LastEvent_A.NewValue != "DELETE_APPLICATION_SETTING"

    Events_B := utils.FilterEvents(LogEvents, "RestrictChatProto externalChatRestriction", OU)
    count(Events_B) > 0
    LastEvent_B := utils.GetLastEvent(Events_B)
    LastEvent_B.NewValue != "DELETE_APPLICATION_SETTING"

    LastEvent_A.NewValue != "true"
    LastEvent_B.NewValue != "TRUSTED_DOMAINS"
}

tests contains {
    "PolicyId": "GWS.CHAT.4.1v0.1",
    "Criticality": "Should",
    "ReportDetails": utils.NoSuchEventDetails(DefaultSafe, utils.TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    NoSuchEvent4_1(utils.TopLevelOU)
}

tests contains {
    "PolicyId": "GWS.CHAT.4.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": utils.ReportDetails(NonCompliantOUs4_1, []),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs4_1},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    not NoSuchEvent4_1(utils.TopLevelOU)
    Status := count(NonCompliantOUs4_1) == 0
}
#--

##############
# GWS.CHAT.5 #
##############

#
# GWS.CHAT.5.1v0.1
#--
NonCompliantOUs5_1 contains {
    "Name": OU,
    "Value": concat(" ", [
        "Allow users to install Chat apps is set to",
        LastEvent.NewValue
    ])
}
if {
    some OU in utils.OUsWithEvents
    Events := utils.FilterEvents(LogEvents, "Chat app Settings - Chat apps enabled", OU)
    # Ignore OUs without any events. We're already asserting that the
    # top-level OU has at least one event; for all other OUs we assume
    # they inherit from a parent OU if they have no events.
    count(Events) > 0
    LastEvent := utils.GetLastEvent(Events)
    LastEvent.NewValue == "true"
}

tests contains {
    "PolicyId": "GWS.CHAT.5.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": utils.NoSuchEventDetails(DefaultSafe, utils.TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := utils.FilterEvents(LogEvents,  "Chat app Settings - Chat apps enabled", utils.TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.CHAT.5.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": utils.ReportDetails(NonCompliantOUs5_1, []),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs5_1},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := utils.FilterEvents(LogEvents,  "Chat app Settings - Chat apps enabled", utils.TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs5_1) == 0
}
#--

#
# GWS.CHAT.6.1v0.1
#--
tests contains {
    "PolicyId": "GWS.CHAT.6.1v0.1",
    "Criticality": "Should/Not-Implemented",
    "ReportDetails": "Currently not able to be tested automatically; please manually check.",
    "ActualValue": "",
    "RequirementMet": false,
    "NoSuchEvent": true
}
#--