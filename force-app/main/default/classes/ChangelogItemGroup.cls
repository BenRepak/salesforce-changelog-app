/**
 * @description groups uu_Changelog_Item__c by date
 *
 * @author Ben Repak 20231030
 *
 * Modification Log:
 *
 * MOD      DATE        AUTHOR          MODIFICATION
 *
*/

public with sharing class ChangelogItemGroup{

    public Date changelogDate;
    public List<ChangelogItem> changelogItems = new List<ChangelogItem>();

    public static Map<Date,ChangelogItemGroup> mapItems = new Map<Date,ChangelogItemGroup>();

    private ChangelogItemGroup(uu_Changelog_Item__c item, ChangelogSetting changelogSetting){
        ChangelogItem clItem = new ChangelogItem(item, changelogSetting);
        this.changelogDate = clItem.changelogDate;
        this.changelogItems.add(clItem);
        if(mapItems.containsKey( this.changelogDate)){
            mapItems.get( this.changelogDate).changelogItems.add(clItem);
        } else {
            mapItems.put( this.changelogDate, this);
        }
    }


    public static List<ChangelogItemGroup> buildLogs(List<uu_Changelog_Item__c> items, ChangelogSetting setting){

        // ChangelogSetting setting = ChangelogController.buildChangelogSetting(settingApiName);
        for(uu_Changelog_Item__c item : items){
            new ChangelogItemGroup(item, setting);
        }
        return mapItems.values();
    }



}