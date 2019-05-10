#import <UIKit/UIKit.h>

@interface CKUIBehavior : NSObject
+ (CKUIBehavior *)sharedBehaviors;
- (BOOL)modifiesSingleLineBalloonLayout;
- (UIFont *)balloonTextFont;
@end

@interface CKLazyTextView : UIView
@property(retain, nonatomic) UIFont *font;
@property(retain, nonatomic) NSAttributedString *attributedText;
@end

@interface CKTiledTextView : CKLazyTextView
@end

@interface CKBalloonImageView : UIView
@property(retain, nonatomic) UIImage *image;
@end

@interface CKBalloonView : CKBalloonImageView
- (void)setHasOverlay:(BOOL)overlay autoDismiss:(BOOL)autoDismiss;
@end

@interface CKColoredBalloonView : CKBalloonView
@property BOOL wantsGradient;
- (void)setGradientReferenceView:(id)gradientReferenceView;
@end

@interface CKTextBalloonView : CKColoredBalloonView
@property(retain, nonatomic) NSAttributedString *attributedText;
@end

@interface _CKTextBalloonView : CKColoredBalloonView
@property(retain, nonatomic) CKTiledTextView *textView;
@property(retain, nonatomic) NSAttributedString *attributedText;
@end

@interface CKChatItem : NSObject
@property CGFloat maxWidth;
- (NSString *)transcriptText;
- (void)loadTranscriptText;
@end

@interface CKBalloonChatItem : CKChatItem
- (void)configureBalloonView:(id)arg1;
@end

@interface CKMessagePartChatItem : CKBalloonChatItem
- (NSAttributedString *)text;
- (NSString *)message;
@end

@interface CKTextMessagePartChatItem : CKMessagePartChatItem
- (NSMutableAttributedString *)loadTranscriptText;
- (NSAttributedString *)subject;
@end

@interface CKTextMessagePart : NSObject
- (NSAttributedString *)text;
@end

@interface CKMessageEntryView : UIView
@property BOOL shouldShowSubject;
@end

@interface CKMessageEntryContentView : UIView
@property BOOL shouldShowSubject;
@end

@interface CKMessageEntryTextView : UITextView
@end

@interface CKMessageEntryRichTextView : CKMessageEntryTextView
@end

@interface CKTextContentView : UITextView
@end

@interface CKContentEntryView : UIScrollView {
    NSString *_defaultText;
}
@property BOOL showsSubject;
@end

@interface CKUIBehavior (Addition)
- (UIEdgeInsets)bigEmojiAlignmentRectInsets;
- (UIFont *)bigEmojiFont;
@end

@interface CKColoredBalloonView (Addition)
- (BOOL)hasBackground;
@end

@interface CKTextBalloonView (Addition)
- (BOOL)modifiesSingleLineBalloonLayout;
@end

@interface CKTextMessagePartChatItem (Addition)
- (BOOL)shouldUseBigEmoji;
@end

@interface CKTextMessagePart (Addition)
- (BOOL)shouldUseBigEmoji;
@end

@interface CKMessageEntryTextView (Addition)
- (void)updateFontIfNeeded;
@end

@interface CKTextContentView (Addition)
- (void)updateFontIfNeeded;
@end
