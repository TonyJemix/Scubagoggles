# CISA Google Workspace Security Configuration Baseline for Google Chat

Google Chat is a communication and collaboration tool in Google Workspace that supports direct messaging, group conversations, and content creation and sharing. Chat allows administrators to control and manage their messages and files. This Secure Configuration Baseline (SCB) provides specific policies to strengthen Chat security.

The Secure Cloud Business Applications (SCuBA) project provides guidance and capabilities to secure agencies' cloud business application environments and protect federal information that is created, accessed, shared, and stored in those environments. The SCuBA Secure Configuration Baselines (SCB) for Google Workspace (GWS) will help secure federal civilian executive branch (FCEB) information assets stored within GWS cloud environments through consistent, effective, modern, and manageable security configurations.

The CISA SCuBA SCBs for GWS help secure federal information assets stored within GWS cloud business application environments through consistent, effective, and manageable security configurations. CISA created baselines tailored to the federal government's threats and risk tolerance with the knowledge that every organization has different threat models and risk tolerance. Non-governmental organizations may also find value in applying these baselines to reduce risks.

The information in this document is being provided "as is" for INFORMATIONAL PURPOSES ONLY. CISA does not endorse any commercial product or service, including any subjects of analysis. Any reference to specific commercial entities or commercial products, processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or imply endorsement, recommendation, or favoritism by CISA.

