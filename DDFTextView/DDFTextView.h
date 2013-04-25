//
//  DDFTextView.h
//  DDFTextView
//
//  Created by 董德富 on 13-4-25.
//  Copyright (c) 2013年 董德富. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DDFTextViewDelegate <NSObject>
@optional
- (void)ddfTextViewDidTouchSuccess:(NSString *)string;
@end

@interface DDFTextView : UIView

@property (nonatomic, assign) id<DDFTextViewDelegate> delegate;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) UIColor *textColor;

+ (float)heightOfText:(NSString *)text
                 font:(UIFont *)font
            limitSize:(CGSize)limitSize;

@end
