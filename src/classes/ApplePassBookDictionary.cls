public with sharing class ApplePassBookDictionary {
		
		public String description {get;set;}
		public Integer formatVersion {get;set;}
		public String organizationName {get;set;}
		public String passTypeIdentifier {get;set;}
		public String serialNumber {get;set;}
		public String teamIdentifier {get;set;}
		public String appLaunchURL {get;set;}
		public List<Integer> associatedStoreIdentifiers {get;set;}
		public String userInfo {get;set;}
		public String expirationDate {get;set;}
		public Boolean voided {get;set;}
		public List<beaconKey> beacons {get;set;}
		public List<locationKey> locations {get;set;}
		public Integer maxDistance {get;set;}
		public String relevantDate {get;set;}
		public passStructureKey boardingPass {get;set;}
		public passStructureKey coupon {get;set;}
		public passStructureKey eventTicket {get;set;}
		public passStructureKey generic {get;set;}
		public passStructureKey storeCard {get;set;}
		public barcodeKey barcode {get;set;}
		public List<barcodeKey> barcodes {get;set;}
		public String backgroundColor {get;set;}
		public String foregroundColor {get;set;}
		public String groupingIdentifier {get;set;}
		public String labelColor {get;set;}
		public String logoText {get;set;}
		public Boolean suppressStripShine {get;set;}
		public String authenticationToken {get;set;}
		public String webServiceURL {get;set;}
		public nfcKey nfc {get;set;}	

	public ApplePassBookDictionary() {
		
	}

	public class fieldDictKey{
		public String attributedValue {get;set;}
		public String changeMessage {get;set;}
		public List<String> dataDetectorTypes {get;set;}
		public String key {get;set;}
		public String label {get;set;}
		public String textAlignment {get;set;}
		public String value {get;set;}
		public String dateStyle {get;set;}	
		public Boolean ignoresTimeZone {get;set;}	
		public Boolean isRelative {get;set;}	
		public Boolean timeStyle {get;set;}
		public String numberStyle {get;set;}
	}
	public class passStructureKey{
		public List<fieldDictKey> auxiliaryFields {get;set;}
		public List<fieldDictKey> backFields {get;set;}
		public List<fieldDictKey> headerFields {get;set;}
		public List<fieldDictKey> primaryFields {get;set;}
		public List<fieldDictKey> secondaryFields {get;set;}
		public String transitType {get;set;}
	}
	public class beaconKey{
		public Integer major {get;set;}
		public Integer minor {get;set;}
		public String proximityUUID {get;set;}
		public String relevantText {get;set;}
	}
	public class locationKey{
		public Double altitude {get;set;}
		public Double latitude {get;set;}
		public Double longitude {get;set;}
		public String relevantText {get;set;}
	}
	public class barcodeKey{
		public String altText {get;set;}
		public String format {get;set;}
		public String message {get;set;}
		public String messageEncoding {get;set;}
	}
	public class nfcKey{
		public String message {get;set;}
		public String encryptionPublicKey {get;set;}
	}

}