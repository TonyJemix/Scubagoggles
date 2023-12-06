package gmail
import future.keywords


#
# GWS.GMAIL.20.1v0.1
#--
test_ComprehensiveMailStorage_Correct_V1 if {
    # Test Comprehensive Mail Storage when there's only one event
    PolicyId := "GWS.GMAIL.20.1v0.1"
    Output := tests with input as {
        "gmail_logs": {"items": [
        ]},
        "tenant_info": {
            "topLevelOU": ""
        }
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    not RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Currently not able to be tested automatically; please manually check."
}
#--