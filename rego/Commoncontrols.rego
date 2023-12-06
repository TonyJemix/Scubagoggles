package commoncontrols
import future.keywords
import data.utils.ReportDetailsOUs
import data.utils.NoSuchEventDetails

ReportDetailsBoolean(true) := "Requirement met."
ReportDetailsBoolean(false) := "Requirement not met."

FilterEvents(SettingName) := FilteredEvents if {
    Events := SettingChangeEvents
    FilteredEvents := {Event | some Event in Events; Event.Setting == SettingName}
}

FilterEventsOU(SettingName, OrgUnit) := FilteredEvents if {
    # If there exists at least the root OU and 1 more OU
    # filter out organizational units that don't exist
    input.organizational_unit_names
    count(input.organizational_unit_names) >=2

    # Filter the events by both SettingName and OrgUnit
    Events := FilterEvents(SettingName)
    FilteredEvents := {
        Event | some Event in Events;
        Event.OrgUnit == OrgUnit;
        Event.OrgUnit in input.organizational_unit_names
    }
}

FilterEventsOU(SettingName, OrgUnit) := FilteredEvents if {
    # If only the root OU exists run like normal
    input.organizational_unit_names
    count(input.organizational_unit_names) < 2

    # Filter the events by both SettingName and OrgUnit
    Events := FilterEvents(SettingName)
    FilteredEvents := {Event | some Event in Events; Event.OrgUnit == OrgUnit}
}

FilterEventsOU(SettingName, OrgUnit) := FilteredEvents if {
    # If OUs variable does not exist run like normal
    not input.organizational_unit_names

    # Filter the events by both SettingName and OrgUnit
    Events := FilterEvents(SettingName)
    FilteredEvents := {Event | some Event in Events; Event.OrgUnit == OrgUnit}
}

SettingChangeEvents contains {
    "Timestamp": time.parse_rfc3339_ns(Item.id.time),
    "TimestampStr": Item.id.time,
    "NewValue": NewValue,
    "Setting": Setting,
    "OrgUnit": OrgUnit,
    "AppName": AppName
}
if {
    some Item in input.commoncontrols_logs.items # For each item...
    some Event in Item.events # For each event in the item...

    # Does this event have the parameters we're looking for?
    "SETTING_NAME" in {Parameter.name | some Parameter in Event.parameters}
    "NEW_VALUE" in {Parameter.name | some Parameter in Event.parameters}
    "ORG_UNIT_NAME" in {Parameter.name | some Parameter in Event.parameters}
    "APPLICATION_NAME" in {Parameter.name | some Parameter in Event.parameters}

    # Extract the values
    Setting := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "SETTING_NAME"][0]
    NewValue := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "NEW_VALUE"][0]
    OrgUnit := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "ORG_UNIT_NAME"][0]
    AppName := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "APPLICATION_NAME"][0]
}

# Secondary case that looks for the DELETE_APPLICATION_SETTING events.
# These events don't have a NEW_VALUE. To make these events work with
# minimal special logic, this rule adds the DELETE_APPLICATION_SETTING
# to the SettingChangeEvents set, with "DELETE_APPLICATION_SETTING" as
# the NewValue.
SettingChangeEvents contains {
    "Timestamp": time.parse_rfc3339_ns(Item.id.time),
    "TimestampStr": Item.id.time,
    "NewValue": NewValue,
    "Setting": Setting,
    "OrgUnit": OrgUnit,
    "AppName": AppName
}
if {
    some Item in input.commoncontrols_logs.items # For each item...
    some Event in Item.events # For each event in the item...
    Event.name == "DELETE_APPLICATION_SETTING" # Only look at delete events

    # Does this event have the parameters we're looking for?
    "SETTING_NAME" in {Parameter.name | some Parameter in Event.parameters}
    "ORG_UNIT_NAME" in {Parameter.name | some Parameter in Event.parameters}
    "APPLICATION_NAME" in {Parameter.name | some Parameter in Event.parameters}

    # Extract the values
    Setting := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "SETTING_NAME"][0]
    NewValue := "DELETE_APPLICATION_SETTING"
    OrgUnit := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "ORG_UNIT_NAME"][0]
    AppName := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "APPLICATION_NAME"][0]
}

# Additional case for Russian localization setting
SettingChangeEvents contains {
    "Timestamp": time.parse_rfc3339_ns(Item.id.time),
    "TimestampStr": Item.id.time,
    "NewValue": NewValue,
    "OrgUnit": OrgUnit,
    "Setting": "CHANGE_DATA_LOCALIZATION_FOR_RUSSIA",
    "AppName": "NA"
}
if {
    some Item in input.commoncontrols_logs.items # For each item...
    some Event in Item.events # For each event in the item...

    Event.name == "CHANGE_DATA_LOCALIZATION_FOR_RUSSIA"

    # Does this event have the parameters we're looking for?
    "NEW_VALUE" in {Parameter.name | some Parameter in Event.parameters}
    "ORG_UNIT_NAME" in {Parameter.name | some Parameter in Event.parameters}

    # Extract the values
    NewValue := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "NEW_VALUE"][0]
    OrgUnit := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "ORG_UNIT_NAME"][0]
}

GetLastEvent(Events) := Event if {
    MaxTs := max({Event.Timestamp | some Event in Events})
    some Event in Events
    Event.Timestamp == MaxTs
}

FilterEventsAlt(EventName) := Events if {
    # Many of the events for common controls are structured differently.
    # Instead of having SETTING_NAME as one of the parameters, the event
    # name is set to what would normally be the setting name.
    Events := SettingChangeEventsAlt with data.EventName as EventName
}

