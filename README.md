# Utah Changelog
This app allows Salesforce admins to share changes made in the system with users. It is configurable using custom metadata and LWCs.
___
## Getting Started
Please follow the steps below to install this app in your org. You may choose to create a scratch org, or install directly in a sandbox.

### Step 1: Install Salesforce CLI and Git
Use the Salesforce CLI to install this project in a target org. 

Learn more:
 - [Install Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm)
 - [Install Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
 - [Quick Start: Salesforce DX Trailhead Project](https://trailhead.salesforce.com/content/learn/projects/quick-start-salesforce-dx/set-up-the-project-on-your-local-machine)


### Step 2: Clone Project Local Repository 
```
git clone https://github.com/BenRepak/salesforce-changelog-app
```

### Step 3: Deploy Project
Deploy the project to your target org using the following sfdx command. 

Be sure to replace **my-org** with the alias of your desired target org.
```
sf project deploy start  --source-dir force-app/main/default --target-org my-org
```

### Step 4: Load Sample Data
Use the following sfdx command to load the sample dataset from the data directory. 

Be sure to replace **my-org** with the alias of your desired target org. 
```
sf data import tree --files data/uu_Changelog_Item__c.json --target-org my-org
```

### Step 5: Assign Permission Sets
You can manually do this to desired users in your org. Or you can run the following command to assign the **Manage_Changelog_Items** permission set to the running user (aka, you).

Be sure to replace **my-org** with the alias of your desired target org.

```
sf org assign permset --name Manage_Changelog_Items --target-org my-org
```
### Step 6: Add Changelog to UI
1. Open a Lightning App Builder page and search for the UU Salesforce Changelog custom LWC.
2. Next, add the UU Salesforce Changelog LWC to your desired Lightning App Builder page. 
3. Finally, enter the API name of the desired uu_Changelog_Setting__mdt record to the setting variable. Out of the box, you can use the Default_Changelog record.
![Add changelog to Flexipage](/assets/images/add_changelog_to_flexipage.png)
___
## Using the App

The app is pretty simple:
- First, you define custom metadata records that will control the UI (uu_Changelog_Setting__mdt)
- Next, you add the changelog LWC (uuSalesforceChangelog) to the desired user interface
- Lastly, you share your hard work with the world (or at least your users) by creating new uu_Changelog_Item__c records

### New Items Alert Display
The first time a user views the log component, they will be greeted with a New Items Alert message. This "New Items" message will display each time the user views the component and there have been new changelog items added since they last time they opened the changelog.
![New Items Alert](/assets/images/display_items_new.png)

### Viewing Updates
To view the changelog, a user can click the "View Updates" button.

![View Updates Button](/assets/images/view_updates_button.png)

This will open a Changelog Modal Display, where changelog items are grouped by Change Date.
![Changelog Modal Display](/assets/images/changelog_modal.png)

### Existing Items Reminder
After viewing the changelog, the component will become less pronounced. The component will remain in this quiet state until a new changelog item is added.

![Existing Items Reminder](/assets/images/display_items_reminder.png)
___
## Customizing the App
The app can be customized using the uu_Changelog_Setting__mdt custom metadata records. 

Each record represents a unique configuration for an instance of the changelog and each field controls various aspects of the app's functionality.
![Changelog Custom Metadata Settings](/assets/images/changelog_settings_fields.png)



### Customize UI Elements
The following uu_Changelog_Setting__mdt fields control display elements on the New Items Alert display:
- Component Title
- New Items Message
- New Items Icon

![New Items Alert Display Settings](/assets/images/display_new_settings.png)


The following uu_Changelog_Setting__mdt fields control display elements on the Existing Items Reminder display:
- Read Items Message

![Existing Items Reminder Display Settings](/assets/images/display_reminder_settings.png)

The following uu_Changelog_Setting__mdt fields control display elements on the Changelog Modal display:
- Change Type Icon Map (maps values from the Change_Type__c field on the uu_Changelog_Item__c record to an SLDS icon https://www.lightningdesignsystem.com/icons/)
- Changelog Modal Header
- Changelog Modal Body 
- Change Item Icon Default (default Change_Type__c icon if not found in map)

![Changelog Modal Display Settings](/assets/images/changelog_modal_settings.png)


### Customize Filters 
For each uu_Changelog_Setting__mdt custom metadata record, a filter can be applied to limit the uu_Changelog_Item__c displayed to users. For example, a filter could be applied to only show uu_Changelog_Item__c records from the last 30 days. The conditions used will be added to the WHERE clause in a Dynamic SOQL query.

The following uu_Changelog_Setting__mdt fields control filtering:
- Filter Criteria
