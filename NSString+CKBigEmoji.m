#import "NSString+CKBigEmoji.h"

#define MAX_BIG_EMOJI_COUNT 3

extern NSString *IMAttachmentCharacterString;

@implementation NSString (CKBigEmoji)

- (BOOL)__ck_isEmoji {
    return [self _containsEmoji];
}

- (BOOL)__ck_shouldUseBigEmoji {
    NSCharacterSet *whiteSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] retain];
    int __block emojiCount = 0;
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        if ([substring __ck_isEmoji]) {
            if (++emojiCount > MAX_BIG_EMOJI_COUNT) {
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