FilterEventsAltOU(EventName, OrgUnit) := FilteredEvents if {
    # Filter the events by both EventName and OrgUnit
    Events := FilterEventsAlt(EventName)
    FilteredEvents := {Event | some Event in Events; Event.OrgUnit == OrgUnit}
}

GetEventOu(Event) := OrgUnit if {
    # Helper function that helps the SettingChange rules always work,
    # even if the org unit isn't actually listed with the event
    "ORG_UNIT_NAME" in {Parameter.name | some Parameter in Event.parameters}
    OrgUnit := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "ORG_UNIT_NAME"][0]
}

GetEventOu(Event) := "None" if {
    not "ORG_UNIT_NAME" in {Parameter.name | some Parameter in Event.parameters}
}

SettingChangeEventsAlt contains {
    "Timestamp": time.parse_rfc3339_ns(Item.id.time),
    "TimestampStr": Item.id.time,
    "NewValue": NewValue,
    "OrgUnit": OrgUnit
}
if {
    some Item in input.commoncontrols_logs.items # For each item...
    some Event in Item.events
    Event.name == data.EventName # Note the data.EventName. This means this
    # rule will only work if called like this:
    # SettingChangeEventsAlt with data.EventName as ExampleEventName

    "NEW_VALUE" in {Parameter.name | some Parameter in Event.parameters}
    NewValue := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "NEW_VALUE"][0]
    OrgUnit := GetEventOu(Event)
}

SettingChangeEventsAlt contains {
    "Timestamp": time.parse_rfc3339_ns(Item.id.time),
    "TimestampStr": Item.id.time,
    "NewValue": NewValue,
    "OrgUnit": OrgUnit
}
if {
    some Item in input.commoncontrols_logs.items # For each item...
    some Event in Item.events
    Event.name == data.EventName

    not "NEW_VALUE" in {Parameter.name | some Parameter in Event.parameters}
    # If NEW_VALUE isn't a parameter, then the parameter name will be
    # data.EventName minus the leading CHANGE_ and the trailing S, e.g.,
    # CHANGE_ALLOWED_TWO_STEP_VERIFICATION_METHODS -> ALLOWED_TWO_STEP_VERIFICATION_METHOD
    EventName := trim_suffix(trim_prefix(data.EventName, "CHANGE_"), "S")
    NewValue := [Parameter.value | some Parameter in Event.parameters; Parameter.name == EventName][0]
    OrgUnit := GetEventOu(Event)
}

TopLevelOU := Name if {
    # Simplest case: if input.tenant_info.topLevelOU is
    # non-empty, it contains the name of the top-level OU.
    input.tenant_info.topLevelOU != ""
    Name := input.tenant_info.topLevelOU
}

TopLevelOU := Name if {
    # input.tenant_info.topLevelOU will be empty when
    # no custom OUs have been created, as in this case
    # the top-level OU cannot be determined via the API.
    # Fortunately, in this case, we know there's literally
    # only one OU, so we can grab the OU listed on any of
    # the events and know that it is the top-level OU
    input.tenant_info.topLevelOU == ""
    count(SettingChangeEvents) > 0
    Name := GetLastEvent(SettingChangeEvents).OrgUnit
}

TopLevelOU := Name if {
    # Extreme edge case: no custom OUs have been made
    # and the logs are empty. In this case, we really
    # have no way of determining the top-level OU name.
    input.tenant_info.topLevelOU == ""
    count(SettingChangeEvents) == 0
    Name := ""
}

# The simpler version of OUsWithEvents won't work
# here because common controls has the two alt SettingChangeEvents
# rules, which means the simpler version might not find all OUs that
# have an event.
#
OUsWithEvents contains OrgUnit if {
    some Item in input.commoncontrols_logs.items
    some Event in Item.events
    "ORG_UNIT_NAME" in {Parameter.name | some Parameter in Event.parameters}
    OrgUnit := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "ORG_UNIT_NAME"][0]
}

########################
# GWS.COMMONCONTROLS.1 #
########################

#
# Baseline GWS.COMMONCONTROLS.1.1v0.1
#--

# For 1.1, we need to assert two different things:
# - MFA is enforced
# - Allowed methods is set to only security key

# Custom NoSuchEvent function needed as we're checking
# two different settings simultaneously.
NoSuchEvent1_1 := true if {
    # No such event...
    Events := FilterEventsAltOU("ENFORCE_STRONG_AUTHENTICATION", TopLevelOU)
    count(Events) == 0
}

NoSuchEvent1_1 := true if {
    # No such event...
    Events := FilterEventsAltOU("CHANGE_ALLOWED_TWO_STEP_VERIFICATION_METHODS", TopLevelOU)
    count(Events) == 0
}

default NoSuchEvent1_1 := false