This baseline is based on Google documentation available at [Google Workspace Admin Help: Google Chat settings](https://support.google.com/a/answer/9540647?hl=en) and addresses the following:

-   [Chat History](#1-chat-history)
-   [External File Sharing](#2-external-file-sharing)
-   [History for Spaces](#3-history-for-spaces)
-   [External Chat Messaging](#4-external-chat-messaging)
-   [Installation of Chat Apps](#5-installation-of-chat-apps)
-   [DLP Rules](#6-dlp-rules)

Settings can be assigned to certain users within Google Workspace through organizational units, configuration groups, or individually. Before changing a setting, the user can select the organizational unit, configuration group, or individual users to which they want to apply changes.

## Assumptions

This document assumes the organization is using GWS Enterprise Plus.

This document does not address, ensure compliance with, or supersede any law, regulation, or other authority.  Entities are responsible for complying with any recordkeeping, privacy, and other laws that may apply to the use of technology.  This document is not intended to, and does not, create any right or benefit for anyone against the United States, its departments, agencies, or entities, its officers, employees, or agents, or any other person.

## Key Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119.

# Baseline Policies

## 1. Chat History

This section covers chat history retention for users within the organization and prevents users from changing their history setting. This control applies to both direct messages and group messages.

### Policies

#### GWS.CHAT.1.1v0.1
Chat history SHALL be enabled for information traceability.

- Rationale
  - Helps ensure there is a record of chats sent to receive in the case that it needs to be reviewed in the future for legal or compliance issues.
- Last Modified: July 10, 2023

- MITRE ATT&CK TTP Mapping
  - [T1562: Impair Defenses](https://attack.mitre.org/techniques/T1562/)
    - [T1562:001: Impair Defenses: Disable or Modify Tools](https://attack.mitre.org/techniques/T1562/001/)

#### GWS.CHAT.1.2v0.1
Users SHALL NOT be allowed to change their history setting.

- Rationale
  - This setting helps prevent changes by the user.
- Last Modified: July 10, 2023

- MITRE ATT&CK TTP Mapping
  - [T1562: Impair Defenses](https://attack.mitre.org/techniques/T1562/)
    - [T1562:001: Impair Defenses: Disable or Modify Tools](https://attack.mitre.org/techniques/T1562/001/)

### Resources

-   [Google Workspace Admin Help: Turn chat history on or off for users](https://support.google.com/a/answer/7664184)

### Prerequisites

-   None

### Implementation

To configure the settings for History for chats:

#### GWS.CHAT.1.1v0.1 Instructions
1.  Sign in to the [Google Admin Console](https://admin.google.com).
2.  Select **Apps** -\> **Google Workspace** -\> **Google Chat**.
3.  Select **History for chats**.
4.  Select **History is ON**.
5.  Select **Save**

#### GWS.CHAT.1.2v0.1 Instructions
1.  Sign in to the [Google Admin Console](https://admin.google.com).
2.  Select **Apps** -\> **Google Workspace** -\> **Google Chat**.
3.  Uncheck the **Allow users to change their history setting** checkbox.
4.  Select **Save**.

## 2. External File Sharing

This section covers what types of files users are allowed to share external to their organization.

### Policies

#### GWS.CHAT.2.1v0.1
External file sharing SHALL be disabled to protect sensitive information from unauthorized or accidental sharing.

- Rationale
  - Protects against unintentional or intentional data leakage from the agency or organization.
- Last Modified: July 10, 2023

- MITRE ATT&CK TTP Mapping
  - [T1048: Exfilitration Over Alternative Protocol](https://attack.mitre.org/techniques/T1048/)
    - [T1048:002: Exfilitration Over Alternative Protocol: Exfilitration Over Asymmetric Encrypted Non-C2 Protocol](https://attack.mitre.org/techniques/T1048/002/)

### Resources

-   [Google Workspace Admin Help: Control file sharing in Chat](https://support.google.com/a/answer/10277783?hl=en)

### Prerequisites

-   None

### Implementation

To configure the settings for External filesharing:

#### GWS.CHAT.2.1v0.1 Instructions
1.  Sign in to the [Google Admin Console](https://admin.google.com).
2.  Select **Apps** -\> **Google Workspace** -\> **Google Chat**.
3.  Select **Chat File Sharing**.
4.  In the **External filesharing** dropdown menu, select **No files.**
5.  Select **Save**.

## 3. History for Spaces

This section covers whether chat history is retained by default for users within the organization. This control does not apply for threaded chat spaces because those require that history be on, which cannot be changed. Chat spaces allow for multiple users to share files, assign tasks, and stay connected.

### Policies

#### GWS.CHAT.3.1v0.1
Space history SHOULD be enabled for traceability of information.

- Rationale
  - This provides the ability to trace history when needed from an organizational level.
- Last Modified: July 10, 2023

- MITRE ATT&CK TTP Mapping
  - [T1562: Impair Defenses](https://attack.mitre.org/techniques/T1562/)
    - [T1562:001: Impair Defenses: Disable or Modify Tools](https://attack.mitre.org/techniques/T1562/001/)

### Resources

-   [Google Workspace Admin Help: Set a space history option for users](https://support.google.com/a/answer/9948515?hl=en)

### Prerequisites

-   None

### Implementation

To configure the settings for History for spaces:

#### GWS.CHAT.3.1v0.1 Instructions
1.  Sign in to the [Google Admin Console](https://admin.google.com).
2.  Select **Apps** -\> **Google Workspace** -\> **Google Chat**.
3.  Select **History for spaces**.
4.  Select **History is ON by default** or **History is ALWAYS ON**.
5.  Select **Save**.

## 4. External Chat Messaging

This section permits users to send Chat messages outside of their organization, but such Chat messages must be restricted to allowlisted domains only.

### Policies

#### GWS.CHAT.4.1v0.1
External Chat messaging SHALL be restricted to allowlisted domains only.

- Rationale
  - Protects the organization from external risks and helps prevent data leakage outside the organization.
- Last Modified: November 14, 2023

- MITRE ATT&CK TTP Mapping
  - [T1530: Data from Cloud Storage](https://attack.mitre.org/techniques/T1530/)

#### GWS.CHAT.4.2v0.1
Only allow this for allowlisted domains SHALL be enabled.

- Rationale
  - This limits the security vulnerabilities present with allowing chatting outside of organization.
- Last Modified: August 1, 2023

- MITRE ATT&CK TTP Mapping
  - [T1530: Data from Cloud Storage](https://attack.mitre.org/techniques/T1530/)

### Resources

-   [Google Workspace Admin Help: Set external chat options](https://support.google.com/a/answer/9269229?product_name=UnuFlow&visit_id=637841711304802210-4105703050&rd=1&src=supportwidget0)
-   [Google Workspace Admin Help: Allow external sharing with only trusted domains](https://support.google.com/a/answer/6160020)
-   [CIS Google Workspace Benchmark v1.1.0 - 3.1.4.2.2 Ensure Google Chat Externally is Restricted to Allowlisted Domains](https://www.cisecurity.org/benchmark/google_workspace)

### Prerequisites

-   None

### Implementation

To configure the settings for External Chat:

#### Policy Group 4 Common Instructions
1.  Sign in to the [Google Admin Console](https://admin.google.com).
2.  Select **Apps** -\> **Google Workspace** -\> **Google Chat**.
3.  Select **External Chat Settings** -\> **Chat externally**.

#### GWS.CHAT.4.1v0.1 Instructions
1.  Select **ON**.
2.  Select **Save**.

#### GWS.CHAT.4.2v0.1 Instructions
1.  Select **Only allow this for allowlisted domains**
2.  To add allowlisted domains select **Manage allowlisted domains**
3.  Select **Save**.

## 5. Installation of Chat Apps

This section covers preventing ordinary users from being able to install Chat apps.

### Policies

#### GWS.CHAT.5.1v0.1
User-level ability to install Chat apps SHALL be disabled.

- Rationale
  - Protects against security risks associated with installing chat apps such as phishing, spyware, etc.
- Last Modified: July 10, 2023

- MITRE ATT&CK TTP Mapping
  - [T1195:002: Supply Chain Compromise](https://attack.mitre.org/techniques/T1195/)
    - [T1195:002: Supply Chain Compromise: Software Supply Chain](https://attack.mitre.org/techniques/T1195/002/)
  - [T1566: Phishing](https://attack.mitre.org/techniques/T1566/)
    - [T1566:001: Phishing: Spearphishing Attachment](https://attack.mitre.org/techniques/T1566/001/)
    - [T1566:002: Phishing: Spearphishing Link](https://attack.mitre.org/techniques/T1566/002/)
    - [T1566:003: Phishing: Spearphishing via Service](https://attack.mitre.org/techniques/T1566/003/)

### Resources

-   [Google Workspace Admin Help: Allow users to install Chat apps](https://support.google.com/a/answer/7651360?product_name=UnuFlow&hl=en&visit_id=637916846359382524-3147840186&rd=1&src=supportwidget0&hl=en#zippy=%2Cstep-add-marketplace-apps-to-your-allowlist-optional%2Cstep-decide-what-apps-users-can-install%2Cstep-let-users-install-apps-in-chat)
-   GWS Common Controls Minimum Viable Secure Configuration Baseline

### Prerequisites

-   None

### Implementation

To configure the settings for Chat apps:

#### GWS.CHAT.5.1v0.1 Instructions
1.  Sign in to the [Google Admin Console](https://admin.google.com).
2.  Select **Apps** -\> **Google Workspace** -\> **Google Chat**.
3.  Select **Chat apps** -\> **Chat apps access settings**.
4.  Select **OFF** for **Allow users to install Chat apps**.
5.  Select **SAVE**.

## 6. DLP rules

This recommendation applies only to agencies that allow external sharing (see section 2.1).

Using data loss prevention (DLP), organizations can create and apply rules to control the content that users can share in files outside the organization. DLP gives you control over what users can share and prevents unintended exposure of sensitive information.

DLP rules can use predefined content detectors to match PII (e.g., SSN), credentials (e.g., API keys), or specific document types (e.g., source code). Custom rules can also be applied based upon regex match or document labels.

### Policies

#### GWS.CHAT.6.1v0.1
Agencies SHOULD configure DLP rules to block or warn on sharing files with sensitive data.

- Rationale
  - Data Loss Prevention (DLP) rules trigger scans of files to look for sensitive content and restrict sharing of documents that may contain sensitive content. Configuring DLP rules helps agencies protect their information, by determining what data and/or phrasing might be sensitive, and restricting the dissemination of the documents containing that data. Examples include PII, PHI, portion markings, etc.
- Last Modified: July 10, 2023

- MITRE ATT&CK TTP Mapping
  - [T1530: Data from Cloud Storage](https://attack.mitre.org/techniques/T1530/)
  - [T1048: Exfilitration Over Alternative Protocol](https://attack.mitre.org/techniques/T1048/)
    - [T1048:002: Exfilitration Over Alternative Protocol: Exfilitration Over Asymmetric Encrypted Non-C2 Protocol](https://attack.mitre.org/techniques/T1048/002/)
  - [T1213: Data from Information Repositories](https://attack.mitre.org/techniques/T1213/)
    - [T1213:001: Data from Information Repositories:Confluence](https://attack.mitre.org/techniques/T1213/001/)
    - [T1213:002: Data from Information Repositories:Sharepoint](https://attack.mitre.org/techniques/T1213/002/)

### Resources

-   [How to use predefined content detectors - Google Workspace Admin Help](https://support.google.com/a/answer/7047475#zippy=%2Cunited-states)
-   [Get started as a Drive labels admin - Google Workspace Admin Help](https://support.google.com/a/answer/9292382?hl=en)
-   [CIS Google Workspace Foundations Benchmark](https://www.cisecurity.org/benchmark/google_workspace)

### Prerequisites

-   None

### Implementation

#### GWS.CHAT.6.1v0.1 Instructions
1.  Sign in to the [Google Admin Console](https://admin.google.com).
2.  Select **Menu -\> Security -\> Access and data control -\> Data protection**.
3.  Click **Manage Rules**. Then click **Add rule** -\> **New rule** or click **Add rule** -\> **New rule from template**. For templates, select a template from the Templates page.
4.  In the **Name** section, add the name and description of the rule.
5.  In the **Scope** section, apply this rule only to the entire domain or to selected organizational units or groups, and click **Continue**. If there's a conflict between organizational units and groups in terms of inclusion or exclusion, the group takes precedence.
6.  In the **Apps** section, choose the trigger for **Google Chat, Message Sent or File Upload**, and click **Continue**.
7.  In the **Conditions** section, click **Add Condition**.
8.  Configure appropriate content definition(s) based upon the agency's individual requirements and click **Continue**.
9.  Select the appropriate action to warn or block sharing, based upon the agency's individual requirements.
10. In the **Alerting** section, choose a severity level, and optionally, check **Send to alert center to trigger notifications**.
11. Review the rule details, mark the rule as **Active**, and click **Create.**

## 7. Content Reporting

This section covers the content reporting functionality, a feature that allows users to report messages that violate organizational guidelines to workspace admins.

### Policies

#### GWS.CHAT.7.1v0.1
Chat content reporting SHALL be enabled.

- Rationale
  - Chat messages could potentially be used as an avenue for phishing, malware distribution, or other security risks. Enabling this feature allows users to report any suspicious messages to workspace admins, increasing threat awareness and facilitating threat mitigation.
- Last Modified: February 13, 2024

- MITRE ATT&CK TTP Mapping
  - None

#### GWS.CHAT.7.2v0.1
All conversation types SHALL be selected.

- Rationale
  - This ensures that users are able to report content for different categories such as sensitive or confidential information. This provides additional monitoring capabilities.
- Last Modified: February 13, 2024

- MITRE ATT&CK TTP Mapping
  - None

  #### GWS.CHAT.7.3v0.1
Spam, confidential information, and sensitive information SHALL be selected.

- Rationale
  - This ensures that users are able to report content for different categories such as sensitive or confidential information. This provides additional monitoring capabilities.
- Last Modified: February 13, 2024
- Notes
  - The other reporting categories MAY be included depending on agency needs.

- MITRE ATT&CK TTP Mapping
  - None

### Resources

- [Set-up content moderation for Chat](https://apps.google.com/supportwidget/articlehome?hl=en&article_url=https%3A%2F%2Fsupport.google.com%2Fa%2Fanswer%2F13471510%3Fhl%3Den&assistant_id=generic-unu&product_context=13471510&product_name=UnuFlow&trigger_context=a)

### Prerequisites

-   None

### Implementation

#### GWS.CHAT.7.1v0.1 Instructions
1.  Sign in to the [Google Admin Console](https://admin.google.com).
2.  Select **Menu** -> **Apps** -> **Google Workspace** -> **Google Chat**.
3.  Click **Content Reporting**.
4.  Ensure **Allow users to report content in Chat** is enabled.
5.  Click **Save**

#### GWS.CHAT.7.2v0.1 Instructions
1.  Sign in to the [Google Admin Console](https://admin.google.com).
2.  Select **Menu** -> **Apps** -> **Google Workspace** -> **Google Chat**.
3.  Click **Content Reporting**.
4.  Ensure **1:1 direct messages**, **Group direct messages**, and **Spaces** with **All spaces** is enabled.
5.  Click **Save**

#### GWS.CHAT.7.3v0.1 Instructions
1.  Sign in to the [Google Admin Console](https://admin.google.com).
2.  Select **Menu** -> **Apps** -> **Google Workspace** -> **Google Chat**.
3.  Click **Content Reporting**.
4.  Ensure **Spam**, **Confidential Information**, and **Sensitive Information** is enabled.
5.  Click **Save**
