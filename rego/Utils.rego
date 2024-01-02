package utils
import future.keywords

NoSuchEventDetails(DefaultSafe, TopLevelOU) := Message if {
    DefaultSafe == true
    Message := concat("", [
        "No relevant event in the current logs for the top-level OU, ",
        TopLevelOU,
        ". While we are unable to determine the state from the logs, the default setting is compliant",
        "; manual check recommended."
    ])
}

NoSuchEventDetails(DefaultSafe, TopLevelOU) := Message if {
    DefaultSafe == false
    Message := concat("", [
        "No relevant event in the current logs for the top-level OU, ",
        TopLevelOU,
        ". While we are unable to determine the state from the logs, the default setting is non-compliant",
        "; manual check recommended."
    ])
}

ReportDetailsOUs(OUs) := "Requirement met in all OUs." if {
    count(OUs) == 0
}

ReportDetailsOUs(OUs) := Message if {
    count(OUs) > 0
    Message := concat("", ["Requirement failed in ", concat(", ", OUs), "."])
}

ReportDetailsBoolean(true) := "Requirement met."

ReportDetailsBoolean(false) := "Requirement not met."

OUsWithEvents contains OrgUnit if {
    some Log in input
    some Item in Log.items
    some Event in Item.events
    some Parameter in Event.parameters
    Parameter.name == "ORG_UNIT_NAME"
    OrgUnit := Parameter.value
}

TopLevelOU := Name if {
    # Simplest case: if input.tenant_info.topLevelOU is
    # non-empty, it contains the name of the top-level OU.
    input.tenant_info.topLevelOU != ""
    Name := input.tenant_info.topLevelOU
}

TopLevelOU := OU if {
    # input.tenant_info.topLevelOU will be empty when
    # no custom OUs have been created, as in this case
    # the top-level OU cannot be determined via the API.
    # Fortunately, in this case, we know there's literally
    # only one OU, so we can grab the OU listed on any of
    # the events and know that it is the top-level OU
    input.tenant_info.topLevelOU == ""
    count(OUsWithEvents) == 1
    some OU in OUsWithEvents
}

TopLevelOU := Name if {
    # Extreme edge case: input.tenant_info.topLevelOU is empty
    # because no custom OUs currently exist, but multiple OUs
    # are present in the events, likely due to an custom OU
    # that was deleted. In this case, we have no way of determining
    # which of OUs is the current OU.
    input.tenant_info.topLevelOU == ""
    count(OUsWithEvents) > 1
    Name := ""
}

TopLevelOU := Name if {
    # Extreme edge case: no custom OUs have been made
    # and the logs are empty. In this case, we really
    # have no way of determining the top-level OU name.
    input.tenant_info.topLevelOU == ""
    count(OUsWithEvents) == 0
    Name := ""
}

GetLastEvent(Events) := Event if {
    MaxTs := max({Event.Timestamp | some Event in Events})
    some Event in Events
    Event.Timestamp == MaxTs
}

# Helper function so that the regular SettingChangeEvents
# rule will work even for events that don't include the
# domain name
GetEventDomain(Event) := DomainName if {
    "DOMAIN_NAME" in {Parameter.name | some Parameter in Event.parameters}
    DomainName := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "DOMAIN_NAME"][0]
}

GetEventDomain(Event) := "None" if {
    not "DOMAIN_NAME" in {Parameter.name | some Parameter in Event.parameters}
}

# Helper function so that the regular SettingChangeEvents
# rule will work even for events that don't include the
# application name
GetEventApp(Event) := AppName if {
    "APPLICATION_NAME" in {Parameter.name | some Parameter in Event.parameters}
    AppName := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "APPLICATION_NAME"][0]
}

GetEventApp(Event) := "None" if {
    not "APPLICATION_NAME" in {Parameter.name | some Parameter in Event.parameters}
}

# Helper function so that the regular SettingChangeEvents
# rule will work even for events that don't include the
# OU name
GetEventOu(Event) := OrgUnit if {
    "ORG_UNIT_NAME" in {Parameter.name | some Parameter in Event.parameters}
    OrgUnit := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "ORG_UNIT_NAME"][0]
}