NonCompliantOUs1_1 contains OU if {
    some OU in OUsWithEvents
    Events := FilterEventsAltOU("ENFORCE_STRONG_AUTHENTICATION", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.NewValue == "false"
}

NonCompliantOUs1_1 contains OU if {
    some OU in OUsWithEvents
    Events := FilterEventsAltOU("CHANGE_ALLOWED_TWO_STEP_VERIFICATION_METHODS", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.NewValue != "ONLY_SECURITY_KEY"
    LastEvent.NewValue != "INHERIT_FROM_PARENT"
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.1.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": NoSuchEventDetails(DefaultSafe, TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    NoSuchEvent1_1 == true
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.1.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": ReportDetailsOUs(NonCompliantOUs1_1),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs1_1},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    NoSuchEvent1_1 == false
    Status := count(NonCompliantOUs1_1) == 0
}
#--

#
# Baseline GWS.COMMONCONTROLS.1.2v0.1
#--

NonCompliantOUs1_2 contains OU if {
    some OU in OUsWithEvents
    Events := FilterEventsAltOU("CHANGE_TWO_STEP_VERIFICATION_ENROLLMENT_PERIOD_DURATION", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.NewValue != "1 week"
    LastEvent.NewValue != "INHERIT_FROM_PARENT"
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.1.2v0.1",
    "Criticality": "Shall",
    "ReportDetails": NoSuchEventDetails(DefaultSafe, TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := FilterEventsAltOU("CHANGE_TWO_STEP_VERIFICATION_ENROLLMENT_PERIOD_DURATION", TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.1.2v0.1",
    "Criticality": "Shall",
    "ReportDetails": ReportDetailsOUs(NonCompliantOUs1_2),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs1_2},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := FilterEventsAltOU("CHANGE_TWO_STEP_VERIFICATION_ENROLLMENT_PERIOD_DURATION", TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs1_2) == 0
}
#--

#
# Baseline GWS.COMMONCONTROLS.1.3v0.1
#--

NonCompliantOUs1_3 contains OU if {
    some OU in OUsWithEvents
    Events := FilterEventsAltOU("CHANGE_TWO_STEP_VERIFICATION_FREQUENCY", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.NewValue != "DISABLE_USERS_TO_TRUST_DEVICE"
    LastEvent.NewValue != "INHERIT_FROM_PARENT"
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.1.3v0.1",
    "Criticality": "Shall",
    "ReportDetails": NoSuchEventDetails(DefaultSafe, TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := FilterEventsAltOU("CHANGE_TWO_STEP_VERIFICATION_FREQUENCY", TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.1.3v0.1",
    "Criticality": "Shall",
    "ReportDetails": ReportDetailsOUs(NonCompliantOUs1_3),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs1_3},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := FilterEventsAltOU("CHANGE_TWO_STEP_VERIFICATION_FREQUENCY", TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs1_3) == 0
}
#--

#
# Baseline GWS.COMMONCONTROLS.1.4v0.1
#--

NonCompliantOUs1_4 contains OU if {
    some OU in OUsWithEvents
    Events := FilterEventsAltOU("CHANGE_ALLOWED_TWO_STEP_VERIFICATION_METHODS", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.NewValue == "ANY"
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.1.4v0.1",
    "Criticality": "Shall",
    "ReportDetails": NoSuchEventDetails(DefaultSafe, TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := FilterEventsAltOU("CHANGE_ALLOWED_TWO_STEP_VERIFICATION_METHODS", TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.1.4v0.1",
    "Criticality": "Shall",
    "ReportDetails": ReportDetailsOUs(NonCompliantOUs1_4),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs1_4},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := FilterEventsAltOU("CHANGE_ALLOWED_TWO_STEP_VERIFICATION_METHODS", TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs1_4) == 0
}

########################
# GWS.COMMONCONTROLS.2 #
########################

#
# Baseline GWS.COMMONCONTROLS.2.1v0.1
#--

# This setting isn't controlled at the OU level, and in this case,
# the logs don't even list an OU for the events. So in this case,
# we just need to ensure the last event is compliant, we don't need
# to check each OU.
tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.2.1v0.1",
    "Criticality": "Should",
    "ReportDetails": concat("", [
        "No relevant event in the current logs. While we are unable ",
        "to determine the state from the logs, the default setting ",
        "is non-compliant; manual check recommended."
    ]), # Custom message instead of NoSuchEventDetails function,
    # as this setting isn't controlled at the OU level
    "ActualValue": "No relevant event in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := FilterEventsAlt("TOGGLE_CAA_ENABLEMENT")
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.2.1v0.1",
    "Criticality": "Should",
    "ReportDetails": ReportDetailsBoolean(Status),
    "ActualValue": {"TOGGLE_CAA_ENABLEMENT": LastEvent.NewValue},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := FilterEventsAlt("TOGGLE_CAA_ENABLEMENT")
    count(Events) > 0
    LastEvent := GetLastEvent(Events)
    Status := LastEvent.NewValue == "ENABLED"
}
#--

#
# Baseline GWS.COMMONCONTROLS.2.2v0.1
#--

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.2.2v0.1",
    "Criticality": "May/Not-Implemented",
    "ReportDetails": "Currently not able to be tested automatically; please manually check.",
    "ActualValue": "",
    "RequirementMet": false,
    "NoSuchEvent": true
}

########################
# GWS.COMMONCONTROLS.3 #
########################

#
# Baseline GWS.COMMONCONTROLS.3.1v0.1
#--

NonCompliantOUs3_1 contains OU if {
    some OU in OUsWithEvents
    Events := FilterEventsOU("SsoPolicyProto challenge_selection_behavior", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.NewValue != "PERFORM_CHALLENGE_SELECTION"
    LastEvent.NewValue != "DELETE_APPLICATION_SETTING"
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.3.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": NoSuchEventDetails(DefaultSafe, TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := FilterEventsOU("SsoPolicyProto challenge_selection_behavior", TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.3.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": ReportDetailsOUs(NonCompliantOUs3_1),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs3_1},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := FilterEventsOU("SsoPolicyProto challenge_selection_behavior", TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs3_1) == 0
}
#--

########################
# GWS.COMMONCONTROLS.4 #
########################

#
# Baseline GWS.COMMONCONTROLS.4.1v0.1
#--

GoodLimits := {"3600", "14400", "28800", "43200"}

IsGoodLimit(ActualLim) := true if {
    count({GoodLim | some GoodLim in GoodLimits; GoodLim == ActualLim}) > 0
}

IsGoodLimit(ActualLim) := false if {
    count({GoodLim | some GoodLim in GoodLimits; GoodLim == ActualLim}) == 0
}

NonCompliantOUs4_1 contains OU if {
    some OU in OUsWithEvents
    Events := FilterEventsOU("Session management settings - Session length in seconds", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.NewValue != "DELETE_APPLICATION_SETTING"
    not IsGoodLimit(LastEvent.NewValue)
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.4.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": NoSuchEventDetails(DefaultSafe, TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := FilterEventsOU("Session management settings - Session length in seconds", TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.4.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": ReportDetailsOUs(NonCompliantOUs4_1),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs4_1},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := FilterEventsOU("Session management settings - Session length in seconds", TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs4_1) == 0
}
#--

########################
# GWS.COMMONCONTROLS.5 #
########################

#
# Baseline GWS.COMMONCONTROLS.5.1v0.1
#--

NonCompliantOUs5_1 contains OU if {
    some OU in OUsWithEvents
    Events := FilterEventsOU("Password Management - Enforce strong password", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.NewValue != "on"
    LastEvent.NewValue != "DELETE_APPLICATION_SETTING"
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.5.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": NoSuchEventDetails(DefaultSafe, TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := FilterEventsOU("Password Management - Enforce strong password", TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.5.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": ReportDetailsOUs(NonCompliantOUs5_1),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs5_1},
    "RequirementMet": Status,
    "NoSuchEvent": false
} if {
    Events := FilterEventsOU("Password Management - Enforce strong password", TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs5_1) == 0
}
#--

#
# Baseline GWS.COMMONCONTROLS.5.2v0.1
#--

NonCompliantOUs5_2 contains OU if {
    some OU in OUsWithEvents
    Events := FilterEventsOU("Password Management - Minimum password length", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.NewValue != "DELETE_APPLICATION_SETTING"
    Minimum := to_number(LastEvent.NewValue)
    Minimum < 12
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.5.2v0.1",
    "Criticality": "Shall",
    "ReportDetails": NoSuchEventDetails(DefaultSafe, TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := FilterEventsOU("Password Management - Minimum password length", TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.5.2v0.1",
    "Criticality": "Shall",
    "ReportDetails": ReportDetailsOUs(NonCompliantOUs5_2),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs5_2},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := FilterEventsOU("Password Management - Minimum password length", TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs5_2) == 0
}
#--

#
# Baseline GWS.COMMONCONTROLS.5.3v0.1
#--

NonCompliantOUs5_3 contains OU if {
    some OU in OUsWithEvents
    Events := FilterEventsOU("Password Management - Enforce password policy at next login", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.NewValue != "true"
    LastEvent.NewValue != "DELETE_APPLICATION_SETTING"
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.5.3v0.1",
    "Criticality": "Shall",
    "ReportDetails": NoSuchEventDetails(DefaultSafe, TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := FilterEventsOU("Password Management - Enforce password policy at next login", TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.5.3v0.1",
    "Criticality": "Shall",
    "ReportDetails": ReportDetailsOUs(NonCompliantOUs5_3),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs5_3},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := FilterEventsOU("Password Management - Enforce password policy at next login", TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs5_3) == 0
}
#--

#
# Baseline GWS.COMMONCONTROLS.5.4v0.1
#--

NonCompliantOUs5_4 contains OU if {
    some OU in OUsWithEvents
    Events := FilterEventsOU("Password Management - Enable password reuse", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.NewValue != "false"
    LastEvent.NewValue != "DELETE_APPLICATION_SETTING"
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.5.4v0.1",
    "Criticality": "Shall",
    "ReportDetails": NoSuchEventDetails(DefaultSafe, TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := FilterEventsOU("Password Management - Enable password reuse", TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.5.4v0.1",
    "Criticality": "Shall",
    "ReportDetails": ReportDetailsOUs(NonCompliantOUs5_4),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs5_4},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := FilterEventsOU("Password Management - Enable password reuse", TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs5_4) == 0
}
#--

#
# Baseline GWS.COMMONCONTROLS.5.5v0.1
#--

NonCompliantOUs5_5 contains OU if {
    some OU in OUsWithEvents
    Events := FilterEventsOU("Password Management - Password reset frequency", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.NewValue != "0"
    LastEvent.NewValue != "DELETE_APPLICATION_SETTING"
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.5.5v0.1",
    "Criticality": "Shall",
    "ReportDetails": NoSuchEventDetails(DefaultSafe, TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := FilterEventsOU("Password Management - Password reset frequency", TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.5.5v0.1",
    "Criticality": "Shall",
    "ReportDetails": ReportDetailsOUs(NonCompliantOUs5_5),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs5_5},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := FilterEventsOU("Password Management - Password reset frequency", TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs5_5) == 0
}
#--

########################
# GWS.COMMONCONTROLS.6 #
########################

#
# Baseline GWS.COMMONCONTROLS.6.1v0.1
#--

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.6.1v0.1",
    "Criticality": "Shall/Not-Implemented",
    "ReportDetails": "Currently not able to be tested automatically; please manually check.",
    "ActualValue": "",
    "RequirementMet": false,
    "NoSuchEvent": true
}
#--

#
# Baseline GWS.COMMONCONTROLS.6.2v0.1
#--

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.6.2v0.1",
    "Criticality": "Shall/Not-Implemented",
    "ReportDetails": "Currently not able to be tested automatically; please manually check.",
    "ActualValue": "",
    "RequirementMet": false,
    "NoSuchEvent": true
}
#--

########################
# GWS.COMMONCONTROLS.7 #
########################

#
# Baseline GWS.COMMONCONTROLS.7.1v0.1
#--

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.7.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": concat("", [
        concat("", ["The following super admins are configured: ", concat(", ", SuperAdmins)]),
        ". <i>Note: Exceptions are allowed for \"break glass\" super admin accounts, ",
        "though we are not able to account for this automatically.</i>"
    ]),
    "ActualValue": SuperAdmins,
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    SuperAdmins := {Admin.primaryEmail | some Admin in input.super_admins}
    Conditions := {count(SuperAdmins) >= 2, count(SuperAdmins) <= 4}
    Status := (false in Conditions) == false
}
#--

########################
# GWS.COMMONCONTROLS.8 #
########################

#
# Baseline GWS.COMMONCONTROLS.8.1v0.1
#--
tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.8.1v0.1",
    "Criticality": "Shall/Not-Implemented",
    "ReportDetails": "Currently not able to be tested automatically; please manually check.",
    "ActualValue": "",
    "RequirementMet": false,
    "NoSuchEvent": true
}
#--

########################
# GWS.COMMONCONTROLS.9 #
########################

#
# Baseline GWS.COMMONCONTROLS.9.1v0.1
#--
tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.9.1v0.1",
    "Criticality": "Shall/Not-Implemented",
    "ReportDetails": "Currently not able to be tested automatically; please manually check.",
    "ActualValue": "",
    "RequirementMet": false,
    "NoSuchEvent": true
}
#--

#
# Baseline GWS.COMMONCONTROLS.9.2v0.1
#--

NonCompliantOUs9_2 contains OU if {
    some OU in OUsWithEvents
    Events := FilterEventsOU("AdminAccountRecoverySettingsProto Enable admin account recovery", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.NewValue != "false"
    LastEvent.NewValue != "DELETE_APPLICATION_SETTING"
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.9.2v0.1",
    "Criticality": "Shall",
    "ReportDetails": NoSuchEventDetails(DefaultSafe, TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := FilterEventsOU("AdminAccountRecoverySettingsProto Enable admin account recovery", TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.9.2v0.1",
    "Criticality": "Shall",
    "ReportDetails": ReportDetailsOUs(NonCompliantOUs9_2),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs9_2},
    "RequirementMet": Status,
    "NoSuchEvent": false
} if {
    Events := FilterEventsOU("AdminAccountRecoverySettingsProto Enable admin account recovery", TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs9_2) == 0
}
#--

#
# Baseline GWS.COMMONCONTROLS.9.3v0.1
#--

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.9.3v0.1",
    "Criticality": "Shall/Not-Implemented",
    "ReportDetails": "Currently not able to be tested automatically; please manually check.",
    "ActualValue": "",
    "RequirementMet": false,
    "NoSuchEvent": true
}
#--

#
# Baseline GWS.COMMONCONTROLS.9.4v0.1
#--

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.9.4v0.1",
    "Criticality": "Should/Not-Implemented",
    "ReportDetails": "Currently not able to be tested automatically; please manually check.",
    "ActualValue": "",
    "RequirementMet": false,
    "NoSuchEvent": true
}
#--

#########################
# GWS.COMMONCONTROLS.10 #
#########################

#
# Baseline GWS.COMMONCONTROLS.10.1v0.1
#--

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.10.1v0.1",
    "Criticality": "Shall/Not-Implemented",
    "ReportDetails": "Currently not able to be tested automatically; please manually check.",
    "ActualValue": "",
    "RequirementMet": false,
    "NoSuchEvent": true
}
#--

#
# Baseline GWS.COMMONCONTROLS.10.2v0.1
#--

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.10.2v0.1",
    "Criticality": "Should/Not-Implemented",
    "ReportDetails": "Currently not able to be tested automatically; please manually check.",
    "ActualValue": "",
    "RequirementMet": false,
    "NoSuchEvent": true
}
#--


#########################
# GWS.COMMONCONTROLS.11 #
#########################

#
# Baseline GWS.COMMONCONTROLS.11.1v0.1
#--

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.11.1v0.1",
    "Criticality": "Shall/Not-Implemented",
    "ReportDetails": "Currently not able to be tested automatically; please manually check.",
    "ActualValue": "",
    "RequirementMet": false,
    "NoSuchEvent": true
}
#--

#
# Baseline GWS.COMMONCONTROLS.11.2v0.1
#--

# Step 1: Get the set of services that have either an API access allow or API access block event
APIAccessEvents contains {
    "Timestamp": time.parse_rfc3339_ns(Item.id.time),
    "TimestampStr": Item.id.time,
    "EventName": Event.name,
    "OrgUnit": OrgUnit,
    "ServiceName": ServiceName
}
if {
    some Item in input.commoncontrols_logs.items
    some Event in Item.events
    # Filter for events where event name is either ALLOW_SERVICE_FOR_OAUTH2_ACCESS or DISALLOW...
    true in {
        Event.name == "ALLOW_SERVICE_FOR_OAUTH2_ACCESS",
        Event.name == "DISALLOW_SERVICE_FOR_OAUTH2_ACCESS"
    }
    OrgUnit := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "ORG_UNIT_NAME"][0]
    ServiceName := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "OAUTH2_SERVICE_NAME"][0]
}

# Step 2: Identify services whose most recent event is an allow event
HighRiskBlocked contains Service if {
    # Iterate through all services
    some Service in {Event.ServiceName | some Event in APIAccessEvents}
    # Only look at services that end with _HIGH_RISK. It's confusing
    # how these events appear in the logs. If a user selects "Restricted"
    # and doesn't check "allow not high risk" a pair of events will appear:
    # 1 with the service name (e.g., DRIVE) with ALLOW_SERVICE_FOR_OAUTH2_ACCESS
    # and a second with the DRIVE_HIGH_RISK set to DISALLOW_SERVICE_FOR_OAUTH2_ACCESS.
    # If user user instead selects "Restricted" but doesn't check "allow not high risk",
    # again, a pair of events will appear:
    # 1 with the service name (e.g., DRIVE) with DISALLOW_SERVICE_FOR_OAUTH2_ACCESS
    # and a second with the DRIVE_HIGH_RISK set to ALLOW_SERVICE_FOR_OAUTH2_ACCESS.
    # Really confusing. But, in short, to identify services that are set to "resticted but
    # allow not high risk", we just need to look for events ending with _HIGH_RISK.
    endswith(Service, "_HIGH_RISK")
    # Filter for just that service
    FilteredEvents := {Event | some Event in APIAccessEvents; Event.ServiceName == Service}
    # Get the most recent change
    Event := GetLastEvent(FilteredEvents)
    # If the most recent change is ALLOW, this service is unrestricted
    Event.EventName == "DISALLOW_SERVICE_FOR_OAUTH2_ACCESS"
}

# Step 3: Identify services whose most recent event is an allow event and where
# the high-risk context isn't blocked
UnrestrictedServices11_2 contains Service if {
    # Iterate through all services
    some Service in {Event.ServiceName | some Event in APIAccessEvents}
    # Ignore services that end risk _HIGH_RISK. Those are handled later
    not endswith(Service, "_HIGH_RISK")
    # Filter for just that service
    FilteredEvents := {Event | some Event in APIAccessEvents; Event.ServiceName == Service}
    # Get the most recent change
    Event := GetLastEvent(FilteredEvents)
    # If the most recent change is ALLOW... and the _HIGH_RISK
    # version of the service is not blocked, then the app is unrestricted
    Event.EventName == "ALLOW_SERVICE_FOR_OAUTH2_ACCESS"
    not concat("", [Service, "_HIGH_RISK"]) in HighRiskBlocked
}

ReportDetails11_2(true) := "Requirement met."

ReportDetails11_2(false) := concat("", [
    "The following services allow access: ",
    concat(", ", UnrestrictedServices11_2), "."
])

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.11.2v0.1",
    "Criticality": "Shall",
    "ReportDetails": concat("", [
        "No API Access Allowed/Blocked events in the current logs. ",
        "While we are unable to determine the state from the logs, ",
        "the default setting is non-compliant; manual check recommended."
    ]),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := APIAccessEvents
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.11.2v0.1",
    "Criticality": "Shall",
    "ReportDetails": ReportDetails11_2(Status),
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := APIAccessEvents
    count(Events) > 0
    Status := count(UnrestrictedServices11_2) == 0
}

# Note that the above logic doesn't filter for OU. As the logic for this setting
# is already fairly complex and GWS doesn't currently allow you to modify this
# setting at the OU level, leaving that as out of scope for now.
#--

#
# Baseline GWS.COMMONCONTROLS.11.3v0.1
#--

# Identify services whose most recent event is an allow event
UnrestrictedServices11_3 contains Service if {
    # Iterate through all services
    some Service in {Event.ServiceName | some Event in APIAccessEvents}
    # Ignore services that end risk _HIGH_RISK. Those are handled later
    not endswith(Service, "_HIGH_RISK")
    # Filter for just that service
    FilteredEvents := {Event | some Event in APIAccessEvents; Event.ServiceName == Service}
    # Get the most recent change
    Event := GetLastEvent(FilteredEvents)
    # If the most recent change is ALLOW..., even if the _HIGH_RISK
    # version of the service is blocked, then the app is unrestricted
    # for the purposes of 11.3, so we don't need to check the high
    # risk part for this one.
    Event.EventName == "ALLOW_SERVICE_FOR_OAUTH2_ACCESS"
}

ReportDetails11_3(true) := "Requirement met."

ReportDetails11_3(false) := concat("", [
    "The following services allow access: ",
    concat(", ", UnrestrictedServices11_3), "."
])

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.11.3v0.1",
    "Criticality": "SHALL",
    "ReportDetails": concat("", [
        "No API Access Allowed/Blocked events in the current logs. ",
        "While we are unable to determine the state from the logs, ",
        "the default setting is non-compliant; manual check recommended."
    ]),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := APIAccessEvents
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.11.3v0.1",
    "Criticality": "Shall",
    "ReportDetails": ReportDetails11_3(Status),
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := APIAccessEvents
    count(Events) > 0
    Status := count(UnrestrictedServices11_3) == 0
}
#--

