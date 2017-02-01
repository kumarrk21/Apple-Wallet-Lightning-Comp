public with sharing class AppleWalletCompController {
	public AppleWalletCompController() {
		
	}
	private class returnPass{
		String passJSON{get;set;}
		String passFile{get;set;}
	}
	@AuraEnabled
	public static String getSamplePass(String passType,Boolean processAtClient){
		returnPass ret = new returnPass();
		AppleWalletSamplePassGenerator sample = new AppleWalletSamplePassGenerator();
		AppleWalletGenerator gen = new AppleWalletGenerator();
		String pass;
		gen.getWalletSettings(getWalletName(passType));

		if(passType=='Coupon'){
			pass = sample.createCouponPass(gen.ws);
		}else if(passType=='BoardingPass'){
			pass = sample.createBoardingPass(gen.ws);
		}else if(passType=='EventPass'){
			pass = sample.createEventPass(gen.ws);
		}
		
		gen.getResourceBlob();
		if(processAtClient){
			//This a placeholder in case Zip and SHA1 signing needs to be done at client;
			ret.passJSON = JSON.serialize(pass);
			ret.passFile = EncodingUtil.base64Encode(gen.resourceBlob);
		}else{
			ret.passFile = EncodingUtil.base64Encode(gen.getpkpassFile(pass,gen.resourceBlob));

		}
		return JSON.serialize(ret);

	}

	@AuraEnabled
	public static String getSignature(String passType, String manifestJSON){
		AppleWalletGenerator gen = new AppleWalletGenerator();
		gen.getWalletSettings(getWalletName(passType));
		return EncodingUtil.base64Encode(gen.getSignature(manifestJSON,gen.ws));
	}

	private static String getWalletName(String passType){
		String walletName = '';
		if(passType=='Coupon'){
			walletName = 'Sample Coupon';
		}else if(passType=='BoardingPass'){
			walletName = 'Sample BoardingPass';
		}else if(passType=='EventPass'){
			walletName = 'Sample EventPass';
		}
		return walletName;

	}

}