GetEventOu(Event) := "None" if {
    not "ORG_UNIT_NAME" in {Parameter.name | some Parameter in Event.parameters}
}


SettingChangeEvents contains {
    "Timestamp": time.parse_rfc3339_ns(Item.id.time),
    "TimestampStr": Item.id.time,
    "NewValue": NewValue,
    "Setting": Setting,
    "OrgUnit": OrgUnit,
    "DomainName": DomainName,
    "AppName": AppName
}
if {
    some Log in input
    some Item in Log.items
    some Event in Item.events

    # Does this event have the parameters we're looking for?
    "SETTING_NAME" in {Parameter.name | some Parameter in Event.parameters}
    "NEW_VALUE" in {Parameter.name | some Parameter in Event.parameters}

    # Extract the values that are there for every event    
    Setting := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "SETTING_NAME"][0]
    NewValue := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "NEW_VALUE"][0]
    
    # Extract the values that are there for only some of the events
    DomainName := GetEventDomain(Event)
    AppName := GetEventApp(Event)
    OrgUnit := GetEventOu(Event)
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
    "DomainName": DomainName,
    "AppName": AppName
}
if {
    some Log in input
    some Item in Log.items
    some Event in Item.events
    Event.name == "DELETE_APPLICATION_SETTING" # Only look at delete events

    # Does this event have the parameters we're looking for?
    "SETTING_NAME" in {Parameter.name | some Parameter in Event.parameters}

    NewValue := "DELETE_APPLICATION_SETTING"

    # Extract the values that are there for every event    
    Setting := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "SETTING_NAME"][0]

    # Extract the values that are there for only some of the events
    DomainName := GetEventDomain(Event)
    AppName := GetEventApp(Event)
    OrgUnit := GetEventOu(Event)
}

# Special case needed for Common Controls, Russian localization setting
SettingChangeEvents contains {
    "Timestamp": time.parse_rfc3339_ns(Item.id.time),
    "TimestampStr": Item.id.time,
    "NewValue": NewValue,
    "OrgUnit": OrgUnit,
    "Setting": "CHANGE_DATA_LOCALIZATION_FOR_RUSSIA",
    "AppName": "NA"
}
if {
    some Log in input
    some Item in Log.items # For each item...
    some Event in Item.events # For each event in the item...

    Event.name == "CHANGE_DATA_LOCALIZATION_FOR_RUSSIA"

    # Does this event have the parameters we're looking for?
    "NEW_VALUE" in {Parameter.name | some Parameter in Event.parameters}

    # Extract the values
    NewValue := [Parameter.value | some Parameter in Event.parameters; Parameter.name == "NEW_VALUE"][0]
    OrgUnit := GetEventOu(Event)
}

FilterEvents(SettingName, OrgUnit) := FilteredEvents if {
    # If there exists at least the root OU and 1 more OU
    # filter out organizational units that don't exist
    input.organizational_unit_names
    count(input.organizational_unit_names) >= 2

    # Filter the events by both SettingName and OrgUnit
    FilteredEvents := {
        Event | some Event in SettingChangeEvents;
        Event.OrgUnit == OrgUnit;
        Event.Setting == SettingName;
        Event.OrgUnit in input.organizational_unit_names
    }
}

FilterEvents(SettingName, OrgUnit) := FilteredEvents if {
    # If only the root OU exists run like normal
    input.organizational_unit_names
    count(input.organizational_unit_names) < 2

    # Filter the events by both SettingName and OrgUnit
    FilteredEvents := {
        Event | some Event in SettingChangeEvents;
        Event.OrgUnit == OrgUnit;
        Event.Setting == SettingName
    }
}

FilterEvents(SettingName, OrgUnit) := FilteredEvents if {
    # If OUs variable does not exist run like normal
    not input.organizational_unit_names

    # Filter the events by both SettingName and OrgUnit
    FilteredEvents := {
        Event | some Event in SettingChangeEvents;
        Event.OrgUnit == OrgUnit;
        Event.Setting == SettingName
    }
}

# Filter the events by just SettingName, ignoring OU
FilterEventsNoOU(SettingName) := {
    Event | some Event in SettingChangeEvents;
    Event.Setting == SettingName
}