#
# Baseline GWS.COMMONCONTROLS.11.4v0.1
#--

DomainOwnedAppAccessEvents contains {
    "Timestamp": time.parse_rfc3339_ns(Item.id.time),
    "TimestampStr": Item.id.time,
    "EventName": Event.name,
    "OrgUnit": OrgUnit
}
if {
    some Item in input.commoncontrols_logs.items
    some Event in Item.events
    # Filter for events where event name is either TRUST_DOMAIN_OWNED_OAUTH2_APPS or UNTRUST...
    true in {
        Event.name == "UNTRUST_DOMAIN_OWNED_OAUTH2_APPS",
        Event.name == "TRUST_DOMAIN_OWNED_OAUTH2_APPS"
    }
    OrgUnit := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "ORG_UNIT_NAME"][0]
}

NonCompliantOUs11_4 contains OU if {
    some OU in OUsWithEvents
    Events := {Event | some Event in DomainOwnedAppAccessEvents; Event.OrgUnit == OU}
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.EventName != "UNTRUST_DOMAIN_OWNED_OAUTH2_APPS"
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.11.4v0.1",
    "Criticality": "Shall",
    "ReportDetails": NoSuchEventDetails(DefaultSafe, TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := {Event | some Event in DomainOwnedAppAccessEvents; Event.OrgUnit == TopLevelOU}
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.11.4v0.1",
        "Criticality": "Shall",
        "ReportDetails": ReportDetailsOUs(NonCompliantOUs11_4),
        "ActualValue": {"NonCompliantOUs": NonCompliantOUs11_4},
        "RequirementMet": Status,
        "NoSuchEvent": false
}
if {
    Events := {Event | some Event in DomainOwnedAppAccessEvents; Event.OrgUnit == TopLevelOU}
    count(Events) > 0
    Status := count(NonCompliantOUs11_4) == 0
}
#--

#
# Baseline GWS.COMMONCONTROLS.11.5v0.1
#--

UnconfiguredAppAccessEvents contains {
    "Timestamp": time.parse_rfc3339_ns(Item.id.time),
    "TimestampStr": Item.id.time,
    "EventName": Event.name,
    "OrgUnit": OrgUnit
}
if {
    some Item in input.commoncontrols_logs.items
    some Event in Item.events
    # Filter for events where event name is either BLOCK_ALL... or UNBLOCK... or SIGN_IN...
    true in {
        Event.name == "BLOCK_ALL_THIRD_PARTY_API_ACCESS",
        Event.name == "UNBLOCK_ALL_THIRD_PARTY_API_ACCESS",
        Event.name == "SIGN_IN_ONLY_THIRD_PARTY_API_ACCESS"
    }
    OrgUnit := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "ORG_UNIT_NAME"][0]
}

