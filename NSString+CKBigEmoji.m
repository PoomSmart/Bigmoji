#import "NSString+CKBigEmoji.h"

#define MAX_BIG_EMOJI_COUNT 3

extern NSString *IMAttachmentCharacterString;

@implementation NSString (CKBigEmoji)

- (BOOL)__ck_isEmoji
{
	NSCharacterSet *VariationSelectors = [[NSCharacterSet characterSetWithRange:NSMakeRange(0xFE00, 16)] retain];
	BOOL variant = [self rangeOfCharacterFromSet:VariationSelectors].location != NSNotFound;
	[VariationSelectors release];
	if (variant)
		return YES; 
	const unichar high = [self characterAtIndex:0];
	if (0xD800 <= high && high <= 0xDBFF) {
		const unichar low = [self characterAtIndex:1];
		const int codepoint = ((high - 0xD800) * 0x400) + (low - 0xDC00) + 0x10000;
		return (0x1D000 <= codepoint && codepoint <= 0x1F77F) || (0x1F900 <= codepoint && codepoint <= 0x1F9FF);
	}
	return (0x2100 <= high && high <= 0x27BF);
}

- (BOOL)__ck_shouldUseBigEmoji
{
	NSCharacterSet *whiteSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] retain];
	int __block emojiCount = 0;
	[self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences
		usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
			if ([substring __ck_isEmoji]) {
				emojiCount++;
				if (emojiCount > MAX_BIG_EMOJI_COUNT) {
					emojiCount = 0;
					*stop = YES;
				}
			} else {
				NSString *trimmed = [[[substring stringByTrimmingCharactersInSet:whiteSet] retain] autorelease];
				if (trimmed.length) {
					if (![trimmed isEqualToString:IMAttachmentCharacterString]) {
						emojiCount = 0;
						*stop = YES;
					}
				}
			}
	}];
	[whiteSet release];
	return emojiCount && emojiCount <= MAX_BIG_EMOJI_COUNT;
}

@end