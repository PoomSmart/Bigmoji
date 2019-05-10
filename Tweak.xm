#import "../PS.h"
#import "Header.h"
#import "CKBigEmojiBalloonView.h"
#import "NSString+CKBigEmoji.h"

CGFloat EMOJI_SIZE, SHIFT;

UIEdgeInsets bigEmojiInsets = UIEdgeInsetsMake(11.0, 0.0, 12.0, 0.0);
BOOL overrideBehavior = NO;

CKTextBalloonView *(*__CKTextBalloonViewForMessagePart)(CKTextMessagePart *, NSString *);
CKTextBalloonView *(*__CKBalloonViewForClass)(Class);

%group iOS7Up

%hook CKUIBehavior

- (BOOL)modifiesSingleLineBalloonLayout {
    return overrideBehavior ? NO : %orig;
}

%end

%hook CKTextMessagePartChatItem

- (Class)balloonViewClass {
    if ([self shouldUseBigEmoji])
        return [CKBigEmojiBalloonView class];
    return %orig;
}

%new
- (BOOL)shouldUseBigEmoji {
    if ([self subject].length)
        return NO;
    return [[self text].string __ck_shouldUseBigEmoji];
}

- (NSMutableAttributedString *)loadTranscriptText {
    NSMutableAttributedString *m_attrString = %orig;
    if ([self shouldUseBigEmoji] && self.text.length) {
        UIFont *emojiFont = [[[CKUIBehavior sharedBehaviors] bigEmojiFont] retain];
        [m_attrString addAttribute:NSFontAttributeName value:emojiFont range:NSMakeRange(0, m_attrString.length)];
        [emojiFont release];
    }
    return m_attrString;
}

%end

%hook CKTextBalloonView

- (CGSize)sizeThatFits:(CGSize)size textAlignmentInsets:(UIEdgeInsets)insets {
    overrideBehavior = ![self hasBackground];
    CGSize fitSize = %orig;
    if (overrideBehavior)
        fitSize.width += 4.0;
    overrideBehavior = NO;
    return fitSize;
}

%end

%hook CKMessageEntryContentView

- (void)textViewDidChange:(CKMessageEntryTextView *)textView {
    if (!self.shouldShowSubject)
        [textView updateFontIfNeeded];
    %orig;
}

%end

%hook CKMessageEntryTextView

%new
- (void)updateFontIfNeeded {
    self.font = [self.text __ck_shouldUseBigEmoji] ? [[CKUIBehavior sharedBehaviors] bigEmojiFont] : [[CKUIBehavior sharedBehaviors] balloonTextFont];
}

%end

%end

%group preiOS7

%hook CKUIBehavior

- (CGFloat)balloonTextLineHeight {
    return overrideBehavior ? EMOJI_SIZE + 4.0 : %orig;
}

%end

%hook CKTextBalloonView

- (CGSize)sizeThatFits:(CGSize)size {
    return ![self hasBackground] ? CGSizeMake(EMOJI_SIZE + SHIFT, EMOJI_SIZE + 9.5) : %orig;
}

%end

%hook _CKTextBalloonView

- (void)updateFontSize {
    self.textView.font = [self.textView.attributedText.string __ck_shouldUseBigEmoji] ? [[CKUIBehavior sharedBehaviors] bigEmojiFont] : [[CKUIBehavior sharedBehaviors] balloonTextFont];
    HBLogDebug(@"%f", self.textView.font.pointSize);
    [self setNeedsLayout];
}

%end

%hook CKContentEntryView

- (unsigned)displayedLines {
    overrideBehavior = [MSHookIvar<NSString *>(self, "_defaultText")__ck_shouldUseBigEmoji];
    unsigned lines = %orig;
    overrideBehavior = NO;
    return lines;
}

- (void)_loadEntryViews {
    overrideBehavior = [MSHookIvar<NSString *>(self, "_defaultText")__ck_shouldUseBigEmoji];
    %orig;
    overrideBehavior = NO;
}

- (void)textContentViewDidChange:(CKTextContentView *)textView {
    if (!self.showsSubject)
        [textView updateFontIfNeeded];
    %orig;
}

%end

%hook CKTextContentView

%new
- (void)updateFontIfNeeded {
    self.font = [self.text __ck_shouldUseBigEmoji] ? [[CKUIBehavior sharedBehaviors] bigEmojiFont] : [[CKUIBehavior sharedBehaviors] balloonTextFont];
}

- (void)_updateFontSize {
    [self updateFontIfNeeded];
}

- (void)_updateDefaultText {
    %orig;
    MSHookIvar<UILabel *>(self, "_defaultTextView").font = [self.text __ck_shouldUseBigEmoji] ? [[CKUIBehavior sharedBehaviors] bigEmojiFont] : [[CKUIBehavior sharedBehaviors] balloonTextFont];
}

/*- (void)_adjustForSingleLineHeightIfNecessary {
    overrideBehavior = [self.text __ck_shouldUseBigEmoji];
    %orig;
    overrideBehavior = NO;
   }*/

- (void)_wvSetupCSSWithMargins:(UIEdgeInsets)margin {
    overrideBehavior = [self.text __ck_shouldUseBigEmoji];
    %orig;
    overrideBehavior = NO;
}

- (CGRect)_defaultTextFrame {
    overrideBehavior = [self.text __ck_shouldUseBigEmoji];
    CGRect frame = %orig;
    overrideBehavior = NO;
    return frame;
}

%end

%hook CKTextMessagePart

%new
- (BOOL)shouldUseBigEmoji {
    return [[self text].string __ck_shouldUseBigEmoji];
}

%end

%hookf(CKTextBalloonView *, __CKTextBalloonViewForMessagePart, CKTextMessagePart *messagePart, NSString *subject) {
    if ([messagePart shouldUseBigEmoji]) {
        CKBigEmojiBalloonView *bigEmojiBalloonView = (CKBigEmojiBalloonView *)__CKBalloonViewForClass([CKBigEmojiBalloonView class]);
        NSMutableAttributedString *mutableAttributedText = [[[NSMutableAttributedString alloc] initWithAttributedString:messagePart.text] autorelease];
        UIFont *emojiFont = [[[CKUIBehavior sharedBehaviors] bigEmojiFont] retain];
        [mutableAttributedText addAttribute:NSFontAttributeName value:emojiFont range:NSMakeRange(0, mutableAttributedText.length)];
        [emojiFont release];
        bigEmojiBalloonView.attributedText = mutableAttributedText;
        return bigEmojiBalloonView;
    }
    return %orig;
}

%end

%hook CKColoredBalloonView

%new
- (BOOL)hasBackground {
    return YES;
}

%end

%hook CKUIBehavior

%new
- (UIEdgeInsets)bigEmojiAlignmentRectInsets {
    return bigEmojiInsets;
}

%new
- (UIFont *)bigEmojiFont {
    return [UIFont systemFontOfSize:EMOJI_SIZE];
}

%end

%ctor {
    EMOJI_SIZE = 48.0;
    SHIFT = 4.0;
    if (isiOS7Up) {
        %init(iOS7Up);
    } else {
        MSImageRef ref = MSGetImageByName("/System/Library/PrivateFrameworks/ChatKit.framework/ChatKit");
        __CKTextBalloonViewForMessagePart = (CKTextBalloonView *(*)(CKTextMessagePart *, NSString *))MSFindSymbol(ref, "__CKTextBalloonViewForMessagePart");
        __CKBalloonViewForClass = (CKTextBalloonView *(*)(Class))MSFindSymbol(ref, "__CKBalloonViewForClass");
        %init(preiOS7);
    }
    %init;
}