NonCompliantOUs11_5 contains OU if {
    some OU in OUsWithEvents
    Events := [Event | some Event in UnconfiguredAppAccessEvents; Event.OrgUnit == OU]
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.EventName != "BLOCK_ALL_THIRD_PARTY_API_ACCESS"
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.11.5v0.1",
    "Criticality": "Shall",
    "ReportDetails": NoSuchEventDetails(DefaultSafe, TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := {Event | some Event in UnconfiguredAppAccessEvents; Event.OrgUnit == TopLevelOU}
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.11.5v0.1",
    "Criticality": "Shall",
    "ReportDetails": ReportDetailsOUs(NonCompliantOUs11_5),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs11_5},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := {Event | some Event in UnconfiguredAppAccessEvents; Event.OrgUnit == TopLevelOU}
    count(Events) > 0
    Status := count(NonCompliantOUs11_5) == 0
}
#--

#########################
# GWS.COMMONCONTROLS.12 #
#########################

#
# Baseline GWS.COMMONCONTROLS.12.1v0.1
#--

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.12.1v0.1",
    "Criticality": "Should/Not-Implemented",
    "ReportDetails": "Currently not able to be tested automatically; please manually check.",
    "ActualValue": "",
    "RequirementMet": false,
    "NoSuchEvent": true
}
#--

