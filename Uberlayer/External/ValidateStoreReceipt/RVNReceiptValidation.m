//
//  RVNReceiptValidation.m
//
//  Created by Satoshi Numata on 12/06/30.
//  Copyright (c) 2012 Sazameki and Satoshi Numata, Ph.D. All rights reserved.
//
//  This sample shows how to write the Mac App Store receipt validation code.
//  Replace kRVNBundleID and kRVNBundleVersion with your own ones.
//
//  This sample is provided because the coding sample found in "Validating Mac App Store Receipts"
//  is somehow out-of-date today and some functions are deprecated in Mac OS X 10.7.
//  (cf. Validating Mac App Store Receipts: )
//
//  You must want to make it much more robustness with some techniques, such as obfuscation
//  with your "own" way. If you use and share the same codes with your friends, attackers
//  will be able to make a special tool to patch application binaries so easily.
//  Again, this sample gives you the very basic idea that which APIs can be used for the validation.
//
//  Don't forget to add IOKit.framework and Security.framework to your project.
//  The main() function should be replaced with the (commented out) main() code at the bottom of this sample.
//  This sample assume that you are using Automatic Reference Counting for memory management.
//
//  Have a nice Cocoa flavor, guys!!
//

#import "RVNReceiptValidation.h"
// RVNReceiptValidation.h contains only one function declaration:
//     int RVNValidateAndRunApplication(int argc, char *argv[]);

#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonDigest.h>
#import <Security/CMSDecoder.h>
#import <Security/SecAsn1Coder.h>
#import <Security/SecAsn1Templates.h>
#import <Security/SecRequirement.h>

#import <IOKit/IOKitLib.h>


static NSString *kRVNBundleID = @"jp.sazameki.MyGreatApp";
static NSString *kRVNBundleVersion = @"1.0";


typedef struct {
    size_t          length;
    unsigned char   *data;
} ASN1_Data;

typedef struct {
    ASN1_Data type;     // INTEGER
    ASN1_Data version;  // INTEGER
    ASN1_Data value;    // OCTET STRING
} RVNReceiptAttribute;

typedef struct {
    RVNReceiptAttribute **attrs;
} RVNReceiptPayload;

// ASN.1 receipt attribute template
static const SecAsn1Template kReceiptAttributeTemplate[] = {
    { SEC_ASN1_SEQUENCE, 0, NULL, sizeof(RVNReceiptAttribute) },
    { SEC_ASN1_INTEGER, offsetof(RVNReceiptAttribute, type), NULL, 0 },
    { SEC_ASN1_INTEGER, offsetof(RVNReceiptAttribute, version), NULL, 0 },
    { SEC_ASN1_OCTET_STRING, offsetof(RVNReceiptAttribute, value), NULL, 0 },
    { 0, 0, NULL, 0 }
};

// ASN.1 receipt template set
static const SecAsn1Template kSetOfReceiptAttributeTemplate[] = {
    { SEC_ASN1_SET_OF, 0, kReceiptAttributeTemplate, sizeof(RVNReceiptPayload) },
    { 0, 0, NULL, 0 }
};


enum {
    kRVNReceiptAttributeTypeBundleID                = 2,
    kRVNReceiptAttributeTypeApplicationVersion      = 3,
    kRVNReceiptAttributeTypeOpaqueValue             = 4,
    kRVNReceiptAttributeTypeSHA1Hash                = 5,
    kRVNReceiptAttributeTypeInAppPurchaseReceipt    = 17,
    
    kRVNReceiptAttributeTypeInAppQuantity               = 1701,
    kRVNReceiptAttributeTypeInAppProductID              = 1702,
    kRVNReceiptAttributeTypeInAppTransactionID          = 1703,
    kRVNReceiptAttributeTypeInAppPurchaseDate           = 1704,
    kRVNReceiptAttributeTypeInAppOriginalTransactionID  = 1705,
    kRVNReceiptAttributeTypeInAppOriginalPurchaseDate   = 1706,
};


