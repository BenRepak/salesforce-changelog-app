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

import {LightningElement, wire, api} from 'lwc';
import getRecentChangelogItems from "@salesforce/apex/ChangelogController.getRecentChangelogItems";
import LightningModal from 'lightning/modal';


export default class UuSalesforceChangelogItems extends LightningModal {

    /**
     * @description list of changelog items to be used in modal
     * @type {array}
     */
    data;
    error;

    /**
     * @description modal body
     * @type {string}
     */
    @api content;

    /**
     * @description modal header
     * @type {string}
     */
    @api heading;

    /** @description api name of uu_Changelog_Setting__mdt passed to controller
     * @type {string}
     */
    @api settingName = '';

    /**
     * @description boolean to control display of spinner while loading changelog items
     * @type {boolean}
     */
    loaded = false;

    /**
     * @description wired function to retrieve changelog items upon load
     */
    @wire(getRecentChangelogItems,{settingApiName : "$settingName"})
    wiredChangelogs({ error, data }) {
        console.log('executing function...');
        if (data) {
            this.data = JSON.parse(data);
            this.error = undefined;
            this.loaded = true;
        } else if (error) {
            console.log('error --> ' + error);
            console.log('stringified error --> ' + JSON.stringify(error));
            this.error = error;
            this.data = undefined;
            this.loaded = true;
        } else {
            this.data = undefined;
            this.error = undefined;
            this.loaded = true;
        }
    }

    /**
     * @description used to close modal and send message back to parent component
     */
    handleOkay() {
        this.close('okay');
    }


}