#
# Baseline GWS.COMMONCONTROLS.12.2v0.1
#--

# For 12.2, we need to assert two different things:
# - Users can only allow whitelisted apps
# - Exceptions aren't allowed for internal apps

# Custom NoSuchEvent function needed as we're checking
# two different settings simultaneously.
NoSuchEvent12_2 := true if {
    Events := FilterEventsOU("Apps Access Setting Allowlist access", TopLevelOU)
    count(Events) == 0
}

NoSuchEvent12_2 := true if {
    Events := FilterEventsOU("Apps Access Setting allow_all_internal_apps", TopLevelOU)
    count(Events) == 0
}

default NoSuchEvent12_2 := false

NonCompliantOUs12_2 contains OU if {
    some OU in OUsWithEvents
    Events := FilterEventsOU("Apps Access Setting Allowlist access", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.NewValue != "ALLOW_SPECIFIED"
    LastEvent.NewValue != "DELETE_APPLICATION_SETTING"
}

NonCompliantOUs12_2 contains OU if {
    some OU in OUsWithEvents
    Events := FilterEventsOU("Apps Access Setting allow_all_internal_apps", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.NewValue != "false"
    LastEvent.NewValue != "DELETE_APPLICATION_SETTING"
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.12.2v0.1",
    "Criticality": "Should",
    "ReportDetails": NoSuchEventDetails(DefaultSafe, TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    NoSuchEvent12_2 == true
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.12.2v0.1",
    "Criticality": "Should",
    "ReportDetails": ReportDetailsOUs(NonCompliantOUs12_2),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs12_2},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    NoSuchEvent12_2 == false
    Status := count(NonCompliantOUs12_2) == 0
}
#--


#########################
# GWS.COMMONCONTROLS.13 #
#########################

#
# Baseline GWS.COMMONCONTROLS.13.1v0.1
#--

NonCompliantOUs13_1 contains OU if {
    some OU in OUsWithEvents
    Events := FilterEventsAltOU("WEAK_PROGRAMMATIC_LOGIN_SETTINGS_CHANGED", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.NewValue != "DENIED"
    LastEvent.NewValue != "INHERIT_FROM_PARENT"
}
# NOTE: When WEAK_PROGRAMMATIC_LOGIN_SETTINGS_CHANGED for a child OU
# is set to inherit from parent, apparently NO EVENT IS PRODUCED IN
# THE ADMIN LOGS. When you later override the setting, it shows
# "INHERIT_FROM_PARENT" as the "OLD_VALUE", so I'm putting that above
# for completeness, but this appears to be a case where we won't be
# able to detect setting inheritance, as least for now.

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.13.1v0.1",
    "Criticality": "Should",
    "ReportDetails": NoSuchEventDetails(DefaultSafe, TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := FilterEventsAltOU("WEAK_PROGRAMMATIC_LOGIN_SETTINGS_CHANGED", TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.13.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": ReportDetailsOUs(NonCompliantOUs13_1),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs13_1},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := FilterEventsAltOU("WEAK_PROGRAMMATIC_LOGIN_SETTINGS_CHANGED", TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs13_1) == 0
}
#--

#########################
# GWS.COMMONCONTROLS.14 #
#########################

Apps := {"Blogger", "Google Books", "Google Pay", "Google Photos", "Google Play",
    "Google Play Console", "Location History", "YouTube"}

AppsAllowingTakoutOU contains App {
    Events := FilterEvents("UserTakeoutSettingsProto User Takeout ")
    some App in Apps
    Filtered := {Event | some Event in Events; Event.AppName == App; Event.OrgUnit == data.OrgUnit}
    # Note the data.OrgUnit. This means this
    # rule will only work if called like this:
    # AppsAllowingTakoutOU with data.OrgUnit as ExampleOrgUnit
    LastEvent := GetLastEvent(Filtered)
    LastEvent.NewValue != "Disabled"
    LastEvent.NewValue != "DELETE_APPLICATION_SETTING"
}

NonCompliantOUs14_1 contains OU {
    some OU in OUsWithEvents
    Events := FilterEventsOU("UserTakeoutSettingsProto User Takeout ", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    EnabledApps := AppsAllowingTakoutOU with data.OrgUnit as OU
    count(EnabledApps) > 0
}

#
# Baseline GWS.COMMONCONTROLS.14.1v0.1
#--

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.14.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": concat("", [
        "For apps with individual admin control: ",
        NoSuchEventDetails(DefaultSafe, TopLevelOU)
    ]),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := true
    Events := FilterEventsOU("UserTakeoutSettingsProto User Takeout ", TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.14.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": concat("", [
        "For apps with individual admin control: ",
        ReportDetailsOUs(NonCompliantOUs14_1)
    ]),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs14_1},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := FilterEventsOU("UserTakeoutSettingsProto User Takeout ", TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs14_1) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.14.2v0.1",
    "Criticality": "Should/Not-Implemented",
    "ReportDetails": concat("", [
        "Currently unable to check that Google takeout is disabled for ",
        "services without an individual admin control; manual check recommended."
    ]),
    "ActualValue": [],
    "RequirementMet": false,
    "NoSuchEvent": true
}
#--

