//
//  LRTextField.m
//  LRTextField
//
//  Created by Chao on 7/26/15.
//  Copyright (c) 2015 Chao. All rights reserved.
//

#import "LRTextField.h"

#define fontScale 0.7f

@interface LRTextField ()

@property (nonatomic, assign) LRTextFieldFormatType type;
@property (nonatomic, assign) LRTextFieldEffectStyle style;
@property (nonatomic, assign) LRTextFieldValidationType validationType;

@property (nonatomic, assign) CGFloat Ypadding;
@property (nonatomic, assign) CGFloat Xpadding;
@property (nonatomic, assign) UIFont *placeholderFont;
@property (nonatomic, assign) CGRect validationFrame;
@property (nonatomic, strong) validationBlock validateBlock;
@end

@implementation LRTextField

- (instancetype) init
{
    self = [self initWithFrame:CGRectZero];
    [self commonInit];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if ( !self )
    {
        return nil;
    }
    _style = LRTextFieldEffectStyleUp;
    [self commonInit];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self commonInit];
    return self;
}

// An common init function
- (instancetype) initWithFormatType:(LRTextFieldFormatType)type
{
    return [self initWithFormatType:type effectStyle:LRTextFieldEffectStyleUp validationType:LRTextFieldValidationTypeNone];
}

- (instancetype) initWithEffectStyle:(LRTextFieldEffectStyle)style
{
    return [self initWithFormatType:LRTextFieldFormatTypeNone effectStyle:style validationType:LRTextFieldValidationTypeNone];
}

- (instancetype) initWithValidationType:(LRTextFieldValidationType)validationType
{
    return [self initWithFormatType:LRTextFieldFormatTypeNone effectStyle:LRTextFieldEffectStyleNone validationType:validationType];
}

- (instancetype) initWithFormatType:(LRTextFieldFormatType)type effectStyle:(LRTextFieldEffectStyle)style validationType:(LRTextFieldValidationType)validationType
{
    self = [super initWithFrame:CGRectZero];
    if ( !self )
    {
        return nil;
    }
    
    _type = type;
    _style = style;
    _validationType = validationType;
    [self commonInit];
    
    return self;
}

- (void) placeholderInit
{
    self.placeholderLabel = [UILabel new];
    self.placeholderLabel.text = self.placeholder;
    self.placeholderLabel.alpha = 0.0f;
    self.placeholderColor = [UIColor grayColor];
    self.placeholderLabel.textColor = self.placeholderColor;
    self.placeholderLabel.font = [self defaultFont];
    [self addSubview:self.placeholderLabel];
}

- (void) commonInit
{
    [self placeholderInit];
    
    self.Xpadding = 0;
    self.Ypadding = 0;
    [self addTarget:self action:@selector(textFieldEdittingDidEndInternal:) forControlEvents:UIControlEventEditingDidEnd];
    [self addTarget:self action:@selector(textFieldEdittingDidBeginInternal:) forControlEvents:UIControlEventEditingDidBegin];
    self.validateBlock = ^BOOL(NSString *text) {
        return YES;
    };
    
//    self.validationLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // Set default validation
//    self.leftvalidation = NO;
//    
//    if (self.leftvalidation)
//        self.validationLabel.frame = CGRectMake(self.layer.borderWidth,
//                                                0,
//                                                self.frame.size.height - self.layer.borderWidth,
//                                                self.frame.size.height - self.layer.borderWidth);
//    else
//        self.validationLabel.frame = CGRectMake(self.frame.size.width - self.frame.size.height,
//                                                0,
//                                                self.frame.size.height - self.layer.borderWidth,
//                                                self.frame.size.height - self.layer.borderWidth);
//    
//    self.validationFrame = self.validationLabel.frame;
//    self.sync = YES;
    
}

- (IBAction) textFieldEdittingDidBeginInternal:(UITextField *)sender
{
    [self runDidBeginAnimation];
}

- (IBAction) textFieldEdittingDidEndInternal:(UITextField *)sender
{
    [self runDidEndAnimation];
}

// Set default font size.
- (UIFont *)defaultFont
{
    UIFont *font = nil;
    
    if ( self.attributedPlaceholder && self.attributedPlaceholder.length > 0 )
    {
        font = [self.attributedPlaceholder attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    }
    else if ( self.attributedText && self.attributedText.length > 0 )
    {
        font = [self.attributedText attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    }
    else
    {
        font = self.font;
    }
    
    return [UIFont fontWithName:font.fontName size:roundf(font.pointSize * fontScale)];
}


// Format checking
- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    
    NSString * currentText = [self.text stringByReplacingCharactersInRange:range withString:string];
    NSLog(@"%@", currentText);
    if (currentText.length > self.format.length)
        return NO;
    NSMutableString * result = [[NSMutableString alloc] init];
    int last = 0;
    for (int i = 0; i < self.format.length; i++){
        if (last >= currentText.length)
            break;
        unichar charAtMask = [_format characterAtIndex:i];
        unichar charAtCurrent = [currentText characterAtIndex:last];
        if (charAtMask == '#'){
            if (self.onlyNumber && !isnumber(charAtCurrent)){
                last++;
                continue;
            }
            [result appendString:[NSString stringWithFormat:@"%c",charAtCurrent]];
        }
        else{
            [result appendString:[NSString stringWithFormat:@"%c",charAtMask]];
            if (charAtCurrent != charAtMask)
                last--;
        }
        last++;
    }
    
    self.text = result;
    return NO;
}

// Set up label frame. The default settings is to make the uplabel align with the placeholder
// Potential alignment need to be paid attention to
- (void) runDidBeginAnimation
{
    [self layoutPlaceholderLabel];
    [self showPlaceholderLabel];
}

- (void) runDidEndAnimation
{
    [self hidePlaceholderLabel];
}

- (void) layoutPlaceholderLabel
{
    if ( self.style == LRTextFieldEffectStyleNone )
    {
        
    }
    else if ( self.style == LRTextFieldEffectStyleUp )
    {
        CGRect rect = [self textRectForBounds:self.bounds];
        CGFloat originX = rect.origin.x;
        if ( self.textAlignment == NSTextAlignmentCenter )
        {
            originX = originX + (rect.size.width / 2) - (self.placeholderLabel.frame.size.width / 2);
        }
        else if ( self.textAlignment == NSTextAlignmentRight )
        {
            originX = originX + rect.size.width - self.placeholderLabel.frame.size.width;
        }
        
        CGSize uplableSize = [self.placeholderLabel sizeThatFits:self.placeholderLabel.superview.bounds.size];
        self.placeholderLabel.frame = CGRectMake(self.Xpadding + originX,
                                                 self.Ypadding + self.placeholderLabel.frame.origin.y,
                                                 uplableSize.width,
                                                 uplableSize.height);
    }
    else if ( self.style == LRTextFieldEffectStyleRight )
    {
        
    }
}

- (void) showPlaceholderLabel
{
    void (^showBlock)() = ^{
        self.placeholderLabel.alpha = 1.0f;
    };
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                     animations:showBlock
                     completion:nil];
}

