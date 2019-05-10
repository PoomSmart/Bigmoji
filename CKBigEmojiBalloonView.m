#import "CKBigEmojiBalloonView.h"

@implementation CKBigEmojiBalloonView

- (UIEdgeInsets)alignmentRectInsets {
    return [[CKUIBehavior sharedBehaviors] bigEmojiAlignmentRectInsets];
}

- (void)setImage:(UIImage *)image {
    return;
}

- (void)setHasOverlay:(BOOL)overlay autoDismiss:(BOOL)autoDismiss {
    return;
}

- (void)setGradientReferenceView:(id)gradientReferenceView {
    return;
}

- (BOOL)modifiesSingleLineBalloonLayout {
    return NO;
}

- (BOOL)hasBackground {
    return NO;
}

@end