#########################
# GWS.COMMONCONTROLS.15 #
#########################

#
# Baseline GWS.COMMONCONTROLS.15.1v0.1
#--

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.15.1v0.1",
    "Criticality": "Shall/Not-Implemented",
    "ReportDetails": concat("", [
        "Results for GWS.COMMONCONTROLS.15 are listed in the ",
        "<a href='../IndividualReports/RulesReport.html'>Rules Report</a>."
    ]),
    "ActualValue": "",
    "RequirementMet": false,
    "NoSuchEvent": true
}
#--

#########################
# GWS.COMMONCONTROLS.16 #
#########################

#
# Baseline GWS.COMMONCONTROLS.16.1v0.1
#--

NonCompliantOUs16_1 contains OU if {
    some OU in OUsWithEvents
    Events := FilterEventsOU("Data Sharing Settings between GCP and Google Workspace \"Sharing Options\"", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.NewValue != "ENABLED"
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.16.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": NoSuchEventDetails(DefaultSafe, TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := FilterEventsOU("Data Sharing Settings between GCP and Google Workspace \"Sharing Options\"", TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.16.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": ReportDetailsOUs(NonCompliantOUs16_1),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs16_1},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := FilterEventsOU("Data Sharing Settings between GCP and Google Workspace \"Sharing Options\"", TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs16_1) == 0
}
#--

