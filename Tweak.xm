#import "../PS.h"
#import "Header.h"
#import "CKBigEmojiBalloonView.h"
#import "NSString+CKBigEmoji.h"

UIEdgeInsets bigEmojiInsets = UIEdgeInsetsMake(11, 0, 12, 0);
BOOL overrideBehavior = NO;

%hook CKUIBehavior

- (_Bool)modifiesSingleLineBalloonLayout
{
	return overrideBehavior ? NO : %orig;
}

%new
- (UIEdgeInsets)bigEmojiAlignmentRectInsets
{
	return bigEmojiInsets;
}

%new
- (UIFont *)bigEmojiFont
{
	return [UIFont systemFontOfSize:48.0];
}

%end

%hook CKTextMessagePartChatItem

- (Class)balloonViewClass
{
	if ([self shouldUseBigEmoji])
		return [CKBigEmojiBalloonView class];
	return %orig;
}

%new
- (_Bool)shouldUseBigEmoji
{
	if ([self subject].length)
		return NO;
	return [[self text].string __ck_shouldUseBigEmoji];
}

- (NSMutableAttributedString *)loadTranscriptText
{
	NSMutableAttributedString *m_attrString = %orig;
	if ([self shouldUseBigEmoji] && self.text.length) {
		UIFont *emojiFont = [[[CKUIBehavior sharedBehaviors] bigEmojiFont] retain];
		[m_attrString addAttribute:NSFontAttributeName value:emojiFont range:NSMakeRange(0, m_attrString.length)];
		[emojiFont release];
	}
	return m_attrString;
}

%end

%hook CKColoredBalloonView

%new
- (_Bool)hasBackground
{
	return YES;
}

%end

%hook CKTextBalloonView

- (CGSize)sizeThatFits:(CGSize)size textAlignmentInsets:(UIEdgeInsets)insets
{
	overrideBehavior = ![self hasBackground];
	CGSize fitSize = %orig;
	if (overrideBehavior)
		fitSize.width += 4;
	overrideBehavior = NO;
	return fitSize;
}

%end

%hook CKMessageEntryContentView

- (void)textViewDidChange:(CKMessageEntryTextView *)textView
{
	if (!self.shouldShowSubject)
		[textView updateFontIfNeeded];
	%orig;
}

%end

%hook CKMessageEntryTextView

%new
- (void)updateFontIfNeeded
{
	self.font = [self.text __ck_shouldUseBigEmoji] ? [[CKUIBehavior sharedBehaviors] bigEmojiFont] : [[CKUIBehavior sharedBehaviors] balloonTextFont];
}

%end