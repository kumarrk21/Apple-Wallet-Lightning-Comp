public with sharing class AppleWalletSamplePassGenerator {
	public ApplePassBookDictionary pass {get;set;}

	public AppleWalletSamplePassGenerator() {
		pass = new ApplePassBookDictionary();	
	}

	private ApplePassBookDictionary getPassStandardFields(Wallet_Setting__C ws, ApplePassBookDictionary pass){
		pass.formatVersion = 1;
		pass.organizationName = ws.Organization_Name__c; 
		pass.description = ws.Pass_Description__c;
		pass.passTypeIdentifier = ws.Pass_Identifier__c; 
		pass.serialNumber = ws.Serial_Number__c;
		pass.teamIdentifier = ws.Team_Identifier__c;
		//pass.webServiceURL = ''; //tbd
		//pass.authenticationToken = ''; //tbd
		return pass;
	}

	public String createEventPass(Wallet_Setting__C ws){
		pass = getPassStandardFields(ws,pass);
		pass.relevantDate = '2017-01-31T14:25-08:00';

		List<ApplePassBookDictionary.locationKey> locations = new List<ApplePassBookDictionary.locationKey>();
		ApplePassBookDictionary.locationKey location = new ApplePassBookDictionary.locationKey();
		location.longitude = -122.3748889;
		location.latitude = 37.6189722;
		locations.add(location);

		location = new ApplePassBookDictionary.locationKey();
		location.longitude = -122.03118;
		location.latitude = 7.33182;
		locations.add(location);

		pass.locations = locations;

		List<ApplePassBookDictionary.barcodeKey> barcodes = new List<ApplePassBookDictionary.barcodeKey>();
		ApplePassBookDictionary.barcodeKey barcode = new ApplePassBookDictionary.barcodeKey();
		barcode.message = '123456789';
		barcode.format = 'PKBarcodeFormatPDF417';
		barcode.messageEncoding = 'iso-8859-1';
		barcodes.add(barcode);
		pass.barcodes = barcodes;

		pass.foregroundColor = 'rgb(255, 255, 255)';
		pass.backgroundColor = 'rgb(60, 65, 76)';

		List<ApplePassBookDictionary.fieldDictKey> primaryFields = new List<ApplePassBookDictionary.fieldDictKey>();
		ApplePassBookDictionary.fieldDictKey  field = new ApplePassBookDictionary.fieldDictKey();
		field.key = 'event';
		field.label = 'EVENT';
		field.value = 'The Beat Goes On';
		primaryFields.add(field);

		List<ApplePassBookDictionary.fieldDictKey> secondaryFields = new List<ApplePassBookDictionary.fieldDictKey>();
		field = new ApplePassBookDictionary.fieldDictKey();
		field.key = 'loc';
		field.label = 'LOCATION';
		field.value = 'Moscone West';
		secondaryFields.add(field);

		pass.eventTicket = new ApplePassBookDictionary.passStructureKey();
		pass.eventTicket.primaryFields = primaryFields;
		pass.eventTicket.secondaryFields = secondaryFields;

		return JSON.serialize(pass,true);
	}

	public String createBoardingPass(Wallet_Setting__C ws){
		pass = getPassStandardFields(ws,pass);

		pass.relevantDate = '2017-01-31T14:25-08:00';

		List<ApplePassBookDictionary.barcodeKey> barcodes = new List<ApplePassBookDictionary.barcodeKey>();
		ApplePassBookDictionary.barcodeKey barcode = new ApplePassBookDictionary.barcodeKey();
		barcode.message = 'SFOJFK JOHN APPLESEED LH451 2012-07-22T14:25-08:00';
		barcode.format = 'PKBarcodeFormatPDF417';
		barcode.messageEncoding = 'iso-8859-1';
		barcodes.add(barcode);
		pass.barcodes = barcodes;

		List<ApplePassBookDictionary.locationKey> locations = new List<ApplePassBookDictionary.locationKey>();
		ApplePassBookDictionary.locationKey location = new ApplePassBookDictionary.locationKey();
		location.longitude = -122.3748889;
		location.latitude = 37.6189722;
		locations.add(location);
		pass.locations = locations;

		pass.logoText = 'Skyport Airways';
		pass.foregroundColor = 'rgb(22, 55, 110)';
		pass.backgroundColor = 'rgb(50, 91, 185)';

		List<ApplePassBookDictionary.fieldDictKey> headerFields = new List<ApplePassBookDictionary.fieldDictKey>();
		ApplePassBookDictionary.fieldDictKey field = new ApplePassBookDictionary.fieldDictKey();
		field.key = 'gate';
		field.label = 'GATE';
		field.value = '23';
		field.changeMessage = 'Gate changed to %@.';
		headerFields.add(field);

		List<ApplePassBookDictionary.fieldDictKey> primaryFields = new List<ApplePassBookDictionary.fieldDictKey>();
		field = new ApplePassBookDictionary.fieldDictKey();
		field.key = 'depart';
		field.label = 'SAN FRANCISCO';
		field.value = 'SFO';
		primaryFields.add(field);
		
		field = new ApplePassBookDictionary.fieldDictKey();
		field.key = 'arrive';
		field.label = 'NEW YORK';
		field.value = 'JFK';
		primaryFields.add(field);
		
		List<ApplePassBookDictionary.fieldDictKey> secondaryFields = new List<ApplePassBookDictionary.fieldDictKey>();
		field = new ApplePassBookDictionary.fieldDictKey();
		field.key = 'passenger';
		field.label = 'PASSENGER';
		field.value = 'John Appleseed';
		secondaryFields.add(field);

		List<ApplePassBookDictionary.fieldDictKey> auxiliaryFields = new List<ApplePassBookDictionary.fieldDictKey>();
		field = new ApplePassBookDictionary.fieldDictKey();
		field.key = 'boardingTime';
		field.label = 'DEPART';
		field.value = '2.25 PM';
		field.changeMessage = 'Gate changed to %@.';
		auxiliaryFields.add(field);
		
		field = new ApplePassBookDictionary.fieldDictKey();
		field.key = 'flightNewName';
		field.label = 'FLIGHT';
		field.value = '815';
		field.changeMessage = 'Flight number changed to %@';
		auxiliaryFields.add(field);
		
		field = new ApplePassBookDictionary.fieldDictKey();
		field.key = 'class';
		field.label = 'DESIG.';
		field.value = 'Coach';
		auxiliaryFields.add(field);
		
		field = new ApplePassBookDictionary.fieldDictKey();
		field.key = 'date';
		field.label = 'DATE';
		field.value = '7/22';
		auxiliaryFields.add(field);

		List<ApplePassBookDictionary.fieldDictKey> backFields = new List<ApplePassBookDictionary.fieldDictKey>();
		field = new ApplePassBookDictionary.fieldDictKey();
		field.key = 'passport';
		field.label = 'PASSPORT';
		field.value = 'Canadian/Canadien';
		backFields.add(field);
		
		field = new ApplePassBookDictionary.fieldDictKey();
		field.key = 'residence';
		field.label = 'RESIDENCE';
		field.value = '999 Infinite Loop, Apartment 42, Cupertino CA';
		backFields.add(field);

		pass.boardingPass = new ApplePassBookDictionary.passStructureKey();
		pass.boardingPass.transitType = 'PKTransitTypeAir';
		pass.boardingPass.headerFields = headerFields;
		pass.boardingPass.primaryFields = primaryFields;
		pass.boardingPass.secondaryFields = secondaryFields;
		pass.boardingPass.auxiliaryFields = auxiliaryFields;
		pass.boardingPass.backFields = backFields;


		return JSON.serialize(pass,true);
	}

	public String createCouponPass(Wallet_Setting__C ws){
		pass = getPassStandardFields(ws,pass);

		List<ApplePassBookDictionary.barcodeKey> barcodes = new List<ApplePassBookDictionary.barcodeKey>();
		ApplePassBookDictionary.barcodeKey barcode = new ApplePassBookDictionary.barcodeKey();
		barcode.message = '123456789';
		barcode.format = 'PKBarcodeFormatPDF417';
		barcode.messageEncoding = 'iso-8859-1';
		barcodes.add(barcode);
		pass.barcodes = barcodes;

		List<ApplePassBookDictionary.locationKey> locations = new List<ApplePassBookDictionary.locationKey>();
		ApplePassBookDictionary.locationKey location = new ApplePassBookDictionary.locationKey();
		location.longitude = -122.3748889;
		location.latitude = 37.6189722;
		locations.add(location);
		location = new ApplePassBookDictionary.locationKey();
		location.longitude = -122.03118;
		location.latitude = 37.33182;
		locations.add(location);
		pass.locations = locations;

		pass.logoText = 'Paw Planet';
		pass.foregroundColor = 'rgb(255, 255, 255)';
		pass.backgroundColor = 'rgb(206, 140, 53)';

		List<ApplePassBookDictionary.fieldDictKey> primaryFields = new List<ApplePassBookDictionary.fieldDictKey>();
		ApplePassBookDictionary.fieldDictKey field = new ApplePassBookDictionary.fieldDictKey();
		field.key = 'offer';
		field.label = 'Any premium dog food';
		field.value = '20% off';
		primaryFields.add(field);
		

		List<ApplePassBookDictionary.fieldDictKey> auxiliaryFields = new List<ApplePassBookDictionary.fieldDictKey>();
		field = new ApplePassBookDictionary.fieldDictKey();
		field.key = 'expires';
		field.label = 'EXPIRES';
		field.value = '2013-04-24T10:00-05:00';
		field.isRelative = true;
		field.dateStyle = 'PKDateStyleShort';
		auxiliaryFields.add(field);

		pass.coupon = new ApplePassBookDictionary.passStructureKey();
		pass.coupon.primaryFields = primaryFields;
		pass.coupon.auxiliaryFields = auxiliaryFields;

		return JSON.serialize(pass,true);
	}
}