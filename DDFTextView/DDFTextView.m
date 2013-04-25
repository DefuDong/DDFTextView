//
//  DDFTextView.m
//  DDFTextView
//
//  Created by 董德富 on 13-4-25.
//  Copyright (c) 2013年 董德富. All rights reserved.
//

#import "DDFTextView.h"

@interface DDFTextView () {
    NSMutableArray *_faceRanges;    //表情索引 NSValue——NSRect
    NSMutableArray *_atRanges;      //@字符索引 NSValue——NSRect
    
    UIColor *_atTextColor;          //@颜色
    
    BOOL _isTouching;               //是否在触摸
    NSMutableArray *_atRects;       //@字符坐标 NSMutableArray---NSValue--CGRect
    int _atRectIndex;               //当前成功触摸的索引值
    
    BOOL _needAddRects;
}
@end

@implementation DDFTextView
- (void)setText:(NSString *)text {
    if (_text != text) {
        [_text release];
        _text = [text copy];
        
        [self getFaceCheckedRanges];
        [self getAtCheckedRanges];
        
        if (_atRects.count) {
            [_atRects removeAllObjects];
        }
        _needAddRects = YES;
        
        [self setNeedsDisplay];
    }
}
- (void)setFont:(UIFont *)font {
    if (_font != font) {
        [_font release];
        _font = [font retain];
        if (_text.length) {
            [self setNeedsDisplay];
        }
    }
}
- (void)setTextColor:(UIColor *)textColor {
    if (_textColor != textColor) {
        [_textColor release];
        _textColor = [textColor retain];
        if (_text.length) {
            [self setNeedsDisplay];
        }
    }
}


#pragma mark - pubilc
+ (float)heightOfText:(NSString *)text
                 font:(UIFont *)font
            limitSize:(CGSize)limitSize {
    if (text.length == 0) {
        return 0;
    }
    
    NSMutableArray *rangeArray = [NSMutableArray array];
    NSString *faceRegexString = @"\\[jk\\d\\d\\]";
    NSRegularExpression *faceRegex =
    [NSRegularExpression regularExpressionWithPattern:faceRegexString
                                              options:NSRegularExpressionCaseInsensitive
                                                error:NULL];
    if (faceRegex) {
        NSArray *array = [faceRegex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        for (NSTextCheckingResult *result in array) {
            [rangeArray addObject:[NSValue valueWithRange:result.range]];
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    
    CGPoint drawPoint = CGPointZero;
    int lenght = text.length;
    float cHeight = [@" " sizeWithFont:font].height;
    float width = limitSize.width;
    
    for (int i = 0; i < lenght; i++) {
        
        if (rangeArray.count) {
            NSRange faceRange = [rangeArray[0] rangeValue];
            if (i == faceRange.location) {
                if (drawPoint.x + cHeight > width) {
                    drawPoint.x = 0;
                    drawPoint.y += cHeight;
                }
                drawPoint.x += cHeight;
                
                i += faceRange.length-1;
                [rangeArray removeObjectAtIndex:0];
                continue;
            }
        }
        
        NSString *aString = [text substringWithRange:NSMakeRange(i, 1)];
        CGSize size = [aString sizeWithFont:font];
        
        if (drawPoint.x + size.width > width) {
            drawPoint.x = 0;
            drawPoint.y += cHeight;
        }
        drawPoint.x += size.width;
    }
    return drawPoint.y + cHeight;
}


#pragma mark - init & preset
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self perset];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self perset];
    }
    return self;
}
- (id)init {
    self = [super init];
    if (self) {
        [self perset];
    }
    return self;
}
- (void)perset {
    _faceRanges = [[NSMutableArray alloc] init];
    _atRanges = [[NSMutableArray alloc] init];
    _atRects = [[NSMutableArray alloc] init];
    _isTouching = NO;
    
    self.textColor = [UIColor blackColor];
    self.font = [UIFont systemFontOfSize:13];
    self.backgroundColor = [UIColor clearColor];
    _atTextColor = [[UIColor blueColor] retain];
}


#pragma mark - draw
- (void)drawRect:(CGRect)rect {
    
    //draw image & text
    CGPoint drawPoint = CGPointZero;
    int lenght = _text.length;
    float cHeight = [@" " sizeWithFont:_font].height;
    float width = self.frame.size.width;
    
    int faceIndex = 0;
    int atIndex = 0;
    
    for (int i = 0; i < lenght; i++) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [_textColor set];
        
        //image
        if (_faceRanges.count) {
            NSRange faceRange = [_faceRanges[faceIndex] rangeValue];
            if (i == faceRange.location) {
                if (drawPoint.x + cHeight > width) {
                    drawPoint.x = 0;
                    drawPoint.y += cHeight;
                }
                NSString *name = [_text substringWithRange:NSMakeRange(faceRange.location+1, faceRange.length-2)];
                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", name]];
                [image drawInRect:CGRectMake(drawPoint.x, drawPoint.y, cHeight, cHeight)];
                drawPoint.x += cHeight;
                
                i += faceRange.length-1;
                if (faceIndex < _faceRanges.count-1) {
                    faceIndex++;
                }
                continue;
            }
        }
        
        //text
        NSString *aString = [_text substringWithRange:NSMakeRange(i, 1)];
        CGSize size = [aString sizeWithFont:_font];
        
        if (drawPoint.x + size.width > width) {
            drawPoint.x = 0;
            drawPoint.y += cHeight;
        }
        CGRect rect = CGRectMake(drawPoint.x, drawPoint.y, size.width, size.height);
        
        //@text
        if (_atRanges.count) {
            NSRange atRange = [_atRanges[atIndex] rangeValue];
            if (NSLocationInRange(i, atRange)) {
                [_atTextColor set];
                //////add rects
                if (_needAddRects) {
                    [self addRect:rect index:atIndex];
                }
                
                if (i == atRange.location+atRange.length-1) {
                    if (atIndex < _atRanges.count-1) {
                        atIndex++;
                    }
                }
            }
        }
        
        [aString drawInRect:rect withFont:_font];
        drawPoint.x += size.width;
        
        [pool release];
    }
    
    //draw touch
    if (_isTouching) {
        CGContextRef contex = UIGraphicsGetCurrentContext();
        UIColor *fillColor = [UIColor colorWithWhite:0 alpha:.3];
        NSArray *touchRects = _atRects[_atRectIndex];
        for (NSValue *va in touchRects) {
            CGRect rect = [va CGRectValue];
            CGContextAddRect(contex, rect);
            CGContextSetFillColorWithColor(contex, fillColor.CGColor);
        }
        CGContextDrawPath(contex, kCGPathFill);
        return;
    }
    
    _needAddRects = NO;
}


