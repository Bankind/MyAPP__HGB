//
//  HGBCustomKeyBordSquareTextView.m
//  VirtualCard
//
//  Created by huangguangbao on 2017/6/22.
//  Copyright © 2017年 agree.com.cn. All rights reserved.
//

#import "HGBCustomKeyBordSquareTextView.h"
#import "HGBCustomKeyBordSquareTextField.h"
@interface HGBCustomKeyBordSquareTextView ()<HGBCustomKeyBordSquareTextFieldDelegate>
@property(nonatomic,assign)NSInteger length;
@property(nonatomic,assign)NSInteger index;
@property(nonatomic,assign)NSInteger count;
@end
@implementation HGBCustomKeyBordSquareTextView

//实例化整个view
-(instancetype)initWithFrame:(CGRect)frame length:(NSInteger)length
{
    if (self=[super init]) {
        int width=frame.size.width/length;
        _length=length;
        _count=0;
        for (int i=0; i<length; i++) {
            HGBCustomKeyBordSquareTextField *text=[[HGBCustomKeyBordSquareTextField alloc] initWithFrame:CGRectMake(i*width-2*i, 0, width, width)];
            if (i==0) {
                [text becomeFirstResponder];
                _index=0;
            }
            
            text.squareTextFieldDelegate=self;
            text.tag=i;
            text.textAlignment=NSTextAlignmentCenter;
            text.tintColor=[UIColor clearColor];
            text.layer.borderWidth=2;
            text.layer.borderColor=[[UIColor lightGrayColor] CGColor];
            text.borderStyle=UITextBorderStyleRoundedRect;
            text.secureTextEntry=YES;
            text.keyboardType=UIKeyboardTypeNumberPad;
            text.font=[UIFont systemFontOfSize:30];
            [text addTarget:self action:@selector(textValueChanged:) forControlEvents:UIControlEventEditingChanged];
            
            
            //为每个textfield添加遮罩 防止点击
            UIView *cover=[[UIView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
            [cover setBackgroundColor:[UIColor clearColor]];
            [text addSubview:cover];
            [self addSubview:text];
        }
        [self setFrame:frame];
        
    }
    return self;
}

-(void)setKeybord:(UIView *)keybord{
    _keybord=keybord;
    for (UITextField *text in self.subviews) {
        text.inputView=keybord;
    }
    self.inputView=keybord;
}

//textfield值
-(void)textValueChanged:(UITextField *)textField
{
    
    if (textField.text.length > 1) {
        textField.text = [textField.text substringToIndex:1];
    }
    
    if (textField.tag<_length) {
        if ([self getTextLength]>_count) {
            _count=[self getTextLength];
            if (textField.tag!=_length-1) {
                _index++;
                HGBCustomKeyBordSquareTextField *text= [self.subviews objectAtIndex:_index];
                [text becomeFirstResponder];
            }
            else{
                HGBCustomKeyBordSquareTextField *text= [self.subviews objectAtIndex:textField.tag];
                _index=textField.tag;
                [text resignFirstResponder];
                for (UITextField *t in self.subviews) {
                    [t resignFirstResponder];
                }
                [self resignFirstResponder];
                if ([self.squareViewDelegate respondsToSelector:@selector(squaresTextView: didFinishWithResult:)]) {
                    [self.squareViewDelegate squaresTextView:self didFinishWithResult:[self getTextString]];
                }
            }
        }
    }
    
}



//实现键盘删除键的代理方法
-(void)deleteBackward
{
    if (_index>0) {
        if ([self getTextLength]<_count) {
            HGBCustomKeyBordSquareTextField *text= [self.subviews objectAtIndex:_index];
            [text becomeFirstResponder];
            _count=[self getTextLength];
        }else
        {
            _index--;
            _count--;
            HGBCustomKeyBordSquareTextField *text= [self.subviews objectAtIndex:_index];
            text.text=@"";
            [text becomeFirstResponder];
        }
    }
}


-(NSInteger)getTextLength
{
    NSInteger count=0;
    for (UITextField *text in self.subviews) {
        if (text.text.length!=0) {
            count++;
        }else{
            break;
        }
    }
    return count;
}

-(NSString *)getTextString
{
    NSString *textResult=@"";
    for (UITextField *text in self.subviews) {
        textResult = [NSString stringWithFormat:@"%@%@",textResult,text.text];
    }
    return textResult;
}
@end