static NSString *kRVNReceiptInfoKeyBundleID                     = @"Bundle ID";
static NSString *kRVNReceiptInfoKeyBundleIDData                 = @"Bundle ID Data";
static NSString *kRVNReceiptInfoKeyApplicationVersion           = @"Application Version";
static NSString *kRVNReceiptInfoKeyApplicationVersionData       = @"Application Version Data";
static NSString *kRVNReceiptInfoKeyOpaqueValue                  = @"Opaque Value";
static NSString *kRVNReceiptInfoKeySHA1Hash                     = @"SHA-1 Hash";
static NSString *kRVNReceiptInfoKeyInAppPurchaseReceipt         = @"In App Purchase Receipt";

static NSString *kRVNReceiptInfoKeyInAppProductID               = @"In App Product ID";
static NSString *kRVNReceiptInfoKeyInAppTransactionID           = @"In App Transaction ID";
static NSString *kRVNReceiptInfoKeyInAppOriginalTransactionID   = @"In App Original Transaction ID";
static NSString *kRVNReceiptInfoKeyInAppPurchaseDate            = @"In App Purchase Date";
static NSString *kRVNReceiptInfoKeyInAppOriginalPurchaseDate    = @"In App Original Purchase Date";
static NSString *kRVNReceiptInfoKeyInAppQuantity                = @"In App Quantity";


