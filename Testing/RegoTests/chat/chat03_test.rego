package chat
import future.keywords

#
# GWS.CHAT.3.1v0.1
#--
test_Space_History_Setting_Correct_V1 if {
    # Test space history setting when there's only one event - use case #1
    PolicyId := "GWS.CHAT.3.1v0.1"
    Output := tests with input as {
        "chat_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name": "SETTING_NAME", "value": "RoomOtrSettingsProto otr_state"},
                        {"name": "NEW_VALUE", "value": "DEFAULT_ON_THE_RECORD"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": ""
        }
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement met in all OUs."
}

test_Space_History_Setting_Correct_V2 if {
    # Test space history setting when there's only one event - use case #2
    PolicyId := "GWS.CHAT.3.1v0.1"
    Output := tests with input as {
        "chat_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name": "SETTING_NAME", "value": "RoomOtrSettingsProto otr_state"},
                        {"name": "NEW_VALUE", "value": "ALWAYS_ON_THE_RECORD"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": ""
        }
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement met in all OUs."
}

test_Space_History_Setting_Correct_V3 if {
    # Test space history setting when there's multiple events and the most most recent is correct - use case #1
    PolicyId := "GWS.CHAT.3.1v0.1"
    Output := tests with input as {
        "chat_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name": "SETTING_NAME", "value": "RoomOtrSettingsProto otr_state"},
                        {"name": "NEW_VALUE", "value": "DEFAULT_ON_THE_RECORD"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            },
            {
                "id": {"time": "2021-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name": "SETTING_NAME", "value": "RoomOtrSettingsProto otr_state"},
                        {"name": "NEW_VALUE", "value": "DEFAULT_OFF_THE_RECORD"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": ""
        }
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement met in all OUs."
}

test_Space_History_Setting_Correct_V4 if {
    # Test space history setting when there's multiple events and the most most recent is correct - use case #2
    PolicyId := "GWS.CHAT.3.1v0.1"
    Output := tests with input as {
        "chat_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name": "SETTING_NAME", "value": "RoomOtrSettingsProto otr_state"},
                        {"name": "NEW_VALUE", "value": "ALWAYS_ON_THE_RECORD"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            },
            {
                "id": {"time": "2021-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name": "SETTING_NAME", "value": "RoomOtrSettingsProto otr_state"},
                        {"name": "NEW_VALUE", "value": "ALWAYS_OFF_THE_RECORD"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": ""
        }
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement met in all OUs."
}

test_Space_History_Setting_Incorrect_V1 if {
    # Test space history setting when there are no relevant events
    PolicyId := "GWS.CHAT.3.1v0.1"
    Output := tests with input as {
        "chat_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name": "SETTING_NAME", "value": "Something else"},
                        {"name": "NEW_VALUE", "value": "ALWAYS_ON_THE_RECORD"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": ""
        }
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    not RuleOutput[0].RequirementMet
    RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "No relevant event in the current logs for the top-level OU, Test Top-Level OU. While we are unable to determine the state from the logs, the default setting is non-compliant; manual check recommended."
}

test_Space_History_Setting_Incorrect_V2 if {
    # Test space history setting when there's only one event and it's wrong - use case #1
    PolicyId := "GWS.CHAT.3.1v0.1"
    Output := tests with input as {
        "chat_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name": "SETTING_NAME", "value": "RoomOtrSettingsProto otr_state"},
                        {"name": "NEW_VALUE", "value": "ALWAYS_OFF_THE_RECORD"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": ""
        }
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    not RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement failed in Test Top-Level OU."
}

test_Space_History_Setting_Incorrect_V3 if {
    # Test space history setting when there's only one event and it's wrong - use case #2
    PolicyId := "GWS.CHAT.3.1v0.1"
    Output := tests with input as {
        "chat_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name": "SETTING_NAME", "value": "RoomOtrSettingsProto otr_state"},
                        {"name": "NEW_VALUE", "value": "DEFAULT_OFF_THE_RECORD"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": ""
        }
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    not RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement failed in Test Top-Level OU."
}

test_Space_History_Setting_Incorrect_V4 if {
    # Test space history setting when there are multiple events and the most recent is wrong - use case #1
    PolicyId := "GWS.CHAT.3.1v0.1"
    Output := tests with input as {
        "chat_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name": "SETTING_NAME", "value": "RoomOtrSettingsProto otr_state"},
                        {"name": "NEW_VALUE", "value": "DEFAULT_OFF_THE_RECORD"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            },
            {
                "id": {"time": "2021-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name": "SETTING_NAME", "value": "RoomOtrSettingsProto otr_state"},
                        {"name": "NEW_VALUE", "value": "DEFAULT_ON_THE_RECORD"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": ""
        },
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    not RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement failed in Test Top-Level OU."
}

test_Space_History_Setting_Incorrect_V5 if {
    # Test space history setting when there are multiple events and the most recent is wrong - use case #2
    PolicyId := "GWS.CHAT.3.1v0.1"
    Output := tests with input as {
        "chat_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name": "SETTING_NAME", "value": "RoomOtrSettingsProto otr_state"},
                        {"name": "NEW_VALUE", "value": "ALWAYS_OFF_THE_RECORD"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            },
            {
                "id": {"time": "2021-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name": "SETTING_NAME", "value": "RoomOtrSettingsProto otr_state"},
                        {"name": "NEW_VALUE", "value": "ALWAYS_ON_THE_RECORD"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": ""
        },
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    not RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement failed in Test Top-Level OU."
}

test_Space_History_Setting_Incorrect_V6 if {
    # Test there's an event for a secondary OU but not the top-level OU
    PolicyId := "GWS.CHAT.3.1v0.1"
    Output := tests with input as {
        "chat_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name": "SETTING_NAME", "value": "RoomOtrSettingsProto otr_state"},
                        {"name": "NEW_VALUE", "value": "ALWAYS_OFF_THE_RECORD"},
                        {"name": "ORG_UNIT_NAME", "value": "Some other OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": "Test Top-Level OU"
        },
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    not RuleOutput[0].RequirementMet
    RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "No relevant event in the current logs for the top-level OU, Test Top-Level OU. While we are unable to determine the state from the logs, the default setting is non-compliant; manual check recommended."
}

test_Space_History_Setting_Incorrect_V7 if {
    # Test multiple OUs
    PolicyId := "GWS.CHAT.3.1v0.1"
    Output := tests with input as {
        "chat_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name": "SETTING_NAME", "value": "RoomOtrSettingsProto otr_state"},
                        {"name": "NEW_VALUE", "value": "ALWAYS_OFF_THE_RECORD"},
                        {"name": "ORG_UNIT_NAME", "value": "Some other OU"},
                    ]
                }]
            },
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name": "SETTING_NAME", "value": "RoomOtrSettingsProto otr_state"},
                        {"name": "NEW_VALUE", "value": "ALWAYS_OFF_THE_RECORD"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": "Test Top-Level OU"
        },
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    not RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement failed in Some other OU, Test Top-Level OU."
}
#--