- (void) hidePlaceholderLabel
{
    void (^hideBlock)() = ^{
        self.placeholderLabel.alpha = 0.0f;
    };
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                     animations:hideBlock
                     completion:nil];
}

// Override this function to make the editing rect move to the bottom.
- (CGRect) editingRectForBounds:(CGRect)bounds
{
    CGRect rect = [super editingRectForBounds:bounds];
    
    if ( self.style == LRTextFieldEffectStyleNone )
    {
        
    }
    else if ( self.style == LRTextFieldEffectStyleUp )
    {
        CGFloat top = self.bounds.size.height - rect.size.height;
        return CGRectIntegral(CGRectMake(rect.origin.x, rect.origin.y + top, rect.size.width, rect.size.height));
    }
    else if ( self.style == LRTextFieldEffectStyleRight )
    {
        
    }
    
    return rect;
}

// Override the function to make the placeholder rect move to the bottom.
- (CGRect) placeholderRectForBounds:(CGRect)bounds
{
    CGRect rect = [super editingRectForBounds:bounds];
    
    if ( self.style == LRTextFieldEffectStyleNone )
    {
        
    }
    else if ( self.style == LRTextFieldEffectStyleUp )
    {
        CGFloat top = self.bounds.size.height - rect.size.height;
        return CGRectIntegral(CGRectMake(rect.origin.x, rect.origin.y + top, rect.size.width, rect.size.height));
    }
    else if ( self.style == LRTextFieldEffectStyleRight )
    {
        
    }
    
    return rect;
}

// set validation block and mode
- (void)setTextValidationBlock:(ValidationBlock)block
                        isSync:(BOOL)sync{
    self.validateBlock = block;
    self.sync = sync;
}

// Run validation function and set textfield.leftview and rightview and show validation results.
- (void) TextValidation
{
    if (self.text.length == 0 || self.isFirstResponder){
        [self toggleText:NO];
        return;
    }

    if (self.sync){
        if (!_validateBlock(self.text))
            [self toggleText:YES];
        else
            [self toggleText:NO];
    }
    else{
        UIActivityIndicatorView *ActivityView = [[UIActivityIndicatorView alloc]
                                         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        if (self.leftvalidation){
            self.leftViewMode = UITextFieldViewModeAlways;
            self.leftView = ActivityView;
        }
        else{
            self.rightViewMode = UITextFieldViewModeAlways;
            self.rightView = ActivityView;
        }

        ActivityView.frame = self.validationFrame;
        [ActivityView startAnimating];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL valid = _validateBlock(weakSelf.text);
            dispatch_async(dispatch_get_main_queue(), ^{
                [ActivityView stopAnimating];
                if (self.leftvalidation){
                    [weakSelf.leftView removeFromSuperview];
                    weakSelf.leftView = nil;
                }
                else{
                    [weakSelf.rightView removeFromSuperview];
                    weakSelf.rightView = nil;
                }
                if (valid) {
                    [self toggleText:NO];
                }
                else{
                    [self toggleText:YES];
                }
            });
        });
    }
}

// Function that show the validation block.
// If show is YES, the validation block is showed. otherwise, it is removed.
- (void) toggleText:(BOOL)show
{
    if ( show )
    {
        UIView *view=[[UIView alloc] init];
        CGRect rect = self.validationFrame;
        view.frame=rect;
        UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"20100722211911-872914855.jpg"]];
        imageView.frame = view.bounds;
        [view addSubview:imageView];
        if (self.leftvalidation){
            self.leftViewMode = UITextFieldViewModeAlways;
            self.leftView = view;
        }
        else{
            self.rightViewMode = UITextFieldViewModeAlways;
            self.rightView = view;
        }
        [UIView animateWithDuration:.3 animations:^{
            if (self.leftvalidation)
                self.leftView.alpha = 1.0;
            else
                self.rightView.alpha = 1.0;
        }];
    }else{
        [UIView animateWithDuration:.3 animations:^{
            if (self.leftvalidation)
                self.leftView.alpha = 0.0;
            else
                self.rightView.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (self.leftvalidation){
                [self.leftView removeFromSuperview];
                self.leftView = nil;
            }
            else{
                [self.rightView removeFromSuperview];
                self.rightView = nil;
            }
        }];
    }
}


@end
