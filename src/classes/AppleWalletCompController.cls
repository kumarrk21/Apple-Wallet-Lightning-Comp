public with sharing class AppleWalletCompController {
	public AppleWalletCompController() {
		
	}
	private class returnPass{
		String passJSON{get;set;}
		String passFile{get;set;}
		Boolean success{get;set;}
		String message{get;set;}
	}
	@AuraEnabled
	public static String getSamplePass(String passType,Boolean processAtClient,Boolean sendPassByEmail,String emalID){
		returnPass ret = new returnPass();
		AppleWalletSamplePassGenerator sample = new AppleWalletSamplePassGenerator();
		AppleWalletGenerator gen = new AppleWalletGenerator();
		String pass;
		Blob passData;
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
			passData = gen.getpkpassFile(pass,gen.resourceBlob);
			if(sendPassByEmail){
				AppleWalletGenerator.returnMessage retMsg = gen.sendPassByEmail(emalID,passData);
				ret.success = retMsg.success;
				ret.message = retMsg.message;
			}else{
				ret.passFile = EncodingUtil.base64Encode(passData);
			}
		}
		return JSON.serialize(ret);

	}


	@AuraEnabled 
	public static String sendPassByEmail(String emailID, String passFile){
		AppleWalletGenerator gen = new AppleWalletGenerator();
		Blob passData = EncodingUtil.base64Decode(passFile);
		AppleWalletGenerator.returnMessage retMsg = gen.sendPassByEmail(emailID,passData);
		returnPass ret = new returnPass();
		ret.success = retMsg.success;
		ret.message = retMsg.message;
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