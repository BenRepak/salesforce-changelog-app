/**
 * @description
 *
 * @author Ben Repak 20231030
 *
 * Modification Log:
 *
 * MOD      DATE        AUTHOR          MODIFICATION
 *
 */

import {LightningElement, api, wire} from 'lwc';
import UuSalesforceChangelogItems from 'c/uuSalesforceChangelogItems';
import logChangelogView from "@salesforce/apex/ChangelogController.logChangelogView";
import displayNewChangelogItems from "@salesforce/apex/ChangelogController.displayNewChangelogItems";
import getChangelogSettings from "@salesforce/apex/ChangelogController.getChangelogSettings";

import { refreshApex } from '@salesforce/apex';

export default class UuSalesforceChangelog extends LightningElement   {


    /**
     * @description set to false when done processing async methods
     * @type {boolean}
     * */
    processing = true;

    /**
     * @description displays new changelog message when set to true
     * @type {Boolean}
     * */
    displayNewCard;
    error;

    /**
     * @description used to hide or show entire component based on presence of user-visible log items
     * @type {boolean}
     */
    hasData = false;

    /**
     * @description api name of uu_Changelog_Setting__mdt record
     * @type {string}
     */
    @api
    setting = '';

    /**
     * @description ChangelogSetting values to control UI
     * @type {object}
     */
    jsonSettings = undefined;

    /** @description api name of uu_Changelog_Setting__mdt passed to controller
     * @type {string}
     */
    settingName;

    /** @description set to true when connectedCallback finishes
     * @type {boolean}
     */
    loaded = false;

    /** @description used to refresh cached component (https://developer.salesforce.com/docs/platform/lwc/guide/apex-result-caching.html)
     * @type {string}
     */
    wiredDisplayNewItemsResults;

    /**
     * @description on component load, imperatively call getChangelogSettings to get the settings for the page. If settings are successfully found, set local variables
     */
    connectedCallback() {
        getChangelogSettings({settingApiName : this.setting})
            .then((result) => {
                this.jsonSettings = JSON.parse(result);
                this.settingName = this.setting;
                this.loaded=true;
            })
            .catch((error) => {
                console.log('error --> ' + error);
                console.log('error --> ' + JSON.stringify(error));
                this.loaded=true;
            });
    }

    /**
     * @description wired function to identify if new changelog records exist for running user.
     * @param result boolean to identify whether to show New Record card. If null, no records exist.
     */
    @wire(displayNewChangelogItems, {settingApiName : '$settingName'})
    wiredDisplayNewItems( result ) {
        this.wiredDisplayNewItemsResults = result;
        if(result.data !== undefined) {
            this.hasData = true;
            this.displayNewCard = result.data;
            this.error = undefined;
            this.processing = false;
        } else if (result.error) {
            this.error = result.error;
            this.displayNewCard = undefined;
            this.processing = false;
        } else {
        }
    }


    /**
     * @description async function to handle changelog items modal open and close
     * @returns {Promise<void>}
     */
    async handleClick() {
        await logChangelogView();
        await refreshApex(this.wiredDisplayNewItemsResults);
        const result = await UuSalesforceChangelogItems.open({
            size: 'large',
            description: 'Accessible description of modal\'s purpose',
            content: this.jsonSettings.settingModalBody,
            heading: this.jsonSettings.settingModalHeader,
            settingName : this.setting
        });
        // if modal closed with X button, promise returns result = 'undefined'
        // if modal closed with OK button, promise returns result = 'okay'
    }


    /**
     * @description returns true if new records exists from wiredDisplayNewItems. used to display template in html
     * @returns {boolean}
     */
    get showNewCard(){
        return this.processing === false && this.displayNewCard !== undefined && this.displayNewCard === true
    }

    /**
     * @description returns true of no new records exist from wiredDisplayNewItems. used to display template in html
     * @returns {boolean}
     */
    get showReminderCard(){
        return this.processing === false &&  this.displayNewCard !== undefined && this.displayNewCard === false
    }

    /**
     * @description returns true if valid json settings are returned from controller, otherwise set to false. used to display template in html
     * @returns {boolean}
     */
    get hasMetadata(){
        return this.jsonSettings !== undefined && this.jsonSettings !== null;
    }




}