package gmail
import future.keywords


#
# GWS.GMAIL.2.1v0.1
#--
test_DKIM_Correct_V1 if {
    # Test DKIM when there's only one domain
    PolicyId := "GWS.GMAIL.2.1v0.1"
    Output := tests with input as {
        "dkim_records": [
            {
                "domain": "test.name",
                "rdata": ["v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlaknWsKvtbTLAxtWSF5sDt+zvQhTXhT7V2QTnhPGlVXotXxL4VscG5cSnWus8rS4itN9ItxtzompUVRZ14b6hO1C+pxYAcl8Zaj6wsjE2vmEAmLHeXjj9EHMzrhfay2A02MJHReszokyLKBm+OZ7F4SNWP4SCazXkouOeATNrcIPUZxBV769ewx6ClumvOeHA\" \"qC77VxJieBg+7LaORrm23DMtWqdkMUWB/wmfCHO333/u6bY21eCMgiP/f+jSiylKDdY5kERpRU0NiIxlTGUhqROJESnxNUTqbK69CTAOYR6qhwJeT4OCsuE1zu6gxANmZMClIMiM2SuntXwNswb4QIDAQAB"]
            }
        ]
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement met."
}

test_DKIM_Correct_V2 if {
    # Test DKIM when there's multiple domains
    PolicyId := "GWS.GMAIL.2.1v0.1"
    Output := tests with input as {
        "dkim_records": [
            {
                "domain": "test1.name",
                "rdata": ["v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlaknWsKvtbTLAxtWSF5sDt+zvQhTXhT7V2QTnhPGlVXotXxL4VscG5cSnWus8rS4itN9ItxtzompUVRZ14b6hO1C+pxYAcl8Zaj6wsjE2vmEAmLHeXjj9EHMzrhfay2A02MJHReszokyLKBm+OZ7F4SNWP4SCazXkouOeATNrcIPUZxBV769ewx6ClumvOeHA\" \"qC77VxJieBg+7LaORrm23DMtWqdkMUWB/wmfCHO333/u6bY21eCMgiP/f+jSiylKDdY5kERpRU0NiIxlTGUhqROJESnxNUTqbK69CTAOYR6qhwJeT4OCsuE1zu6gxANmZMClIMiM2SuntXwNswb4QIDAQAB"]
            },
            {
                "domain": "test2.name",
                "rdata": ["v=DKIM1;"]
            }
        ]
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "Requirement met."
}

test_DKIM_Incorrect_V1 if {
    # Test DKIM when there's multiple domains and only one is correct
    PolicyId := "GWS.GMAIL.2.1v0.1"
    Output := tests with input as {
        "dkim_records": [
            {
                "domain": "test1.name",
                "rdata": ["v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlaknWsKvtbTLAxtWSF5sDt+zvQhTXhT7V2QTnhPGlVXotXxL4VscG5cSnWus8rS4itN9ItxtzompUVRZ14b6hO1C+pxYAcl8Zaj6wsjE2vmEAmLHeXjj9EHMzrhfay2A02MJHReszokyLKBm+OZ7F4SNWP4SCazXkouOeATNrcIPUZxBV769ewx6ClumvOeHA\" \"qC77VxJieBg+7LaORrm23DMtWqdkMUWB/wmfCHO333/u6bY21eCMgiP/f+jSiylKDdY5kERpRU0NiIxlTGUhqROJESnxNUTqbK69CTAOYR6qhwJeT4OCsuE1zu6gxANmZMClIMiM2SuntXwNswb4QIDAQAB"]
            },
            {
                "domain": "test2.name",
                "rdata": []
            }
        ]
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    not RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "1 of 2 agency domain(s) found in violation: test2.name."
}

test_DKIM_Incorrect_V2 if {
    # Test DKIM when there's only one domain and it's wrong
    PolicyId := "GWS.GMAIL.2.1v0.1"
    Output := tests with input as {
        "dkim_records": [
            {
                "domain": "test.name",
                "rdata": []
            }
        ]
    }

    RuleOutput := [Result | Result = Output[_]; Result.PolicyId == PolicyId]
    count(RuleOutput) == 1
    not RuleOutput[0].RequirementMet
    not RuleOutput[0].NoSuchEvent
    RuleOutput[0].ReportDetails == "1 of 1 agency domain(s) found in violation: test.name."
}
#--