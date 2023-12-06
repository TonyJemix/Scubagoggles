package classroom
import future.keywords

#
# GWS.CLASSROOM.1.1v0.1
#--

test_JoinClassroom_Correct_V1 if {
    # Test enforcing who can join classroom when there's only one event
    PolicyId := "GWS.CLASSROOM.1.1v0.1"
    Output := tests with input as {
        "classroom_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name":"SETTING_NAME",
                        "value": "ClassMembershipSettingsGroup who_can_join_classes"},
                        {"name": "NEW_VALUE", "value": "1"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": "Test Top-Level OU"
        }
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement met in all OUs."
}

test_JoinClassroom_Correct_V2 if {
    # Test enforcing MFA when there's multiple events, with the chronological latest
    # correct but not last in json list
    PolicyId := "GWS.CLASSROOM.1.1v0.1"
    Output := tests with input as {
        "classroom_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name":"SETTING_NAME",
                        "value": "ClassMembershipSettingsGroup who_can_join_classes"},
                        {"name": "NEW_VALUE", "value": "1"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            },
            {
                "id": {"time": "2021-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name":"SETTING_NAME",
                        "value": "ClassMembershipSettingsGroup who_can_join_classes"},
                        {"name": "NEW_VALUE", "value": "2"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": "Test Top-Level OU"
        }
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement met in all OUs."
}

test_JoinClassroom_Incorrect_V1 if {
    # Test enforcing who can join classroom when there's only one event and it's wrong
    PolicyId := "GWS.CLASSROOM.1.1v0.1"
    Output := tests with input as {
        "classroom_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name":"SETTING_NAME",
                        "value": "ClassMembershipSettingsGroup who_can_join_classes"},
                        {"name": "NEW_VALUE", "value": "2"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": "Test Top-Level OU"
        }
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    not RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement failed in Test Top-Level OU."
}

test_JoinClassroom_Incorrect_V2 if {
    # Test who can join classroom when there's multiple events, with the chronological latest
    # incorrect but not last in json list
    PolicyId := "GWS.CLASSROOM.1.1v0.1"
    Output := tests with input as {
        "classroom_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name":"SETTING_NAME",
                        "value": "ClassMembershipSettingsGroup who_can_join_classes"},
                        {"name": "NEW_VALUE", "value": "2"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            },
            {
                "id": {"time": "2021-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name":"SETTING_NAME",
                        "value": "ClassMembershipSettingsGroup who_can_join_classes"},
                        {"name": "NEW_VALUE", "value": "1"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": "Test Top-Level OU"
        }
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    not RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement failed in Test Top-Level OU."
}


test_JoinClassroom_Incorrect_V3 if {
    # Test enforcing who can join classroom when there no applicable event
    PolicyId := "GWS.CLASSROOM.1.1v0.1"
    Output := tests with input as {
        "classroom_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "name": "SOMETHING_ELSE",
                    "parameters": [
                        {"name": "NEW_VALUE", "value": "2"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": "Test Top-Level OU"
        }
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    not RuleOutput[0].RequirementMet
    RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "No relevant event in the current logs for the top-level OU, Test Top-Level OU. While we are unable to determine the state from the logs, the default setting is non-compliant; manual check recommended."
}
#--


#
# GWS.CLASSROOM.1.2v0.1
#--

test_WhichClasses_Correct_V1 if {
    # Test enforcing which classes users can join when there's only one event
    PolicyId := "GWS.CLASSROOM.1.2v0.1"
    Output := tests with input as {
        "classroom_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name":"SETTING_NAME",
                        "value": "ClassMembershipSettingsGroup which_classes_can_users_join"},
                        {"name": "NEW_VALUE", "value": "1"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": "Test Top-Level OU"
        }
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement met in all OUs."
}

test_WhichClasses_Correct_V2 if {
    # Test enforcing which classes users can join when there's multiple events, with the chronological latest
    # correct but not last in json list
    PolicyId := "GWS.CLASSROOM.1.2v0.1"
    Output := tests with input as {
        "classroom_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name":"SETTING_NAME",
                        "value": "ClassMembershipSettingsGroup which_classes_can_users_join"},
                        {"name": "NEW_VALUE", "value": "1"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            },
            {
                "id": {"time": "2021-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name":"SETTING_NAME",
                        "value": "ClassMembershipSettingsGroup which_classes_can_users_join"},
                        {"name": "NEW_VALUE", "value": "2"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": "Test Top-Level OU"
        }
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement met in all OUs."
}

test_WhichClasses_Incorrect_V1 if {
    # Test enforcing which classes users can join when there's only one event and it's wrong
    PolicyId := "GWS.CLASSROOM.1.2v0.1"
    Output := tests with input as {
        "classroom_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name":"SETTING_NAME",
                        "value": "ClassMembershipSettingsGroup which_classes_can_users_join"},
                        {"name": "NEW_VALUE", "value": "2"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": "Test Top-Level OU"
        }
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    not RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement failed in Test Top-Level OU."
}

test_WhichClasses_Incorrect_V2 if {
    # Test enforcing which classes users can join when there's multiple events, with the chronological latest
    # incorrect but not last in json list
    PolicyId := "GWS.CLASSROOM.1.2v0.1"
    Output := tests with input as {
        "classroom_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "parameters": [
                        {"name":"SETTING_NAME",
                        "value": "ClassMembershipSettingsGroup which_classes_can_users_join"},
                        {"name": "NEW_VALUE", "value": "2"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            },
            {
                "id": {"time": "2021-12-20T00:02:28.672Z"},
                "events": [{
                    "name": "ClassMembershipSettingsGroup who_can_join_classes",
                    "parameters": [
                        {"name": "NEW_VALUE", "value": "1"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": "Test Top-Level OU"
        }
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    not RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement failed in Test Top-Level OU."
}


test_WhichClasses_Incorrect_V3 if {
    # Test enforcing which classes users can join when there no applicable event
    PolicyId := "GWS.CLASSROOM.1.2v0.1"
    Output := tests with input as {
        "classroom_logs": {"items": [
            {
                "id": {"time": "2022-12-20T00:02:28.672Z"},
                "events": [{
                    "name": "SOMETHING_ELSE",
                    "parameters": [
                        {"name": "NEW_VALUE", "value": "2"},
                        {"name": "ORG_UNIT_NAME", "value": "Test Top-Level OU"},
                    ]
                }]
            }
        ]},
        "tenant_info": {
            "topLevelOU": "Test Top-Level OU"
        }
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    not RuleOutput[0].RequirementMet
    RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "No relevant event in the current logs for the top-level OU, Test Top-Level OU. While we are unable to determine the state from the logs, the default setting is non-compliant; manual check recommended."
}