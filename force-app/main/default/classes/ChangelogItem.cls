/**
 * @description abstracts uu_Changelog_Item__c records
 *
 * @author Ben Repak 20231030
 *
 * Modification Log:
 *
 * MOD      DATE        AUTHOR          MODIFICATION
 *
*/

public with sharing class ChangelogItem{
    public String changelogId;
    public String changelogTitle;
    public String changelogDocumentLink;
    public String changelogShortDescription;
    public Date changelogDate;
    public String changeType;
    public String iconType;

    /**
     * @description  constructor to dynamically build changelog item based on the provided setting
     * @param item changelog record to be abstracted
     * @param changelogSetting instance of ChangelogSetting (abstracted uu_Changelog_Setting__mdt)
     */
    public ChangelogItem(uu_Changelog_Item__c item, ChangelogSetting changelogSetting){
        this.changelogDate = Date.valueOf(item.Change_Datetime__c);
        this.changelogId = item.Id;
        this.changelogTitle = item.Title__c;
        this.changelogShortDescription = item.Short_Description__c;
        this.changelogDocumentLink = item.Documentation_Link__c;
        this.changeType = item.Change_Type__c;

        // conditionally set icon type
        if(String.isNotBlank(item.Change_Type__c)) {
            if(changelogSetting.settingTypeIconMap.containsKey(item.Change_Type__c)){
                this.iconType = changelogSetting.settingTypeIconMap.get(item.Change_Type__c);
            } else {
                this.iconType = changelogSetting.settingDefaultItemIcon;
            }
        }
    }
}