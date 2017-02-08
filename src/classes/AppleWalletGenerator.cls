global class AppleWalletGenerator {
	public Wallet_Setting__c ws{get;set;}
	public Blob resourceBlob{get;set;}

	public AppleWalletGenerator() {
			
	}

	public void  getWalletSettings(String walletName){
		ws = [Select Apple_Certificate_ID__c, Organization_Name__c, Pass_Description__c,Pass_Identifier__c,Serial_Number__c,Team_Identifier__c,Wallet_Certificate_ID__c,Wallet_Certificate_Password__c,Wallet_Resources_ID__c,SignGeneratorAPIURL__c FROM Wallet_Setting__c WHERE Name=:walletName LIMIT 1];
		
	}

	public void getResourceBlob(){
		resourceBlob = [Select VersionData from ContentVersion where ContentDocumentId=:ws.Wallet_Resources_ID__c LIMIT 1].VersionData;
	}

	public returnMessage sendPassByEmail(String emailID, Blob passFile){
		returnMessage ret = new returnMessage();
		ret.success = true;
		ret.message = 'Email Successfully Sent';
		try{
			List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			
			List<String> sendTo = new List<String>();
			sendTo.add(emailID);

			List<Messaging.EmailFileAttachment> atts = new List<Messaging.EmailFileAttachment>();
			Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
			att.setBody(passFile);
			att.setFileName('Pass.pkpass');
			att.setInline(false);
			atts.add(att);

			email.setPlainTextBody('Pass file enclosed');
			email.setSubject('Sample apple wallet pass');
			email.setToAddresses(sendTo);
			email.setFileAttachments(atts);

			emails.add(email);
			Messaging.sendEmail(emails);	
			}catch(Exception e){
				ret.success = false;
				ret.message = 'Error in sending email - ' + e.getMessage() + 'at Line number ' + e.getLineNumber();
			}
		

		return ret;
	}

	public Blob getpkpassFile(string pass, Blob resourceBlob){
		Zippex zipFile = new Zippex(resourceBlob);
		Set <String> fileNames = zipFile.getFileNames();
		Map<String,String> hashes = new Map<String,String>();
		Blob passBlob = Blob.valueOf(pass);
		hashes.put('pass.json',EncodingUtil.convertToHex(Crypto.generateDigest('SHA1',passBlob)));
		for (String fileName : fileNames)
		{
			if( !fileName.startsWith('__MACOSX') && 
				!fileName.startsWith('.DS_Store') &&
				!fileName.endsWith('/')){
				Blob fileData = zipFile.getFile(fileName);
    			if(fileData != null){
    				Blob digest = Crypto.generateDigest('SHA1',fileData);
    				hashes.put(fileName,EncodingUtil.convertToHex(digest));	
    				digest = null;
    			}	
    			fileData = null;
			}
		}
		String manifestJSON = JSON.serialize(hashes,true);
		zipFile.addFile('pass.json',passBlob,null);
		zipFile.addFile('manifest.json',Blob.valueOf(manifestJSON),null);
		zipFile.addFile('signature',getSignature(manifestJSON,ws),null);
		return zipFile.getZipArchive();
	}

	public Blob getSignature(String manifestJSON, Wallet_Setting__c ws){
		
		Blob passCertBlob= [Select VersionData from ContentVersion where ContentDocumentId=:ws.Wallet_Certificate_ID__c LIMIT 1].VersionData;
		Blob caCertBlob= [Select VersionData from ContentVersion where ContentDocumentId=:ws.Apple_Certificate_ID__c LIMIT 1].VersionData;

		String url = ws.SignGeneratorAPIURL__c;
		Http h = new Http();
	    HttpRequest req = new HttpRequest();
	    req.setEndpoint(url);
	    req.setMethod('POST');
	    req.setHeader('passCert', EncodingUtil.base64Encode(passCertBlob));
	    req.setHeader('caCert', EncodingUtil.base64Encode(caCertBlob));
	    req.setHeader('passKey', ws.Wallet_Certificate_Password__c);
	    req.setHeader('manifestJSON', manifestJSON);
	    HttpResponse res = h.send(req);
	    return res.getBodyAsBlob();

	}

	public class returnMessage{
		public Boolean success{get;set;}
		public String message{get;set;}
	} 


}