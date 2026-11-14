# ai-agentforce-builder-project

# Agentforce Project

# Salesforce AI-Powered Customer Service & Intelligent Automation

This Salesforce DX project contains a sample agent called Local Info Agent that you could, for example, embed in a resort's web site. The agent provides local weather updates, shares information about local events, and helps guests with facility hours. 

The agent demonstrates:

- Three types of subagents (Invocable Apex, Prompt Template, and Flow).
- Mutable variables.
- Flow control with `available when`.
- Deterministic branching with `if/else` in reasoning instructions.

## Prerequisites

- **Salesforce Developer Edition (DE)** org. Get a free one at [developer.salesforce.com/signup](https://developer.salesforce.com/signup). 
- **Salesforce CLI** (`sf`). Download and install it from [developer.salesforce.com/tools/sfdxcli](https://developer.salesforce.com/tools/sfdxcli).  See the [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm) for more detailed information. 
- **VS Code** with the **Salesforce Extensions** pack and the **Agentforce DX** extension. See [Install Pro-Code Tools](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-dx-set-up-env.html) for details. 

After you get a DE org and set up your tools, authorize the org so you can start working with it.  Open VS Code and use the **SFDX: Authorize an Org** VS Code command from the Command Palette, or run this CLI command in VS Code's integrated terminal:

```bash
sf org login web --alias my-de-org --set-default
```
Log in to the browser that opens using your DE credentials.  

## Configure Your Salesforce DX Project

Your new Salesforce DX project is ready to use.  

But you can further configure it by editing the `sfdx-project.json` file. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file. 

## Enable Skills in Agentforce Vibes to Vibe Code Agents

To vibe code agents using Agentforce Vibes, first open the Agentforce Vibes panel. Click the **Manage Skills, Rules, Workflows, and Hookss** icon, then the **Skills** tab, and ensure these skills are enabled:

- `developing-agentforce`
- `observing-agentforce`
- `testing-agentforce`

That's it!


## Project Overview

This project focuses on leveraging Salesforce capabilities and Generative AI to automate customer service operations, streamline customer information management, and simplify document processing.

The solution combines Salesforce Service Cloud, Agentforce, Apex, and Google Gemini AI to deliver intelligent automation, improve operational efficiency, reduce manual intervention, and enhance the overall customer experience.

The project consists of three major functional areas:

---

## 1. AI-Powered Booking Management Using Agentforce

### Business Challenge

A leading B2B car rental and mobility solutions provider faced inefficiencies in managing customer interactions related to booking cancellations, amendments, and re-bookings.

These processes were entirely manual, often resulting in longer resolution times, inconsistent agent responses, and repetitive questioning. This impacted customer satisfaction, increased support team workloads, and affected overall service quality.

### Solution Implemented

Implemented an intelligent customer service automation solution using Salesforce Service Cloud and Agentforce to automate booking cancellations, amendments, and re-bookings.

**Key Features:**

- Configured custom Apex classes and Agentforce actions to drive personalized, intent-based chat flows.
- Defined agent instructions to guide customer conversations and provide appropriate booking solutions.
- Implemented intelligent conversation flows that suggest alternatives, such as booking amendments or re-booking, before confirming cancellations.
- Integrated pre-built APIs to ensure data accuracy during booking amendments.
- Enabled customers to modify details such as email addresses and flight information directly within the same chat session.
- Dynamically captured re-booking preferences, including pickup/drop-off dates, times, and locations.
- Reduced repetitive customer queries through intelligent information gathering and contextual conversations.
- Minimized manual intervention by simulating human-like customer interactions.

### Business Benefits

- Faster resolution of booking-related requests.
- Reduced manual intervention and support workload.
- Improved consistency in customer interactions.
- Enhanced customer satisfaction.
- Seamless self-service experience for booking management.

---

## 2. Salesforce Account Summary

### Overview

Implemented an Account Summary capability within Salesforce to provide users with a consolidated overview of customer account information.

The objective is to simplify access to important account details, improve customer information visibility, and help business users retrieve relevant account information efficiently.

### Key Features

- Consolidated customer account information.
- Simplified access to relevant account details.
- Improved visibility into customer information.
- Reduced effort required to navigate multiple Salesforce records.
- Enhanced user experience through centralized account information access.

### Business Benefits

- Improved account information accessibility.
- Faster retrieval of customer details.
- Better visibility into customer accounts.
- Improved operational efficiency for Salesforce users.

---

## 3. AI-Powered Government Identity Document Processing Using Google Gemini

### Overview

Implemented an AI-powered document processing solution by integrating Salesforce with the Google Gemini Flash API to extract customer information from government-issued identity documents.

The solution automates information extraction and Salesforce record creation, reducing manual data entry and simplifying customer onboarding.

### Solution Implemented

- Integrated Salesforce with the Google Gemini Flash API.
- Enabled AI-based processing of government-issued identity documents.
- Extracted relevant customer information from uploaded identity documents.
- Processed the extracted information to prepare structured customer data.
- Automatically created Salesforce Contact records using the extracted customer information.
- Created and associated customer document attachment records within Salesforce.
- Maintained API execution logs to track integration requests and responses.
- Captured API execution statuses to monitor successful and unsuccessful processing.
- Improved integration traceability and error monitoring.

### Business Benefits

- Reduced manual data entry.
- Faster customer onboarding.
- Automated customer information extraction.
- Improved operational efficiency.
- Centralized customer document management.
- Better integration monitoring through API logs and execution statuses.

---

## Technology Stack

| Technology | Purpose |
|---|---|
| Salesforce Service Cloud | Customer service management |
| Salesforce Agentforce | AI-powered customer interactions |
| Apex | Custom business logic and automation |
| Agent Actions | Booking management automation |
| Salesforce APIs | Integration with external booking systems |
| Google Gemini Flash API | AI-powered identity document information extraction |
| Salesforce Contacts | Automated customer record creation |
| Salesforce Files / Attachments | Customer document storage |
| API Logging | Integration monitoring and execution tracking |

---

## Overall Project Benefits

- **Process Automation:** Automated repetitive business processes and reduced manual intervention.
- **AI Integration:** Leveraged Agentforce and Google Gemini AI for intelligent customer interactions and document processing.
- **Improved Productivity:** Reduced operational effort and accelerated business workflows.
- **Data Accuracy:** Improved data consistency through API integrations and structured information processing.
- **Enhanced Customer Experience:** Delivered faster, more efficient, and seamless customer interactions.
- **Integration Monitoring:** Implemented API logging and status tracking for better integration visibility and troubleshooting.

---

## Conclusion

This project demonstrates the implementation of AI-driven Salesforce solutions by combining Salesforce Service Cloud, Agentforce, Apex, and Google Gemini AI.

From intelligent booking management and centralized account information to automated government identity document processing, the solution transforms traditional manual workflows into intelligent, efficient, and scalable business processes.


### Use Other AI Tools

If you prefer to use other AI tools, such as Claude Code or Cursor, copy these skills from the `sf-skills` GitHub repository to the appropriate directory in this DX project. Check your AI tool's documentation for the specific location and how to enable the skills.  

- [`developing-agentforce`](https://github.com/forcedotcom/sf-skills/tree/main/skills/developing-agentforce)
- [`observing-agentforce`](https://github.com/forcedotcom/sf-skills/tree/main/skills/observing-agentforce)
- [`testing-agentforce`](https://github.com/forcedotcom/sf-skills/tree/main/skills/testing-agentforce)

## Vibe Code the Sample Agent

Salesforce agents use an Agent Script file as their blueprint. To vibe code an agent, you vibe code its Agent Script file. Agent Script files are part of the `AiAuthoringBundle` metadata type.

Let's see how this works by vibe coding the Agent Script file associated with the sample Local Info Agent. Open up the `force-app/main/default/aiAuthoringBundle/Local_Info_Agent/Local_Info_Agent.agent` file in VS Code, then enter your prompts in the Agentforce Vibes chat box. For example, to learn more about how the agent is coded, ask questions like: 

- _What does the Local Info Agent do?_
- _What Apex classes does this agent use?_
- _Does the agent use flows?_

As you get more familiar with vibe coding a Salesforce agent, you can start making actual changes to the Agent Script file.

## Preview the Agent in Simulated Mode

You can preview how the agent works right in VS Code using the Agentforce DX panel. For now you must preview in _simulated mode_, because you haven't yet deployed the Apex classes, flow, or prompt template to your org. After you deploy, you can use _live mode_ in which the agent uses the actual Apex classes, etc.  In simulated mode, the Local Info Agent mocks the answers to your questions. 

To preview in simulated mode, right-click the `Local_Info_Agent.agent` file and choose **AFDX: Preview This Agent**.  In the Agentforce DX panel that opens, click **Start Simulation**.  Then enter a question in the chat box at the bottom, such as `What's the weather like?`.  The agent simulates an answer. 

## Agentforce-Ready Scratch Orgs

This template includes a scratch org configuration file (`config/project-scratch-def.json`) that contains the required settings and features for creating an Agentforce-ready scratch org. 

Here's an example of creating a scratch org using the file; it assumes you've already authorized the Dev Hub org with alias `DevHub`:

```bash
sf org create scratch --definition-file config/project-scratch-def.json --alias AgentScratchOrg --set-default --target-dev-hub DevHub
```

## What's Inside This DX Project?

These are the interesting metadata components associated with the Local Info Agent. All the component source files are in the `force-app/main/default` package directory under their associated metadata directory, such as `classes` for Apex classes.

| Component | Type | Purpose |
|---|---|---|
| `Local_Info_Agent.agent` | Agent Script | The agent definition — tools, reasoning, variables, and flow control. |
| `CheckWeather` | Apex Class | Invocable Apex. Checks current weather conditions for a given location. |
| `CurrentDate` | Apex Class | Invocable Apex. Returns the current date for use by the agent. |
| `WeatherService` | Apex Class | Provides mock weather data for the resort. |
| `Get_Event_Info` | Prompt Template | Retrieves local events.|
| `Get_Resort_Hours` | Flow | Returns facility hours and reservation requirements. |
| `Resort_Agent` | Permission Set | Agent user permissions (Einstein Agent license). |
| `Resort_Admin` | Permission Set | Admin/developer Apex class access. |
| `AFDX_Agent_Perms` | Permission Set Group | Bundles agent user permissions for assignment. |
| `AFDX_User_Perms` | Permission Set Group | Bundles admin user permissions for assignment. |

## Next Steps

This README provides just a taste of working with Salesforce agents. Check out the [_Agentforce DX Developer Guide_](https://developer.salesforce.com/docs/einstein/genai/guide/agent-dx.html) which shows you how to:

- Author an agent, which involves generating an authoring bundle, coding the Agent Script file, and publishing the agent to your org.
- Preview and debug an agent.
- Test an agent.

## Read All About It

- [_Agentforce DX Developer Guide_](https://developer.salesforce.com/docs/einstein/genai/guide/agent-dx.html)
- [_Agent Script_](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-script.html)
- [_Agentforce Vibes Extension_](https://developer.salesforce.com/docs/platform/einstein-for-devs/guide/einstein-overview.html)

- [_Salesforce Extensions for VS Code_](https://developer.salesforce.com/docs/platform/sfvscode-extensions/guide)
- [_Salesforce CLI Setup Guide_](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [_Salesforce DX Developer Guide_](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [_Salesforce CLI Command Reference_](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