#
# Baseline GWS.COMMONCONTROLS.16.2v0.1
#--

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.16.2v0.1",
    "Criticality": "Shall/Not-Implemented",
    "ReportDetails": "Currently not able to be tested automatically; please manually check.",
    "ActualValue": "",
    "RequirementMet": false,
    "NoSuchEvent": true
}
#--

#########################
# GWS.COMMONCONTROLS.17 #
#########################

#
# Baseline GWS.COMMONCONTROLS.17.1v0.1
#--
tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.17.1v0.1",
    "Criticality": "Shall/Not-Implemented",
    "ReportDetails": "Currently not able to be tested automatically; please manually check.",
    "ActualValue": "",
    "RequirementMet": false,
    "NoSuchEvent": true
}
#--

#########################
# GWS.COMMONCONTROLS.18 #
#########################

#
# Baseline GWS.COMMONCONTROLS.18.1v0.1
#--

NonCompliantOUs18_1 contains OU if {
    some OU in OUsWithEvents
    Events := FilterEventsOU("CHANGE_DATA_LOCALIZATION_FOR_RUSSIA", OU)
    count(Events) > 0 # Ignore OUs without any events. We're already
    # asserting that the top-level OU has at least one event; for all
    # other OUs we assume they inherit from a parent OU if they have
    # no events.
    LastEvent := GetLastEvent(Events)
    LastEvent.NewValue == "true"
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.18.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": NoSuchEventDetails(DefaultSafe, TopLevelOU),
    "ActualValue": "No relevant event for the top-level OU in the current logs",
    "RequirementMet": DefaultSafe,
    "NoSuchEvent": true
}
if {
    DefaultSafe := false
    Events := FilterEventsOU("CHANGE_DATA_LOCALIZATION_FOR_RUSSIA", TopLevelOU)
    count(Events) == 0
}

tests contains {
    "PolicyId": "GWS.COMMONCONTROLS.18.1v0.1",
    "Criticality": "Shall",
    "ReportDetails": ReportDetailsOUs(NonCompliantOUs18_1),
    "ActualValue": {"NonCompliantOUs": NonCompliantOUs18_1},
    "RequirementMet": Status,
    "NoSuchEvent": false
}
if {
    Events := FilterEventsOU("CHANGE_DATA_LOCALIZATION_FOR_RUSSIA", TopLevelOU)
    count(Events) > 0
    Status := count(NonCompliantOUs18_1) == 0
}
#--
