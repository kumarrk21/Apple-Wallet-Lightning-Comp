({

    scriptsLoaded:function(cmp,evt,helper){
        zip.useWebWorkers = false;
        zip.workerScriptsPath = '/resource/awresources/';
        /*
        zip.workerScripts = {
                                deflater: ['/resource/awresources/z-worker.js', '/resource/awresources/deflate.js'],
                                inflater: ['/resource/awresources/z-worker.js', '/resource/awresources/inflate.js']
                            };
        */
    },

	toggleProcessAtClient: function(cmp,evt,helper){
        cmp.set('v.processAtClient',cmp.find('processAtClient').get('v.checked'));
        console.log('Process at client',cmp.get('v.processAtClient'));
	},

    toggleEmailIDInput: function(cmp,evt,helper){
        var sendPassByEmail = cmp.find('sendPassByEmail').get('v.checked')
        cmp.set('v.sendPassByEmail',sendPassByEmail);
        //cmp.set('v.emailRequired',sendPassByEmail);
        if(sendPassByEmail){
            $A.util.removeClass(cmp.find('_emailDiv'), "slds-hide")
        }else{
            $A.util.addClass(cmp.find('_emailDiv'), "slds-hide")
        }
    },


    getCouponPass: function(cmp, evt, helper) {
    	cmp.set('v.passType','Coupon');
        helper.getPass(cmp, evt);
    },

    getBoardingPass: function(cmp,evt,helper){
        cmp.set('v.passType','BoardingPass');
    	helper.getPass(cmp, evt);
    },

    getEventPass: function(cmp,evt,helper){
        cmp.set('v.passType','EventPass');
        helper.getPass(cmp, evt);
    }    

})