inline static void RVNCheckBundleIDAndVersion(void)
{
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    
    NSString *bundleID = [bundleInfo valueForKey:@"CFBundleIdentifier"];
    if (![bundleID isEqualToString:kRVNBundleID]) {
        [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to check bundle ID.", nil];
    }
    
    NSString *bundleVersion = [bundleInfo valueForKey:@"CFBundleShortVersionString"];
    if (![bundleVersion isEqualToString:kRVNBundleVersion]) {
        [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to check bundle Version.", nil];
    }
}

inline static void RVNCheckBundleSignature(void)
{
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    
    SecStaticCodeRef staticCode = NULL;
    OSStatus status = SecStaticCodeCreateWithPath((__bridge CFURLRef)bundleURL, kSecCSDefaultFlags, &staticCode);
    if (status != errSecSuccess) {
        [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to validate bundle signature: Create a static code", nil];
    }
    
    NSString *requirementText = @"anchor apple generic";   // For code signed by Apple
    
    SecRequirementRef requirement = NULL;
    status = SecRequirementCreateWithString((__bridge CFStringRef)requirementText, kSecCSDefaultFlags, &requirement);
    if (status != errSecSuccess) {
        if (staticCode) CFRelease(staticCode);
        [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to validate bundle signature: Create a requirement", nil];
    }
    
    status = SecStaticCodeCheckValidity(staticCode, kSecCSDefaultFlags, requirement);
    if (status != errSecSuccess) {
        if (staticCode) CFRelease(staticCode);
        if (requirement) CFRelease(requirement);
        [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to validate bundle signature: Check the static code validity", nil];
    }
    
    if (staticCode) CFRelease(staticCode);
    if (requirement) CFRelease(requirement);
}

inline static NSData *RVNGetReceiptData(void)
{
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    if (!receiptData) {
        [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to fetch the MacAppStore receipt.", nil];
    }
    return receiptData;
}

inline static NSData *RVNDecodeReceiptData(NSData *receiptData)
{
    CMSDecoderRef decoder = NULL;
    SecPolicyRef policyRef = NULL;
    SecTrustRef trustRef = NULL;
    
    @try {
        // Create a decoder
        OSStatus status = CMSDecoderCreate(&decoder);
        if (status) {
            [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to decode receipt data: Create a decoder", nil];
        }
        
        // Decrypt the message (1)
        status = CMSDecoderUpdateMessage(decoder, receiptData.bytes, receiptData.length);
        if (status) {
            [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to decode receipt data: Update message", nil];
        }
        
        // Decrypt the message (2)
        status = CMSDecoderFinalizeMessage(decoder);
        if (status) {
            [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to decode receipt data: Finalize message", nil];
        }
        
        // Get the decrypted content
        NSData *ret = nil;
        CFDataRef dataRef = NULL;
        status = CMSDecoderCopyContent(decoder, &dataRef);
        if (status) {
            [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to decode receipt data: Get decrypted content", nil];
        }
        ret = [NSData dataWithData:(__bridge NSData *)dataRef];
        CFRelease(dataRef);
        
        // Check the signature
        size_t numSigners;
        status = CMSDecoderGetNumSigners(decoder, &numSigners);
        if (status) {
            [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to check receipt signature: Get singer count", nil];
        }
        if (numSigners == 0) {
            [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to check receipt signature: No signer found", nil];
        }
        
        policyRef = SecPolicyCreateBasicX509();
        
        CMSSignerStatus signerStatus;
        OSStatus certVerifyResult;
        status = CMSDecoderCopySignerStatus(decoder, 0, policyRef, TRUE, &signerStatus, &trustRef, &certVerifyResult);
        if (status) {
            [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to check receipt signature: Get signer status", nil];
        }
        if (signerStatus != kCMSSignerValid) {
            [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to check receipt signature: No valid signer", nil];
        }
        
        return ret;
    } @catch (NSException *e) {
        @throw e;
    } @finally {
        if (policyRef) CFRelease(policyRef);
        if (trustRef) CFRelease(trustRef);
        if (decoder) CFRelease(decoder);
    }
}

inline static NSData *RVNGetASN1RawData(ASN1_Data asn1Data)
{
    return [NSData dataWithBytes:asn1Data.data length:asn1Data.length];
}

inline static int RVNGetIntValueFromASN1Data(const ASN1_Data *asn1Data)
{
    int ret = 0;
    for (int i = 0; i < asn1Data->length; i++) {
        ret = (ret << 8) | asn1Data->data[i];
    }
    return ret;
}

inline static NSNumber *RVNDecodeIntNumberFromASN1Data(SecAsn1CoderRef decoder, ASN1_Data srcData)
{
    ASN1_Data asn1Data;
    OSStatus status = SecAsn1Decode(decoder, srcData.data, srcData.length, kSecAsn1IntegerTemplate, &asn1Data);
    if (status) {
        [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to get receipt information: Decode integer value", nil];
    }
    return [NSNumber numberWithInt:RVNGetIntValueFromASN1Data(&asn1Data)];
}

inline static NSString *RVNDecodeUTF8StringFromASN1Data(SecAsn1CoderRef decoder, ASN1_Data srcData)
{
    ASN1_Data asn1Data;
    OSStatus status = SecAsn1Decode(decoder, srcData.data, srcData.length, kSecAsn1UTF8StringTemplate, &asn1Data);
    if (status) {
        [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to get receipt information: Decode UTF-8 string", nil];
    }
    return [[NSString alloc] initWithBytes:asn1Data.data length:asn1Data.length encoding:NSUTF8StringEncoding];
}

inline static NSDate *RVNDecodeDateFromASN1Data(SecAsn1CoderRef decoder, ASN1_Data srcData)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-ddTHH:mm:ssZ"];
    
    ASN1_Data asn1Data;
    OSStatus status = SecAsn1Decode(decoder, srcData.data, srcData.length, kSecAsn1IA5StringTemplate, &asn1Data);
    if (status) {
        [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to get receipt information: Decode date (IA5 string)", nil];
    }
    
    NSString *dateStr = [[NSString alloc] initWithBytes:asn1Data.data length:asn1Data.length encoding:NSASCIIStringEncoding];
    return [dateFormatter dateFromString:dateStr];
}

inline static NSDictionary *RVNGetReceiptPayload(NSData *payloadData)
{
    SecAsn1CoderRef asn1Decoder = NULL;
    
    @try {
        NSMutableDictionary *ret = [NSMutableDictionary dictionary];
        
        // Create the ASN.1 parser
        OSStatus status = SecAsn1CoderCreate(&asn1Decoder);
        if (status) {
            [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to get receipt information: Create ASN.1 decoder", nil];
        }
        
        // Decode the receipt payload
        RVNReceiptPayload payload = { NULL };
        status = SecAsn1Decode(asn1Decoder, payloadData.bytes, payloadData.length, kSetOfReceiptAttributeTemplate, &payload);
        if (status) {
            [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to get receipt information: Decode payload", nil];
        }
        
        // Fetch all attributes
        RVNReceiptAttribute *anAttr;
        for (int i = 0; (anAttr = payload.attrs[i]); i++) {
            int type = RVNGetIntValueFromASN1Data(&anAttr->type);
            switch (type) {
                    // UTF-8 String
                case kRVNReceiptAttributeTypeBundleID:
                    [ret setValue:RVNDecodeUTF8StringFromASN1Data(asn1Decoder, anAttr->value) forKey:kRVNReceiptInfoKeyBundleID];
                    [ret setValue:RVNGetASN1RawData(anAttr->value) forKey:kRVNReceiptInfoKeyBundleIDData];
                    break;
                case kRVNReceiptAttributeTypeApplicationVersion:
                    [ret setValue:RVNDecodeUTF8StringFromASN1Data(asn1Decoder, anAttr->value) forKey:kRVNReceiptInfoKeyApplicationVersion];
                    [ret setValue:RVNGetASN1RawData(anAttr->value) forKey:kRVNReceiptInfoKeyApplicationVersionData];
                    break;
                case kRVNReceiptAttributeTypeInAppProductID:
                    [ret setValue:RVNDecodeUTF8StringFromASN1Data(asn1Decoder, anAttr->value) forKey:kRVNReceiptInfoKeyInAppProductID];
                    break;
                case kRVNReceiptAttributeTypeInAppTransactionID:
                    [ret setValue:RVNDecodeUTF8StringFromASN1Data(asn1Decoder, anAttr->value) forKey:kRVNReceiptInfoKeyInAppTransactionID];
                    break;
                case kRVNReceiptAttributeTypeInAppOriginalTransactionID:
                    [ret setValue:RVNDecodeUTF8StringFromASN1Data(asn1Decoder, anAttr->value) forKey:kRVNReceiptInfoKeyInAppOriginalTransactionID];
                    break;
                    
                    // Purchase Date (As IA5 String (almost identical to the ASCII String))
                case kRVNReceiptAttributeTypeInAppPurchaseDate:
                    [ret setValue:RVNDecodeDateFromASN1Data(asn1Decoder, anAttr->value) forKey:kRVNReceiptInfoKeyInAppPurchaseDate];
                    break;
                case kRVNReceiptAttributeTypeInAppOriginalPurchaseDate:
                    [ret setValue:RVNDecodeDateFromASN1Data(asn1Decoder, anAttr->value) forKey:kRVNReceiptInfoKeyInAppOriginalPurchaseDate];
                    break;
                    
                    // Quantity (Integer Value)
                case kRVNReceiptAttributeTypeInAppQuantity:
                    [ret setValue:RVNDecodeIntNumberFromASN1Data(asn1Decoder, anAttr->value)
                           forKey:kRVNReceiptInfoKeyInAppQuantity];
                    break;
                    
                    // Opaque Value (Octet Data)
                case kRVNReceiptAttributeTypeOpaqueValue:
                    [ret setValue:RVNGetASN1RawData(anAttr->value) forKey:kRVNReceiptInfoKeyOpaqueValue];
                    break;
                    
                    // SHA-1 Hash (Octet Data)
                case kRVNReceiptAttributeTypeSHA1Hash:
                    [ret setValue:RVNGetASN1RawData(anAttr->value) forKey:kRVNReceiptInfoKeySHA1Hash];
                    break;
                    
                    // In App Purchases Receipt
                case kRVNReceiptAttributeTypeInAppPurchaseReceipt: {
                    NSMutableArray *inAppPurchases = [ret valueForKey:kRVNReceiptInfoKeyInAppPurchaseReceipt];
                    if (!inAppPurchases) {
                        inAppPurchases = [NSMutableArray array];
                        [ret setValue:inAppPurchases forKey:kRVNReceiptInfoKeyInAppPurchaseReceipt];
                    }
                    NSData *inAppData = [NSData dataWithBytes:anAttr->value.data length:anAttr->value.length];
                    NSDictionary *inAppInfo = RVNGetReceiptPayload(inAppData);
                    [inAppPurchases addObject:inAppInfo];
                    break;
                }
                    
                    // Otherwise
                default:
                    break;
            }
        }
        return ret;
    } @catch (NSException *e) {
        @throw e;
    } @finally {
        if (asn1Decoder) SecAsn1CoderRelease(asn1Decoder);
    }
}

inline static NSData *RVLGetMacAddress(void)
{
    mach_port_t masterPort;
    kern_return_t result = IOMasterPort(MACH_PORT_NULL, &masterPort);
    if (result != KERN_SUCCESS) {
        return nil;
    }
    
    CFMutableDictionaryRef matchingDict = IOBSDNameMatching(masterPort, 0, "en0");
    if (!matchingDict) {
        return nil;
    }
    
    io_iterator_t iterator;
    result = IOServiceGetMatchingServices(masterPort, matchingDict, &iterator);
    if (result != KERN_SUCCESS) {
        return nil;
    }
    
    CFDataRef macAddressDataRef = nil;
    io_object_t aService;
    while ((aService = IOIteratorNext(iterator)) != 0) {
        io_object_t parentService;
        result = IORegistryEntryGetParentEntry(aService, kIOServicePlane, &parentService);
        if (result == KERN_SUCCESS) {
            if (macAddressDataRef) CFRelease(macAddressDataRef);
            macAddressDataRef = (CFDataRef)IORegistryEntryCreateCFProperty(parentService, (CFStringRef)@"IOMACAddress", kCFAllocatorDefault, 0);
            IOObjectRelease(parentService);
        }
        IOObjectRelease(aService);
    }
    IOObjectRelease(iterator);
    
    NSData *ret = nil;
    if (macAddressDataRef) {
        ret = [NSData dataWithData:(__bridge NSData *)macAddressDataRef];
        CFRelease(macAddressDataRef);
    }
    return ret;
}

inline static void RVNCheckReceiptIDAndVersion(NSDictionary *receiptInfo)
{
    NSString *bundleID = [receiptInfo valueForKey:kRVNReceiptInfoKeyBundleID];
    if (![bundleID isEqualToString:kRVNBundleID]) {
        [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to check receipt ID.", nil];
    }
    
    NSString *bundleVersion = [receiptInfo objectForKey:kRVNReceiptInfoKeyApplicationVersion];
    if (![bundleVersion isEqualToString:kRVNBundleVersion]) {
        [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to check receipt version.", nil];
    }
}

inline static void RVNCheckReceiptHash(NSDictionary *receiptInfo)
{
    NSData *macAddressData = RVLGetMacAddress();
    if (!macAddressData) {
        [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to get the primary MAC Address for checking receipt hash.", nil];
    }
    NSData *data1 = [receiptInfo valueForKey:kRVNReceiptInfoKeyOpaqueValue];
    NSData *data2 = [receiptInfo valueForKey:kRVNReceiptInfoKeyBundleIDData];
    
    NSMutableData *digestData = [NSMutableData dataWithData:macAddressData];
    [digestData appendData:data1];
    [digestData appendData:data2];
    
    unsigned char digestBuffer[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(digestData.bytes, (CC_LONG)digestData.length, digestBuffer);
    
    NSData *hashData = [receiptInfo valueForKey:kRVNReceiptInfoKeySHA1Hash];
    if (memcmp(digestBuffer, hashData.bytes, CC_SHA1_DIGEST_LENGTH) != 0) {
        [NSException raise:@"MacAppStore Receipt Validation Error" format:@"Failed to check receipt hash.", nil];
    }
}

int RVNValidateAndRunApplication(int argc, char *argv[])
{
    @try {
        ///// Check the bundle information
        RVNCheckBundleIDAndVersion();
        RVNCheckBundleSignature();
        
        ///// Check the receipt information
        NSData *receiptData = RVNGetReceiptData();
        NSData *receiptDataDecoded = RVNDecodeReceiptData(receiptData);
        NSDictionary *receiptInfo = RVNGetReceiptPayload(receiptDataDecoded);
#if DEBUG
        NSLog(@"receiptInfo=%@", receiptInfo);
#endif
        
        RVNCheckReceiptIDAndVersion(receiptInfo);
        RVNCheckReceiptHash(receiptInfo);
        
        return NSApplicationMain(argc, (const char **)argv);
    } @catch (NSException *e) {
        NSLog(@"%@", e.reason);
        exit(173);
    }
}


//int main(int argc, char *argv[])
//{
//    @autoreleasepool {
//        return RVNValidateAndRunApplication(argc, argv);
//    }
//}