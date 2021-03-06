# Project Requirements



# Intro

The purpose of this document is to explain the two parts I will try to implement for this project. The first thing I will implement is a way to extract and send biometric data to server from an empatica e4 wristband. The second part is to develop an extension for vscode that will record and timestamp certain events. I will have 130 hours to complete these tasks.

# Limitations

1. The data extraction app will only be available for Ios devices.
2. The project must be completed within 130 hours.

# Requirements

Device data extraction requirements

D1: Develop an app that gather the data from the device.

D2:UI.

D3: App should be able to handle different users.

D4: Formatting of data and transmission to server using correct API call.

Vscode Extension

E1: Develop an extension for vscode. The extension must be able to record certain events (ex, opened files, git commits etc�).

E2: Time stamp each event.



## Cost and Priority



| ID | Priority | Description | Cost in hours | Dependencies | Status |
| --- | --- | --- | --- | --- | --- |
| D1 | 10 | Data collection | 30 |   | Complete |
| D2 | 7 | UI | 40 | D1 | Complete |
| D3 | 8 | Different user handling | 10 |   | Complete |
| D4 | 10 | Data formatting and transmission | 30 | D1, D2 | Complete\* |
| E1 | 8 | Extension triggers | 50 |   | Not delivered |
| E2 | 8 | Extension trigger timestamps | 10 | E2 | Not delivered |



# Delivery

| ID | Objectives | Descriptions | Cost in hours | Due date | Status |
| --- | --- | --- | --- | --- | --- |
| Sprint 1 | D1 | Data collection | 30 | Feb 20 | Complete |
| Sprint 2 | D2, D3, D4, E1 | UI, different user handling | 40 | March 9 | Complete |
| Sprint 3 | E1 | Send data | 40 | March 19 | Complete |
| Final delivery | E2 | Send data | 10 | March 26 | Complete |



\*Issue with e4Link framework makes it impossible to correctly gather data from the device. Could be fixed if Empatica updates their SDK to support newer versions of IOS.