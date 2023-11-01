/**
 * @description controller used with uuchangelog lwcs
 *
 * @author Ben Repak 20231030
 *
 * Modification Log:
 *
 * MOD      DATE        AUTHOR          MODIFICATION
 *
*/

public with sharing class ChangelogController{

    public static ChangelogSetting setting;

    /**
     * @description  returns abstracted uu_Changelog_Setting__mdt record based on api name
     * @param settingApiName api name of uu_Changelog_Setting__mdt record to control component settings
     *
     * @return uu_Changelog_Setting__mdt record abstracted as instance of custom apex ChangelogSetting
     */
    public static ChangelogSetting buildChangelogSetting(String settingApiName){
        if(setting == null ) {
            uu_Changelog_Setting__mdt settingMetadata = uu_Changelog_Setting__mdt.getInstance(settingApiName);
            if(settingMetadata != null){
                setting =  new ChangelogSetting(settingMetadata);
            }
        }
        return setting;
    }


    /**
     * @description  returns abstracted uu_Changelog_Setting__mdt record based on api name
     * @param settingApiName api name of uu_Changelog_Setting__mdt record to control component settings
     *
     * @return serialized json of uu_Changelog_Setting__mdt record abstracted as instance of custom apex ChangelogSetting
     */
    @AuraEnabled
    public static String getChangelogSettings(String settingApiName){
        ChangelogSetting cls = buildChangelogSetting(settingApiName);
        if(cls == null) {
            return null;
        } else {
            return JSON.serialize(cls);
        }
    }


    /**
     * @description  retrieves uu_Changelog_Item__c records that meet the filter conditions from the uu_Changelog_Setting__mdt settings
     * @param settingApiName api name of uu_Changelog_Setting__mdt record to control component settings
     *
     * @return serialized json list of ChangelogItemGroup record groups
     */
    @AuraEnabled(Cacheable=true)
    public static String getRecentChangelogItems(String settingApiName){
        String jsonData = '';
        if(setting == null ) {
            setting = buildChangelogSetting(settingApiName);
        }

        String queryString = buildQuery(setting, false);

        List<uu_Changelog_Item__c> items = new List<uu_Changelog_Item__c>();
        items = Database.query(queryString);

        if(items.size() > 0) {
            List<ChangelogItemGroup> logs = ChangelogItemGroup.buildLogs(items, setting);
            jsonData = JSON.serialize(logs);
        }
        return jsonData;
    }


    /**
     * @description logs a uu_Changelog_User_View__c record each time a user opens the changelog modal
     */
    @AuraEnabled
    public static void logChangelogView(){
        try{
            insert new uu_Changelog_User_View__c();
        } catch(Exception e) {
            System.debug('an error occurred: ' + e.getMessage());
        }
    }


    /**
     * @description identifies if any new changelog items have been created since the user last opened the changelog modal
     * @param settingApiName api name of uu_Changelog_Setting__mdt record to control component settings
     *
     * @return true if new records exist since last modal open, otherwise false. returns null if no recent changelog records exist meeting filter criteria.
     */
    @AuraEnabled(Cacheable=true)
    public static Boolean displayNewChangelogItems(String settingApiName){
        if(setting == null ) {
            setting = buildChangelogSetting(settingApiName);
            if(setting == null){
                return null;
            }
        }

        Boolean displayNewChangelogItems = true;

        List<uu_Changelog_Item__c> items = new List<uu_Changelog_Item__c>();

        String queryString = buildQuery(setting, true);
        items = Database.query(queryString);

        if(items.size() == 0){
            return null;
        }

        // get most recent changelog item date/time based on filter settings
        Datetime maxItemDate;
        if(items.size() > 0){
            maxItemDate = items[0].Change_Datetime__c;
        }

        // get the most recent modal open date/time
        List<uu_Changelog_User_View__c> views = new List<uu_Changelog_User_View__c>();
        views = [
                SELECT CreatedDate
                FROM uu_Changelog_User_View__c
                WHERE CreatedById = :UserInfo.getUserId()
                ORDER BY CreatedDate DESC
                LIMIT 1];

        Datetime maxViewDate;
        if(views.size() > 0) {
            Datetime createdDate = views[0].CreatedDate;
            maxViewDate = createdDate;
        } else {
            maxViewDate = maxItemDate.addDays(-1);
        }

        displayNewChangelogItems = ( maxViewDate < maxItemDate ? true: false);

        return displayNewChangelogItems;
    }


    /**
     * @description build query string for uu_Changelog_Item__c records based on metadata filter settings
     * @param setting uu_Changelog_Setting__mdt record abstracted as instance of custom apex ChangelogSetting
     * @param checkForNewItems true if we are only checking for the displayNewCard boolean, or false to query for all records
     *
     * @return
     */
    private static String buildQuery(ChangelogSetting setting, Boolean checkForNewItems){
        String selectString = 'SELECT Id, Title__c, Short_Description__c, Documentation_Link__c, Change_Datetime__c, Change_Type__c ';
        String fromString = ' FROM uu_Changelog_Item__c ';
        String whereString = '';
        String limitString = '';
        if(String.isNotBlank(setting.filterCriteria)){
            whereString = ' WHERE ' + setting.filterCriteria;
        }
        // only look for new changelog records created since the users last view
        if(checkForNewItems){
            String sysNow = System.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            limitString = ' LIMIT 1 ';
            String newItemOnlyFilter = ' Change_Datetime__c < ' + sysNow ;  // ignore future items to be released
            if(String.isNotBlank(whereString)){
                whereString = whereString + ' AND ' + newItemOnlyFilter + ' ';
            } else {
                whereString = ' WHERE ' + newItemOnlyFilter + ' ';
            }
        }
        String orderByString = ' ORDER BY Change_Datetime__c DESC';
        String queryString = selectString + fromString + whereString + orderByString + limitString;
        return queryString;
    }


}