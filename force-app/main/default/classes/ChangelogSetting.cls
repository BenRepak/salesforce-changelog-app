/**
 * @description abstracts uu_Changelog_Setting__mdt
 *
 * @author Ben Repak 20231030
 *
 * Modification Log:
 *
 * MOD      DATE        AUTHOR          MODIFICATION
 *
*/

public with sharing class ChangelogSetting{

    public String settingName;
    public String settingNewItemsMessage;
    public String settingReadItemsMessage;
    public String settingComponentTitle;
    public String settingNewItemsIcon;
    public String settingModalBody;
    public String settingModalHeader;
    public String settingDefaultItemIcon;
    public String filterCriteria;
    public Map<String,String> settingTypeIconMap;

    /**
     * @description  constructor to abstract uu_Changelog_Setting__mdt into a custom apex class
     * @param setting a single uu_Changelog_Setting__mdt record for the given implementation of changelog
     */
    public ChangelogSetting(uu_Changelog_Setting__mdt setting){
        this.settingName = setting.DeveloperName;
        this.settingComponentTitle = setting.Component_Title__c.trim();
        this.settingNewItemsIcon = setting.New_Items_Icon__c.trim();
        this.settingNewItemsMessage = setting.New_Items_Message__c.trim();
        this.settingReadItemsMessage = setting.Read_Items_Message__c.trim();
        this.settingModalHeader = setting.Changelog_Modal_Header__c.trim();
        this.settingModalBody = setting.Changelog_Modal_Body__c;
        this.settingDefaultItemIcon = setting.Change_Item_Icon_Default__c.trim();
        this.settingTypeIconMap = new Map<String, String>();
        this.filterCriteria = setting.Filter_Criteria__c.trim().normalizeSpace();

        // dynamically set icon type based on custom metadata settings
        if(String.isNotBlank(setting.Change_Type_Icon_Map__c)){
            String iconMapString = setting.Change_Type_Icon_Map__c.normalizeSpace();
            Map<String, Object> settings = (Map<String, Object>)JSON.deserializeUntyped(iconMapString);
            for(String s : settings.keySet()){
                settingTypeIconMap.put(s, (String)settings.get(s));
            }
        }
    }


}