#pragma mark - touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (touches.count == 1) {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        for (NSMutableArray *arr in _atRects) {
            int index = [_atRects indexOfObject:arr];
            for (NSValue *va in arr) {
                if (CGRectContainsPoint([va CGRectValue], touchPoint)) {
                    _isTouching = YES;
                    _atRectIndex = index;
                    [self setNeedsDisplay];
                    //                    NSLog(@"%@", [_text substringWithRange:[_atRanges[index] rangeValue]]);
                    return;
                }
            }
        }
    }
    [self.nextResponder touchesBegan:touches withEvent:event];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_isTouching) {
        NSString *touchString = [_text substringWithRange:[_atRanges[_atRectIndex] rangeValue]];
        NSString *returnString = [touchString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        if ([self.delegate respondsToSelector:@selector(ddfTextViewDidTouchSuccess:)]) {
            [self.delegate ddfTextViewDidTouchSuccess:returnString];
        }
    }else {
        [self.nextResponder touchesEnded:touches withEvent:event];
    }
    
    _isTouching = NO;
    [self setNeedsDisplay];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _isTouching = NO;
    [self setNeedsDisplay];
    [self.nextResponder touchesCancelled:touches withEvent:event];
}


#pragma mark - private
- (void)getFaceCheckedRanges {
    [_faceRanges removeAllObjects];
    NSString *faceRegexString = @"\\[jk\\d\\d\\]";
    NSRegularExpression *faceRegex =
    [NSRegularExpression regularExpressionWithPattern:faceRegexString
                                              options:NSRegularExpressionCaseInsensitive
                                                error:NULL];
    if (faceRegex) {
        NSArray *array = [faceRegex matchesInString:_text options:0 range:NSMakeRange(0, _text.length)];
        for (NSTextCheckingResult *result in array) {
            [_faceRanges addObject:[NSValue valueWithRange:result.range]];
        }
    }
}
- (void)getAtCheckedRanges {
    [_atRanges removeAllObjects];
    NSString *atRegexString = @"@[\\w\u4e00-\u9fa5]+";
    NSRegularExpression *atRegex =
    [NSRegularExpression regularExpressionWithPattern:atRegexString
                                              options:NSRegularExpressionCaseInsensitive
                                                error:NULL];
    if (atRegex) {
        NSArray *array = [atRegex matchesInString:_text options:0 range:NSMakeRange(0, _text.length)];
        for (NSTextCheckingResult *result in array) {
            [_atRanges addObject:[NSValue valueWithRange:result.range]];
        }
    }
}

- (void)addRect:(CGRect)rect index:(int)index {
    
    if (index > (_atRects.count-1) || _atRects.count == 0) { //新的， 添加
        NSValue *va = [NSValue valueWithCGRect:rect];
        NSMutableArray *arr = [NSMutableArray arrayWithObject:va];
        [_atRects addObject:arr];
//        NSLog(@"--new");
    }else if (index >= 0) { //已有， 扩展
        
        NSMutableArray *array = _atRects[index];
        BOOL needNewLine = YES;
        for (int i = 0; i < array.count; i++) {
            
            CGRect perRect = [array[i] CGRectValue];
            if (perRect.origin.y == rect.origin.y && rect.origin.x > perRect.origin.x) {
                CGRect curRect = CGRectMake(perRect.origin.x,
                                            perRect.origin.y,
                                            perRect.size.width+rect.size.width,
                                            perRect.size.height);
                array[i] = [NSValue valueWithCGRect:curRect];
//                NSLog(@"++add");
                needNewLine = NO;
            }
        }
        if (needNewLine){ //需要添加新的行
            [array addObject:[NSValue valueWithCGRect:rect]];
//            NSLog(@"new line");
        }
        
    }
}


#pragma mark - others
- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)dealloc {
    //    [_faceInfoArray release];
    [_text release];
    [_textColor release];
    [_font release];
    
    [_faceRanges release];
    [_atRanges release];
    
    [_atTextColor release];
    [_atRects release];
    
    [super dealloc];
}

@end

