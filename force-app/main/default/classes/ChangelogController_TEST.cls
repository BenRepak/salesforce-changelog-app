/**
 * @description test class for ChangelogController
 *
 * @author Ben Repak 20231030
 *
 * Modification Log:
 *
 * MOD      DATE        AUTHOR          MODIFICATION
 *
*/
@IsTest
private class ChangelogController_TEST{


    @TestSetup
    private static void makeData(){
        Datetime yesterday = System.now().addDays(-1);
        uu_Changelog_Item__c cli = new uu_Changelog_Item__c();
        cli.Title__c = 'Test Item';
        cli.Short_Description__c = 'short description';
        cli.Change_Datetime__c = yesterday;
        cli.Change_Type__c = 'Bug Fix';
        cli.Is_Published__c = 'Yes';
        cli.Changelog_Audience__c = 'All';

        insert cli;


    }


    @IsTest
    private static void testBuildChangelogSettingSuccess(){
        String defaultChangelogName = 'Default_Changelog';
        String jsonChangelogSetting;
        Test.startTest();
        jsonChangelogSetting = ChangelogController.getChangelogSettings(defaultChangelogName);
        Test.stopTest();

        Assert.isNotNull(jsonChangelogSetting,'Expect a valid uu_Changelog_Setting__mdt to be returned');
    }

    @IsTest
    private static void testBuildChangelogSettingFail(){
        String invalidChangelogName = 'Invalid_Test_Bad_Record';
        String jsonChangelogSetting;
        Test.startTest();
        jsonChangelogSetting = ChangelogController.getChangelogSettings(invalidChangelogName);
        Test.stopTest();

        Assert.isNull(jsonChangelogSetting,'Expect no matching uu_Changelog_Setting__mdt to be returned');
    }

    @IsTest
    private static void testShowReminderSuccess(){
        // create changelog view
        insert new uu_Changelog_User_View__c();

        String defaultChangelogName = 'Default_Changelog';
        Boolean displayNewLogMessage;
        Test.startTest();
        displayNewLogMessage = ChangelogController.displayNewChangelogItems(defaultChangelogName);
        Test.stopTest();

        Assert.areEqual(false,displayNewLogMessage,'Expect to return false, indicating that the user has viewed the most recent records');
    }

    @IsTest
    private static void testShowNewItemsSuccess(){
        // intentionally do not log any views

        String defaultChangelogName = 'Default_Changelog';
        Boolean displayNewLogMessage;
        Test.startTest();
        displayNewLogMessage = ChangelogController.displayNewChangelogItems(defaultChangelogName);
        Test.stopTest();

        Assert.areEqual(true,displayNewLogMessage,'Expect to return true, indicating that new changelogs have been created since the users last view');
    }

    @IsTest
    private static void testNoItemsSuccess(){
        // intentionally delete all changelog items
        List<uu_Changelog_Item__c> items = [select id from uu_Changelog_Item__c];
        delete items;

        String defaultChangelogName = 'Default_Changelog';
        Boolean displayNewLogMessage;
        Test.startTest();
        displayNewLogMessage = ChangelogController.displayNewChangelogItems(defaultChangelogName);
        Test.stopTest();

        Assert.areEqual(null,displayNewLogMessage,'Expect to return null, indicating that no changelog items are viewable by the user');
    }

    @IsTest
    private static void testCreateChangelogViewSuccess(){
        Test.startTest();
        ChangelogController.logChangelogView();
        Test.stopTest();
        List<uu_Changelog_User_View__c> views = [SELECT Id FROM uu_Changelog_User_View__c];
        Integer countViews = views.size();
        Assert.areEqual(1,countViews,'Expect 1 view to be logged');
    }


    @IsTest
    private static void testGetRecentLogsResultsSuccess(){

        String defaultChangelogName = 'Default_Changelog';
        String jsonDataLogData;
        Test.startTest();
        jsonDataLogData = ChangelogController.getRecentChangelogItems(defaultChangelogName);
        Test.stopTest();

        Assert.areNotEqual('',jsonDataLogData,'Expect there to be jsonDataLogData');
        Assert.areNotEqual(null,jsonDataLogData,'Expect there to be jsonDataLogData');

    }

    @IsTest
    private static void testGetRecentLogsNoResultsSuccess(){
        // intentionally delete all changelog items
        List<uu_Changelog_Item__c> items = [select id from uu_Changelog_Item__c];
        delete items;

        String defaultChangelogName = 'Default_Changelog';
        String jsonDataLogData;
        Test.startTest();
        jsonDataLogData = ChangelogController.getRecentChangelogItems(defaultChangelogName);
        Test.stopTest();

        Assert.areEqual('',jsonDataLogData,'Expect there to NOT be jsonDataLogData');

    }



}