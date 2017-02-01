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
		cmp.set('v.processAtClient',evt.target.checked);
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
