//
//  HTMLPurifier_ConfigSchema.m
//  HTMLPurifier
//
//  Created by Roman Priebe on 13.01.14.
//  Copyright (c) 2014 Mynigma. All rights reserved.
//

#import "HTMLPurifier_ConfigSchema.h"
//#import "XPathQuery.h"
#import <libxml/parser.h>
#import <libxml/tree.h>



//
//  XPathQuery.m
//  FuelFinder
//
//  Created by Matt Gallagher on 4/08/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

NSDictionary *DictionaryForNode(xmlNodePtr currentNode, NSMutableDictionary *parentResult)
{
	NSMutableDictionary *resultForNode = [NSMutableDictionary dictionary];

	if (currentNode->name)
	{
		NSString *currentNodeContent =
        [NSString stringWithCString:(const char *)currentNode->name encoding:NSUTF8StringEncoding];
		[resultForNode setObject:currentNodeContent forKey:@"nodeName"];
	}

	if (currentNode->content && currentNode->type != XML_DOCUMENT_TYPE_NODE)
	{
		NSString *currentNodeContent =
        [NSString stringWithCString:(const char *)currentNode->content encoding:NSUTF8StringEncoding];

		if ([[resultForNode objectForKey:@"nodeName"] isEqual:@"text"] && parentResult)
		{
			currentNodeContent = [currentNodeContent
                                  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

			NSString *existingContent = [parentResult objectForKey:@"nodeContent"];
			NSString *newContent;
			if (existingContent)
			{
				newContent = [existingContent stringByAppendingString:currentNodeContent];
			}
			else
			{
				newContent = currentNodeContent;
			}

			[parentResult setObject:newContent forKey:@"nodeContent"];
			return nil;
		}

		[resultForNode setObject:currentNodeContent forKey:@"nodeContent"];
	}

	xmlAttr *attribute = currentNode->properties;
	if (attribute)
	{
		NSMutableArray *attributeArray = [NSMutableArray array];
		while (attribute)
		{
			NSMutableDictionary *attributeDictionary = [NSMutableDictionary dictionary];
			NSString *attributeName =
            [NSString stringWithCString:(const char *)attribute->name encoding:NSUTF8StringEncoding];
			if (attributeName)
			{
				[attributeDictionary setObject:attributeName forKey:@"attributeName"];
			}

			if (attribute->children)
			{
				NSDictionary *childDictionary = DictionaryForNode(attribute->children, attributeDictionary);
				if (childDictionary)
				{
					[attributeDictionary setObject:childDictionary forKey:@"attributeContent"];
				}
			}

			if ([attributeDictionary count] > 0)
			{
				[attributeArray addObject:attributeDictionary];
			}
			attribute = attribute->next;
		}

		if ([attributeArray count] > 0)
		{
			[resultForNode setObject:attributeArray forKey:@"nodeAttributeArray"];
		}
	}

	xmlNodePtr childNode = currentNode->children;
	if (childNode)
	{
		NSMutableArray *childContentArray = [NSMutableArray array];
		while (childNode)
		{
			NSDictionary *childDictionary = DictionaryForNode(childNode, resultForNode);
			if (childDictionary)
			{
				[childContentArray addObject:childDictionary];
			}
			childNode = childNode->next;
		}
		if ([childContentArray count] > 0)
		{
			[resultForNode setObject:childContentArray forKey:@"nodeChildArray"];
		}
	}
	
	return resultForNode;
}

static HTMLPurifier_ConfigSchema* theSingleton;

@implementation HTMLPurifier_ConfigSchema

- (id)init
{
    if(theSingleton)
        return theSingleton;

    self = [super init];
    if (self) {
        _defaults = [NSMutableDictionary new];

        [self actuallyReadPlist];

        theSingleton = self;
    }
    return self;
}

- (void)actuallyReadPlist
{
    NSData* contents = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"]];
    if(!contents)
    {
        NSLog(@"Error opening config plist file!");
        return;
    }

    CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
    CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
    const char *enc = CFStringGetCStringPtr(cfencstr, 0);
    // _doc = htmlParseDoc((xmlChar*)[string UTF8String], enc);
    xmlDocPtr doc = xmlReadDoc ((xmlChar*)contents.bytes, NULL, enc, 0);

    NSDictionary* configDict = DictionaryForNode(&doc->children[0], nil);

    [self setDefaultPList:configDict[@"defaultPlist"]];
    [self setInfo:[configDict[@"info"] mutableCopy]];
    [self setDefaults:[configDict[@"defaults"] mutableCopy]];
}

+ (HTMLPurifier_ConfigSchema*)singleton
{
    return [HTMLPurifier_ConfigSchema new];
}

+ (HTMLPurifier_ConfigSchema*)makeFromSerial
{
    return [HTMLPurifier_ConfigSchema new];
}


@end
